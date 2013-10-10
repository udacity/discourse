Fabricator(:subcategory) do
  name { sequence(:name) { |n| "Amazing Subcategory #{n}" } }
  user
  category {|attrs| Fabricate(:category, user: attrs[:user] ) }
  key { sequence(:key) { |k| k.to_s} }
end
