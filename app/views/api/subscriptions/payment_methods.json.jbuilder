json.data @payment_methods do |payment_method|
  json.type "payment_methods"
  json.id payment_method.id.to_s
  json.attributes do
    json.id payment_method.id.to_s
    json.full_name payment_method.billing_details.name
    json.city payment_method.billing_details.address.city
    json.addr1 payment_method.billing_details.address.line1
    json.addr2 payment_method.billing_details.address.line2
    json.phone payment_method.billing_details.phone
    json.country payment_method.card.country
    json.last4 payment_method.card.last4
    json.exp_month payment_method.card.exp_month
    json.exp_year payment_method.card.exp_year
    json.brand payment_method.card.brand
  end
end
