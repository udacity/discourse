Fabricator(:activity) do
  action {|attrs| attrs[:action] || 'create'}
  trackable {|attrs| attrs[:trackable]}
  user {|attrs| attrs[:trackable].user}
end
