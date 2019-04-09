json.array! license_types do |lt|
  json.partial! "api/licenses/license_type", license_type: lt
end
