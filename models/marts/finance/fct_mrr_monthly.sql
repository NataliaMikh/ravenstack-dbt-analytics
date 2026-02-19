{{ config(materialized='table') }}

with subs as (

    select
        subscription_id,
        account_id,
        mrr_amount,
        date_trunc(date(start_date), month) as start_month,
        date_trunc(date(coalesce(end_date, current_date())), month) as end_month
    from {{ ref('stg_neon__subscriptions') }}

),

-- Build a month spine from min start_month to max end_month
bounds as (
    select
        min(start_month) as min_month,
        max(end_month) as max_month
    from subs
),

month_spine as (
    select month
    from bounds,
    unnest(generate_date_array(min_month, max_month, interval 1 month)) as month
),

expanded as (
    select
        s.account_id,
        s.subscription_id,
        m.month,
        s.mrr_amount
    from subs s
    join month_spine m
      on m.month between s.start_month and s.end_month
)

select
    month,
    account_id,
    sum(mrr_amount) as mrr
from expanded
group by 1,2
