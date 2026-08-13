{{
    silver_config('order_id')
}}

with order_line_items_flat as (
    select
        cast(raw:order_id as string)                        as order_id,						
        cast(oi.value:order_item_id as string)              as order_line_item,
        cast(oi.value:product_id as string)                 as product_id,
        cast(oi.value:quantity as number)                   as quantity,
        cast(oi.value:unit_price as number(10,2))           as unit_price,
        cast(oi.value:discount.type as string)              as discount_type,
        cast(oi.value:discount.value as number(5,2))        as discount_value,
        cast(oi.value:line_total as number(12,2))           as line_total,
        current_timestamp()                                 as dbt_updated_at                     
    from {{ source('ecommerce', 'raw_orders') }} s,
        lateral flatten (input=> s.raw:order_items) oi
    qualify row_number() over (partition by cast(oi.value:order_item_id as string) order by _loaded_at desc) = 1
)
select
    *
from order_line_items_flat