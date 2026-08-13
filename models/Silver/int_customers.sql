{{
    silver_config('customer_id')
}}

with customers_flat as (
    select
        customer_id, 
        first_name, 
        last_name, 
        email, 
        phone, 
        gender, 
        date_of_birth, 
        signup_date, 
        customer_segment, 
        loyalty_tier, 
        city, 
        state, 
        country, 
        postal_code, 
        is_active, 
        cast(last_updated_at as timestamp_ntz)          as last_updated_at,
        current_timestamp()                             as dbt_updated_at 
    from {{ source('ecommerce', 'raw_customers') }}
    qualify row_number() over (partition by customer_id order by _loaded_at desc) = 1
)
select
    *
from customers_flat