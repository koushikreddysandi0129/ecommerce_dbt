{{
    silver_config('order_id')
}}

/*
attempt_id	VARCHAR (PK)	Natural key from unnested payment_attempts[]
payment_id	VARCHAR (FK)	References silver.payments.payment_id
attempt_timestamp	TIMESTAMP_NTZ	Typed
status	VARCHAR	SUCCESS / DECLINED / FAILED / PENDING
gateway	VARCHAR	Stripe / Razorpay / PayPal / Adyen / Braintree
gateway_response_code, gateway_response_message
*/

with payment_attempts_flat as (
    select
        cast(pa.value:attempt_id as string)                 as attempt_id,
        cast(raw:payment_id as string)                      as payment_id,
        cast(pa.value:attempt_timestamp as timestamp_ntz)   as attempt_timestamp,
        cast(pa.value:status as string)                     as status,
        cast(pa.value:gateway as string)                    as gateway,
        cast(pa.value:gateway_response:code as string)      as gateway_response_code,
        cast(pa.value:gateway_response:message as string)   as gateway_response_message,                
        current_timestamp()                                 as dbt_updated_at
    from {{ source('ecommerce', 'raw_payments') }} s,
        lateral flatten (input => s.raw:payment_attempts) pa
    qualify row_number() over (partition by cast(pa.value:attempt_id as string) order by _loaded_at desc) = 1
)
select
    *
from payment_attempts_flat