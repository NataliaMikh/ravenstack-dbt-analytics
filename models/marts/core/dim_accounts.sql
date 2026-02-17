with accounts as (
    select * from {{ ref('stg_neon__accounts') }}
),

subscriptions as (
    select 
        account_id,
        sum(mrr_amount) as total_mrr,
        sum(arr_amount) as total_arr,
        max(plan_tier) as current_plan_tier
    from {{ ref('stg_neon__subscriptions') }}
    where churn_flag is false  -- only active subscribers
    group by 1
),

final as (
    select
        a.account_id,
        a.account_name,
        a.industry,
        a.country,
        a.signup_date,
        a.referral_source,
        coalesce(s.current_plan_tier, 'Free') as current_plan_tier,
        coalesce(s.total_mrr, 0) as mrr,
        -- status
        case 
            when s.total_mrr > 0 then 'Active'
            else 'Inactive/Trial'
        end as account_status,
        date_diff(current_date(), a.signup_date, day) as account_tenure_days
    from accounts a
    left join subscriptions s on a.account_id = s.account_id
)

select * from final