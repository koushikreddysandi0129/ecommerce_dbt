{{
    silver_config('product_id')
}}

with products_flat as (
    select
        product_id,						
        product_name,						
        category,						
        subcategory,						
        brand,						
        unit_price,						
        cost_price,						
        currency,						
        stock_quantity,						
        supplier_id,						
        supplier_name,						
        is_active,						
        created_at,						 
        cast(updated_at as timestamp_ntz)               as last_updated_at,
        current_timestamp()                             as dbt_updated_at 
    from {{ source('ecommerce', 'raw_products') }}
    qualify row_number() over (partition by product_id order by _loaded_at desc) = 1
)
select
    *
from products_flat