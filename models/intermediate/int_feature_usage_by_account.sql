with feature_usage as (
    select * from {{ ref('stg_neon__feature_usage') }}
),

subscriptions as (
    select 
        subscription_id,
        account_id,
        plan_tier
    from {{ ref('stg_neon__subscriptions') }}
),

joined as (
    select
        f.usage_id,
        f.usage_date,
        s.account_id,        {# The critical link #}
        s.plan_tier,         {# to compare Basic vs Pro usage #}
        f.feature_name,
        f.feature_category,
        f.usage_count,
        f.error_count
    from feature_usage f
    left join subscriptions s on f.subscription_id = s.subscription_id
)

select * from joined