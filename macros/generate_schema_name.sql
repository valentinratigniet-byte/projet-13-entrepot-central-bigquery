{# Utilise le schema custom (+schema) tel quel, sans le concatener au dataset
   par defaut du profil (comportement standard dbt sur BigQuery multi-dataset). #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
