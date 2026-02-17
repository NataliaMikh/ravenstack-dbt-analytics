with accounts as (
    select * from {{ ref('stg_neon__accounts') }}
),

churn as (
    select * from {{ ref('stg_neon__churn') }}
),

usage_stats as (
    select 
        account_id,
        sum(usage_count) as total_usage_events,
        sum(error_count) as total_errors
    from {{ ref('int_feature_usage_by_account') }}
    group by 1
),

final as (
    select
        -- Using explicit aliases to avoid "struct" confusion
        acc.account_id,
        acc.account_name,
        acc.industry,
        acc.plan_tier, -- Adjusted to match the field name in your stg_accounts
        
        -- Status Logic
        case 
            when c.churn_date is not null then 'Churned'
            else 'Active'
        end as customer_status,
        
        -- Aggregated Metrics
        coalesce(u.total_usage_events, 0) as total_usage_events,
        coalesce(u.total_errors, 0) as total_errors,
        c.churn_date

    from accounts as acc
    left join churn as c on acc.account_id = c.account_id
    left join usage_stats as u on acc.account_id = u.account_id
)

select * from final