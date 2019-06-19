json.data @institutions do |institution|
  json.type "institutions"
  json.id institution.id
  json.attributes do
    json.id institution.id
    json.name institution.name
    json.edit_url edit_institution_path(institution)
    json.has_site_license institution.has_site_license
    json.institution_type institution.institution_type
    json.has_google_access institution.has_google_access
  end
end
