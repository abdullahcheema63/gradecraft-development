json.array! billing_schemes do |bs|
  json.partial! "api/subscriptions/billing_scheme", billing_scheme: bs
end
