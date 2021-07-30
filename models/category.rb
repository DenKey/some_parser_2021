require './base'

class Category < ActiveRecord::Base
  has_and_belongs_to_many :images, join_table: "category_images"
end

class Category::Image < ActiveRecord::Base
  belongs_to :category
  belongs_to :image
end