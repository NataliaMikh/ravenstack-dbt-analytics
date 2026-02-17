with accounts as (
    select 
        account_id,
        account_name,
        industry,
        plan_tier 
    from {{ ref('stg_neon__accounts') }}
),

churn_summarized as (
    select 
        account_id,
        max(churn_date) as latest_churn_date
    from {{ ref('stg_neon__churn') }}
    group by 1
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
        acc.account_id,
        acc.account_name,
        acc.industry,
        acc.plan_tier,
        
        case 
            when c.latest_churn_date is not null then 'Churned'
            else 'Active'
        end as customer_status,
        
        coalesce(u.total_usage_events, 0) as total_usage_events,
        coalesce(u.total_errors, 0) as total_errors,
        c.latest_churn_date as churn_date

    from accounts as acc
    left join churn_summarized as c on acc.account_id = c.account_id
    left join usage_stats as u on acc.account_id = u.account_id
)

select * from final