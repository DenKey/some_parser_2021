require './models/base'

class Product < ActiveRecord::Base
  has_and_belongs_to_many :images, join_table: "product_images"
  has_and_belongs_to_many :categories, join_table: "product_categories"
end

class Product::Image < ActiveRecord::Base
  belongs_to :product
  belongs_to :image
end

class Product::Category < ActiveRecord::Base
  belongs_to :product
  belongs_to :category
end