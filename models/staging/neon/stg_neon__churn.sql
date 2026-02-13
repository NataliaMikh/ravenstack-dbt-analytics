with source as (
    {# Extracting raw churn events from Neon #}
    select * from {{ source('neon_raw', 'ravenstack_churn_events') }}
),

renamed as (
    select
        {# Primary and foreign keys #}
        churn_event_id,
        account_id,
        
        {# Dates: Casting to DATE for cleaner analysis if needed #}
        cast(churn_date as date) as churn_date,
        
        {# Business attributes #}
        reason_code as churn_reason_code,
        refund_amount_usd,
        
        {# Logic: Boolean flags #}
        preceding_upgrade_flag,
        preceding_downgrade_flag,
        is_reactivation,
        
        {# Text data #}
        feedback_text,
        
        {# Technical metadata #}
        _fivetran_deleted as is_deleted_from_source,
        _fivetran_synced as synced_at_utc

    from source
)

select * from renamed