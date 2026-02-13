{{ config(materialized='table') }}

with accounts as (
    select * from {{ ref('stg_neon__accounts') }}
),

subscriptions as (
    select * from {{ ref('stg_neon__subscriptions') }}
),

customer_subscription_metrics as (
    select
        account_id,
        sum(mrr_amount) as total_mrr,
        sum(arr_amount) as total_arr,
        max(start_date) as latest_subscription_start_date,
        count(subscription_id) as active_subscriptions_count
    from subscriptions
    {# Utilizing the churn_flag found in your BigQuery schema #}
    where churn_flag is false
    group by 1
),

final as (
    select
        a.account_id,
        a.referral_source,
        a.synced_at_utc as account_last_synced_at,
        coalesce(csm.total_mrr, 0) as mrr,
        coalesce(csm.total_arr, 0) as arr,
        csm.latest_subscription_start_date,
        case 
            when csm.total_mrr > 0 then 'Active'
            else 'Inactive/Churned'
        end as customer_status
    from accounts a
    left join customer_subscription_metrics csm 
        on a.account_id = csm.account_id
)

select * from final