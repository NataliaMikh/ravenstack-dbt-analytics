with accounts as (
    select 
        account_id,
        date_trunc(signup_date, month) as cohort_month
    from {{ ref('dim_accounts') }}
),

-- Here we bring in the revenue per month
monthly_revenue as (
    select
        account_id,
        date_trunc(usage_date, month) as activity_month,
        sum(usage_count) as total_interactions, -- Engagement metric
        -- We'll assume for this exercise that active usage correlates with active MRR
        -- In a real scenario, you'd join with a monthly_invoice table here
        count(distinct usage_id) * 10 as estimated_monthly_revenue 
    from {{ ref('int_feature_usage_by_account') }}
    group by 1, 2
),

final as (
    select
        a.cohort_month,
        r.activity_month,
        date_diff(r.activity_month, a.cohort_month, month) as months_since_signup,
        count(distinct a.account_id) as retained_customers,
        sum(r.estimated_monthly_revenue) as cohort_revenue
    from accounts a
    join monthly_revenue r on a.account_id = r.account_id
    group by 1, 2, 3
)

select * from final
order by 1, 3