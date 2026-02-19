with mrr as (

    select
        month,
        total_mrr
    from {{ ref('fct_mrr_monthly_totals') }}

),

active_accounts as (

    select
        month,
        count(distinct account_id) as active_customers
    from {{ ref('fct_mrr_monthly') }}
    where mrr > 0
    group by 1

)

select
    m.month,
    m.total_mrr,
    a.active_customers,
    m.total_mrr / a.active_customers as arpu

from mrr m
left join active_accounts a
    on m.month = a.month
