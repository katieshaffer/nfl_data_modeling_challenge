{%- set years = [2020, 2021, 2022, 2023, 2024] -%}

{% for year in years %}
    select *, 
        {{ year }} as year
    from {{ ref('stg_seasonal_stats_' ~ year) }}
    {% if not loop.last %}union all{% endif %}
{% endfor %}
