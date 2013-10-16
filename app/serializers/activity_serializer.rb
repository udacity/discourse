class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :user_id, :action, :trackable_id, :trackable_type, :created_at, :version, :key

  def version
    1
  end

  def key
    object.user.email[0, object.user.email.index('@')]
  end
end
