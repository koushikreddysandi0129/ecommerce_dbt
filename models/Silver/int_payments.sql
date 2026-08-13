{{
    silver_config('order_id')
}}

with payments_flat as (
    select
        cast(raw:payment_id as string)                      as payment_id,
        cast(raw:order_id as string)                        as order_id,						
        cast(raw:customer_id as string)                     as customer_id,						
        cast(raw:payment_date as timestamp_ntz)             as payment_date,					
        cast(raw:currency as varchar(3))                    as currency,
        cast(raw:amount as number(12,2))                    as amount,
        cast(raw:billing_address:street as string)          as shipping_street,
        cast(raw:billing_address:city as string)            as shipping_city,
        cast(raw:billing_address:state as string)           as shipping_state,
        cast(raw:billing_address:country as string)         as shipping_country,
        cast(raw:billing_address:postal_code as string)     as shipping_postal_code,
        cast(raw:final_status as string)                    as order_total,
        cast(raw:refund.is_refunded as boolean)             as is_refunded,
        cast(raw:refund.refund_amount as number(12,2))      as refund_amount,
        cast(raw:refund.refund_date as timestamp_ntz)       as refund_date,
        current_timestamp()                                 as dbt_updated_at
    from {{ source('ecommerce', 'raw_payments') }},
    qualify row_number() over (partition by cast(raw:payment_id as string) order by _loaded_at desc) = 1
)
select
    *
from payments_flat