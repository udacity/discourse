class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :trackable, :polymorphic => true
  attr_accessible :action, :trackable

  validates :user_id, :trackable_id, :trackable_type, :action, :presence => true

  BATCH_SIZE = 1000
  MAX_BATCH_SIZE = 5000

  scope :logged_after, ->(options) do
    return unless options[:offset]
    user_id = options[:user_id]
    batch_size = options[:batch_size] || BATCH_SIZE
    include_trackable = options[:detailed] == 'true'
    batch_size = [batch_size, MAX_BATCH_SIZE].min
    conditions = where('id > ?', options[:offset]).order(:id).limit(batch_size).includes(:user)
    conditions = conditions.includes(:trackable) if include_trackable
    conditions = conditions.where(:user_id => user_id) if user_id
    conditions
  end
end
