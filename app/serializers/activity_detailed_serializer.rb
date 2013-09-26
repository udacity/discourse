class ActivityDetailedSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :action,
             :trackable_id,
             :trackable_type,
             :created_at,
             :version,
             :key

  has_one :trackable, polymorphic: true

  def version
    1
  end

  def key
    scope.user.email[0, scope.user.email.index('@')]
  end
end
