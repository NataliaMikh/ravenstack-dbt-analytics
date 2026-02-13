with source as (
    {# Taking raw support tickets data from the source #}
    select * from {{ source('neon_raw', 'ravenstack_support_tickets') }}
),

renamed as (
    select
        {# IDs #}
        ticket_id,
        account_id,
        
        {# Timing and metrics #}
        submitted_at,
        closed_at,
        resolution_time_hours,
        first_response_time_minutes,
        
        {# Ticket attributes #}
        priority as ticket_priority,
        satisfaction_score,
        escalation_flag,
        
        {# Technical metadata #}
        _fivetran_synced as synced_at_utc

    from source
)

select * from renamed