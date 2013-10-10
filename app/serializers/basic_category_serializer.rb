class BasicCategorySerializer < ApplicationSerializer

  attributes :id,
             :name,
             :color,
             :text_color,
             :slug,
             :topic_count,
             :description,
             :topic_url,
             :hotness,
             :read_restricted,
             :permission,
             :subcategories

  def subcategories
    object.subcategories.map { |s| {id: s.id, name: s.name} }
  end
end
