class Subcategory < ActiveRecord::Base
  attr_accessible :key, :name, :category_id, :user_id

  belongs_to :user
  belongs_to :category
  has_many :topics

  validates :category_id, presence: true
  validates :user_id, presence: true
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true, length: { in: 1..50 }

  after_save :invalidate_site_cache
  before_save :apply_permissions
  after_create :create_category_definition
  after_create :publish_categories_list
  after_destroy :invalidate_site_cache
  after_destroy :publish_categories_list

end
