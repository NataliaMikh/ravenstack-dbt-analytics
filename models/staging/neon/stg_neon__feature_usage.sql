with source as (
    {# Extracting raw feature usage logs from Neon #}
    select * from {{ source('neon_raw', 'ravenstack_feature_usage') }}
),

renamed as (
    select
        {# IDs for linking to accounts and subscriptions #}
        usage_id,
        subscription_id,
        
        {# Event details: Casting to DATE for daily aggregation #}
        cast(usage_date as date) as usage_date,
        feature_name,
        
        {# Usage metrics #}
        usage_count,
        usage_duration_secs,
        error_count,
        
        {# Boolean flags #}
        is_beta_feature,
        
        {# Technical metadata #}
        _fivetran_deleted as is_deleted_from_source,
        _fivetran_synced as synced_at_utc

    from source
)

select * from renamed