with source as (
    {# Taking raw subscription data from the source #}
    select * from {{ source('neon_raw', 'ravenstack_subscriptions') }}
),

renamed as (
    select
        {# Primary and foreign keys #}
        subscription_id,
        account_id,
        
        {# Dates and Plan details #}
        start_date,
        end_date,
        plan_tier,
        billing_frequency,
        
        {# Financial metrics - already in BIGNUMERIC, no casting needed #}
        mrr_amount,
        arr_amount,
        
        {# Business flags #}
        is_trial,
        churn_flag,
        auto_renew_flag,
        
        {# Technical metadata #}
        _fivetran_synced as synced_at_utc

    from source
)

select * from renamed