require './api/client'
require './models/product'
require './models/image'
require './models/category'
require 'logger'

module Api
  class Service

    def initialize
      @client = Api::Client.new
      @logger = Logger.new(STDOUT)
    end

    attr_accessor :client, :logger

    def product_create(product)
      payload = {
        name: product.product_name,
        description: product.description,
        price: product.price,
        inventory: product.inventory,
        categories: categories_list(product),
        images: images_urls(product),
      }

      response = client.post!("catalogs/product", payload)
      external_id = response[:id]
      if external_id
        product.external_id = external_id
        product.save
      end
      logger.info response # just like a some simple view of result
    end

    def product_update(product)
      payload = {
        id: product.external_id,
        name: product.product_name,
        description: product.description,
        price: product.price,
        inventory: product.inventory,
        categories: categories_list(product),
        images: images_urls(product),
      }

      response = client.put!("catalogs/product", payload)
      logger.info response
    end

    def product_delete(product_id)
      response = client.delete!("catalogs/product/#{product_id}")
      logger.info response
    end

    private

    # This shameful code here because associations between Sqlite3 and
    # active_record doesn't work for me.
    # I don't know why but I stuck with this problem and more than half of
    # development time i spent on this.
    # Just a quick fix in the middle of night
    def images_urls(product)
      images_ids = Product::Image.where(product_id: product.id).pluck(:image_id)
      Image.where(id: images_ids).pluck(:image_url)
    end

    def categories_list(product)
      parent = Category.find_by(category_code: nil)
      category_ids = Product::Category.where(product_id: product.id).pluck(:category_id)
      Category.where(id: category_ids).map do |category|
        if category.category_code
          "#{parent.category_name}:#{category.category_name}"
        else
          parent.category_name
        end
      end
    end
  end
end