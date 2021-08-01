require 'sidekiq'
require 'csv'
require './models/image'
require './models/category'
require './models/product'

class CsvWorker
  include Sidekiq::Worker

  ROOT_CATEGORY = "category_1"

  def perform
    CSV.foreach(csvpath('images'), headers: true, header_converters: :symbol) do |row|
      next if row[:image_name].nil?

      image = Image.create_or_find_by(image_name: row[:image_name]) do |image|
        image.image_url = row[:image_url],
        image.description = row[:description]
      end

      # We update attributes only if we have difference between old and new values.
      image.assign_attributes(image_url: row[:image_url], description: row[:description])
      image.save if image.changed?
    end

    CSV.foreach(csvpath('categories'), headers: true, header_converters: :symbol) do |row|
      next if row[:category_code].nil?

      if row[:category_code] == ROOT_CATEGORY
        create_root_category(row)
        next
      end

      category = Category.create_or_find_by(category_code: row[:category_code]) do |category|
        category.category_name = row[:category_name],
        category.parent_category_code = row[:parent_category_code]
        category.description = row[:description]
      end

      category.assign_attributes(category_attrs(row))
      category.save if category.changed?

      create_relation_category_image(category, row)
    end

    CSV.foreach(csvpath('products'), headers: true, header_converters: :symbol) do |row|
      next if row[:product_code].nil?

      product = Product.create_or_find_by(product_code: row[:product_code]) do |product|
        product.product_name = row[:product_name]
        product.description = row[:description]
        product.status = row[:status]
        product.price = row[:price]
        product.inventory = row[:inventory]
        product.available_time = row[:available_time]
      end

      product.assign_attributes(product_name: row[:product_name],
                                description: row[:description],
                                status: row[:status],
                                price: row[:price],
                                inventory: row[:inventory],
                                available_time: row[:available_time])
      product.save if product.changed?


      create_relation_product_category(product, row)
      create_relation_product_image(product, row)
    end
  end

  private

  def create_root_category(row)
    root_category = Category.find_by(category_code: nil, parent_category_code: nil)

    if root_category.nil?
      Category.create(category_code: nil,
                      category_name: row[:category_name],
                      parent_category_code: nil,
                      description: row[:description])
    else
      # I think we can extract this pattern but for better reading I left it as it is.
      root_category.assign_attributes(category_attrs(row))
      root_category.save if root_category.changed?
    end
  end

  def category_attrs(row)
    {
      category_name: row[:category_name],
      parent_category_code: row[:parent_category_code],
      description: row[:description]
    }
  end

  def create_relation_category_image(category, row)
    # The easiest way to keep relations actual it's recreate it when your create or update main records.
    # Instead of this we can add specific logic to check was changed this images or not.
    Category::Image.where(category_id: category.id).destroy_all

    1.upto(2) do |i|
      if row[:"image_name_#{i}"]
        image = Image.find_by(image_name: row[:"image_name_#{i}"])
        Category::Image.create(image: image, category: category)
      end
    end
  end

  def create_relation_product_category(product, row)
    Product::Category.where(product_id: product.id).destroy_all

    1.upto(2) do |i|
      if row[:"category_code_#{i}"]
        category = Category.find_by(category_code: category_code(i, row))
        Product::Category.create(product: product, category: category)
      end
    end
  end

  def category_code(i, row)
    row[:"category_code_#{i}"] == ROOT_CATEGORY ? nil : row[:"category_code_#{i}"]
  end

  def create_relation_product_image(product, row)
    Product::Image.where(product_id: product.id).destroy_all

    1.upto(3) do |i|
      if row[:"image_name_#{i}"]
        image = Image.find_by(image_name: row[:"image_name_#{i}"])
        Product::Image.create(image: image, product: product)
      end
    end
  end

  def csvpath(filename)
    "./csv_files/#{filename}.csv"
  end
end
