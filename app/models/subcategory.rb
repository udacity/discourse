class Subcategory < ActiveRecord::Base
  attr_accessible :key, :name, :category_id, :user_id

  belongs_to :user
  belongs_to :category
  has_many :topics

  validates :category_id, presence: true
  validates :user_id, presence: true
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true, length: { in: 1..255 }

  # TODO broussev add publish_subcategory_list & invalidate_site_cache
end
