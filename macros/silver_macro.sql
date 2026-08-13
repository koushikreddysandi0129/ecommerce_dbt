{% macro silver_config(unique_key) %}

{{
    config (
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = unique_key,
        schema = 'silver'
    )
}}

{% endmacro %}