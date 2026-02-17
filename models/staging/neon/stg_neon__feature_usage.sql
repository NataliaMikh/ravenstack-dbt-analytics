with source as (
    select * from {{ source('neon_raw', 'ravenstack_feature_usage') }}
),

renamed as (
    select
        usage_id,
        subscription_id,
        cast(usage_date as date) as usage_date,
        feature_name,
        
        {# Mapping generic feature IDs to strategic categories for analysis #}
        case 
            when feature_name in ('feature_32', 'feature_12', 'feature_6') then 'AI Tools'
            when feature_name in ('feature_17', 'feature_34') then 'Analytics Dashboard'
            else 'Core Platform'
        end as feature_category,

        usage_count,
        usage_duration_secs,
        error_count,
        is_beta_feature,
        _fivetran_deleted as is_deleted,
        _fivetran_synced as synced_at_utc

    from source
    where _fivetran_deleted = false 
)

select * from renamed