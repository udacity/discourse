# kind of odd, but we need it, we also need to nuke usage of User from inside migrations
#  very poor form
User.reset_column_information
user = User.where("id <> -1 and username_lower = 'system'").first
if user
  user.username = UserNameSuggester.suggest("system")
  user.save
end

User.seed do |u|
  u.id = -1
  u.name = "system"
  u.username = "system"
  u.username_lower = "system"
  u.email = "no_email"
  u.password = SecureRandom.hex
  # TODO localize this, its going to require a series of hacks
  u.bio_raw = "Not a real person. A global user for system notifications and other system tasks."
  u.active = true
  u.admin = true
  u.moderator = true
  u.email_direct = false
  u.approved = true
  u.email_private_messages = false
end

User.seed do |u|
  u.id = 1
  u.name = "Alfred Hitchcock"
  u.username = "Alfred"
  u.email = "alfred@udacity.com"
  u.username_lower = "alfred"
  u.password_hash = "6dc14c97bac279f7ba86b6fef728f2a228b4722bfc2401e826406a79897c8b78"
  u.salt = "c38fff795b91095b70a7222f4c25828b"
  u.auth_token = "1bef3739668d7264baf2250d47a27571"
  u.admin = true
  u.active = true
  u.approved = true
  u.trust_level = 0
end
User.find(1).activate

User.seed do |u|
  u.id = 2
  u.name = "Bruce Willis"
  u.username = "Bruce"
  u.username_lower = "bruce"
  u.email = "bruce@udacity.com"
  u.password_hash = "6dc14c97bac279f7ba86b6fef728f2a228b4722bfc2401e826406a79897c8b78"
  u.salt = "c38fff795b91095b70a7222f4c25828b"
  u.auth_token = "1bef3739668d7264baf2250d47a27571"
  u.admin = false
  u.active = true
  u.approved = true
  u.trust_level = 0
end
User.find(2).activate

User.seed do |u|
  u.id = 3
  u.name = "Caroline Wozniacki"
  u.username = "Caroline"
  u.username_lower = "caroline"
  u.email = "caroline@udacity.com"
  u.password_hash = "6dc14c97bac279f7ba86b6fef728f2a228b4722bfc2401e826406a79897c8b78"
  u.salt = "c38fff795b91095b70a7222f4c25828b"
  u.auth_token = "1bef3739668d7264baf2250d47a27571"
  u.admin = false
  u.active = true
  u.approved = true
  u.trust_level = 0
end
User.find(3).activate

