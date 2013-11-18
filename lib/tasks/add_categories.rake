namespace :db do
  namespace :categories do
    desc "Create categories and subcategories."
    task :load => :environment do
      file_name = "#{Rails.root}/tmp/nodes.json"
      nodes = JSON.parse(File.open(file_name, 'r').read())
      categories = nodes['categories']
      subcategories = nodes['subcategories']
      categories.each do |c|
        key = c['key']
        c.delete('key')
        c['user_id'] = -1
        category = Category.create!(c, :without_protection => true)
        subcategories.select{|s| s['category_key'] == key}.each do |s|
          s.delete('category_key')
          s['user_id'] = -1
          category.subcategories.build(s)
        end
        category.save!
        puts "-" * 80
        puts "Created category '#{category.name}'"
        puts "Created subcategories:"
        category.subcategories.each{|s| puts "\t#{s.name}\n"}
        puts "-" * 80 + "\n\n"
      end
    end
  end
end

