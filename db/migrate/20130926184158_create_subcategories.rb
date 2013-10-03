class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
      t.string :key
      t.string :name
      t.references :category
      t.references :user

      t.timestamps
    end

    add_column :topics, :subcategory_id, :integer
    add_index :topics, :subcategory_id
    add_index :subcategories, :category_id
    add_index :subcategories, :user_id
    add_index :subcategories, :key
  end
end
