json.data @users do |user|
  json.type "users"
  json.id user.id
  json.attributes do
    json.email user.email
    json.first_name user.first_name
    json.last_name user.last_name
  end
end
