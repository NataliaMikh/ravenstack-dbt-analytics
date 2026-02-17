with usage as (
    select
        account_id,
        sum(usage_count) as total_interactions,
        count(distinct feature_name) as unique_features_used
    from {{ ref('int_feature_usage_by_account') }}
    group by 1
),

churn_data as (
    select
        account_id,
        total_errors,
        customer_status 
    from {{ ref('fct_churn_analysis') }}
),

final as (
    select
        u.account_id,
        u.total_interactions,
        u.unique_features_used,
        c.total_errors,
        -- Health formula
        (u.unique_features_used * 10) - (c.total_errors * 5) as health_score,
        case 
            when c.customer_status = 'Churned' then 'Inactive'
            when c.total_errors > 5 then 'At Risk'
            when u.unique_features_used > 3 and c.total_errors = 0 then 'Healthy / Upsell Candidate'
            else 'Stable'
        end as prediction_status
    from usage u
    left join churn_data c on u.account_id = c.account_id
)

select * from final