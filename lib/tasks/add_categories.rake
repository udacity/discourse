namespace :db do
  namespace :categories do
    desc "Create categories and subcategories."
    task :load => :environment do
      file_name = "#{Rails.root}/tmp/nodes.json"
      nodes = JSON.parse(File.open(file_name, 'r').read())
      categories = nodes['categories']
      subcategories = nodes['subcategories']
      categories.each do |c|
        category = Category.create!(c)
        subcategories.select{|s| s['category_key'] == category['key']}.each do |s|
          s.delete('category_key')
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