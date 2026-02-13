with
    source as (
        {# Reference the raw accounts table from the neon_raw source #}
        select * from {{ source("neon_raw", "accounts") }}
    ),

    renamed as (
        select
            account_id,
            account_name,
            industry,
            country,
            referral_source,
            signup_date,
            plan_tier,
            seats,
            is_trial,
            churn_flag,

            {# Technical metadata from Fivetran #}
            _fivetran_deleted as is_deleted_from_source,
            _fivetran_synced as synced_at_utc

        from source
    )

select *
from renamed
