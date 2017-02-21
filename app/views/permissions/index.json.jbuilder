json.array!(@permissions) do |permission|
  json.extract! permission, *Permission.json_keys
  json.target_name permission.target_name
  json.target_type permission.target_type
  json.removable permission.user_id!=current_user.id
end
