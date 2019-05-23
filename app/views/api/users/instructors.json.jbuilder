json.data @instructors.includes(:course_memberships) do |instructor|
  json.type "instructors"
  json.id instructor.id
  json.attributes do
    json.id instructor.id
    json.name instructor.first_name
  end
end
