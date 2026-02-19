{{ config(materialized='table') }}

with account_cohorts as (

    select
        account_id,
        date_trunc(date(signup_date), month) as cohort_month
    from {{ ref('stg_neon__accounts') }}

),

mrr_monthly as (

    select
        month as activity_month,
        account_id,
        mrr
    from {{ ref('fct_mrr_monthly') }}

),

cohort_monthly as (

    select
        c.cohort_month,
        m.activity_month,
        date_diff(m.activity_month, c.cohort_month, month) as months_since_signup,
        count(distinct m.account_id) as active_accounts,
        sum(m.mrr) as cohort_mrr
    from account_cohorts c
    join mrr_monthly m
      on m.account_id = c.account_id
     and m.activity_month >= c.cohort_month
    group by 1,2,3

),

cohort_sizes as (

    select
        cohort_month,
        count(distinct account_id) as cohort_accounts
    from account_cohorts
    group by 1

),

final as (

    select
        cm.cohort_month,
        cm.activity_month,
        cm.months_since_signup,
        cm.active_accounts,
        cs.cohort_accounts,
        safe_divide(cm.active_accounts, cs.cohort_accounts) as customer_retention_rate,
        cm.cohort_mrr
    from cohort_monthly cm
    join cohort_sizes cs using (cohort_month)

)

select *
from final
order by cohort_month, months_since_signup
