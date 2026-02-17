with account_usage as (
    select
        account_id,
        count(distinct feature_name) as features_used,
        sum(usage_count) as total_usage
    from {{ ref('int_feature_usage_by_account') }}
    group by 1
),

account_info as (
    select 
        account_id,
        current_plan_tier
    from {{ ref('dim_accounts') }} 
),

final as (
    select
        u.account_id,
        i.current_plan_tier,
        u.features_used,
        u.total_usage,
        case 
            when i.current_plan_tier = 'Basic' and u.features_used >= 3 then 'High Potential'
            when i.current_plan_tier = 'Trial' and u.total_usage > 10 then 'Convert to Paid'
            else 'Maintain'
        end as sales_action
    from account_usage u
    join account_info i on u.account_id = i.account_id
)

select * from final