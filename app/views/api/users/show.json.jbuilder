json.data do @user
  json.type "user"
  json.id @user.id.to_s
  json.attributes do
    json.id @user.id.to_s
    json.username @user.username
    json.first_name @user.first_name
    json.last_name @user.last_name
    json.email @user.email
    json.created_at @user.created_at
    json.last_login @user.last_login_at
    json.last_logout @user.last_logout_at
    json.show_guide @user.show_guide
    json.admin @user.admin
    json.current_course_id @user.current_course_id
    json.account_url edit_profile_users_path
  end
end
