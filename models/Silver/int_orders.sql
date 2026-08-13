{{
    silver_config('order_id')
}}

with orders_flat as (
    select
        cast(raw:order_id as string)                        as order_id,						
        cast(raw:customer_id as string)                     as customer_id,						
        cast(raw:order_date as timestamp_ntz)               as order_date,					
        cast(raw:order_status as string)                    as order_status,
        cast(raw:currency as varchar(3))                    as currency,
        cast(raw:payment_method as string)                  as payment_method,
        cast(raw:shipping_address:street as string)         as shipping_street,
        cast(raw:shipping_address:city as string)           as shipping_city,
        cast(raw:shipping_address:state as string)          as shipping_state,
        cast(raw:shipping_address:country as string)        as shipping_country,
        cast(raw:shipping_address:postal_code as string)    as shipping_postal_code,
        cast(raw:order_total as number(10,2))               as order_total,
        cast(raw:updated_at as timestamp_ntz)               as last_updated_at,
        current_timestamp()                                 as dbt_updated_at
    from {{ source('ecommerce', 'raw_orders') }},
    qualify row_number() over (partition by cast(raw:order_id as string) order by _loaded_at desc) = 1
)
select
    *
from orders_flat