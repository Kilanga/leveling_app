class AddDefaultCategories < ActiveRecord::Migration[7.0]
  def up
    %w[Force Agilité Perception Intelligence Vitalité].each do |cat|
      Category.create(name: cat)
    end
  end

  def down
    Category.delete_all
  end
end
