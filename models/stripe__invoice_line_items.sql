{{ config(enabled=var('using_invoices', True)) }}

with invoice as (

    select *
    from {{ ref('stg_stripe__invoice') }}  

), charge as (

    select *
    from {{ ref('stg_stripe__charge') }}  

), invoice_line_item as (

    select *
    from {{ ref('stg_stripe__invoice_line_item') }}  

), customer as (

    select *
    from {{ ref('stg_stripe__customer') }}  

{% if var('using_subscriptions', True) %}

), subscription as (

    select *
    from {{ ref('stg_stripe__subscription') }}  

), plan as (

    select *
    from {{ ref('stg_stripe__plan') }}  

{% endif %}
)

select 
    invoice.invoice_id,
    invoice.number,
    invoice.created_at as invoice_created_at,
    invoice.status,
    invoice.due_date,
    invoice.amount_due,
    invoice.subtotal,
    invoice.tax,
    invoice.total,
    invoice.amount_paid,
    invoice.amount_remaining,
    invoice.attempt_count,
    invoice.description as invoice_memo,
    invoice_line_item.unique_id  as invoice_line_item_id,
    invoice_line_item.description as line_item_desc,
    invoice_line_item.amount as line_item_amount,
    invoice_line_item.quantity,
    invoice_line_item.period_start,
    invoice_line_item.period_end,
    charge.balance_transaction_id,
    charge.amount as charge_amount, 
    charge.status as charge_status,
    charge.created_at as charge_created_at,
    customer.description as customer_description,
    customer.email as customer_email,
    customer.customer_id

    {% if var('using_subscriptions', True) %}
    ,subscription.subscription_id,
    subscription.billing as subcription_billing,
    subscription.start_date as subscription_start_date,
    subscription.ended_at as subscription_ended_at,
    plan.plan_id,
    plan.is_active as plan_is_active,
    plan.amount as plan_amount,
    plan.plan_interval as plan_interval,
    plan.interval_count as plan_interval_count,
    plan.nickname as plan_nickname,
    plan.product_id as plan_product_id
    {% endif %}
    
from invoice

left join charge 
    on charge.charge_id = invoice.charge_id
left join invoice_line_item 
    on invoice.invoice_id = invoice_line_item.invoice_id

{% if var('using_subscriptions', True) %}
left join subscription 
    on invoice_line_item.subscription_id = subscription.subscription_id
left join plan 
    on invoice_line_item.plan_id = plan.plan_id
{% endif %}

left join customer 
    on invoice.customer_id = customer.customer_id

order by invoice.created_at desc
