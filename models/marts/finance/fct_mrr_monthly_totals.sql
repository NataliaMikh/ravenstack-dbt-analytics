{{ config(materialized='view') }}

select
  month,
  sum(mrr) as total_mrr
from {{ ref('fct_mrr_monthly') }}
group by 1
order by month
