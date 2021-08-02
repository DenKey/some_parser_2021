require 'sidekiq'
require 'csv'
require './api/service'
require './models/image'
require './models/category'
require './models/product'
require 'logger'


class ApiWorker
  include Sidekiq::Worker

  def perform
    logger = Logger.new(STDOUT)
    service = Api::Service.new
    products = Product.all

    # API doesn't have a source that provide the availability to check which products
    # already created. So I don't know exactly what needed to create or update.
    active_products = products.filter { |p| p.status }
    non_active_products = products.filter { |p| !p.status }

    active_products.each do |product|
      service.product_create(product)
    end

    non_active_products.each do |product|
      service.product_delete(product.id)
    end
  rescue => e
    logger.info "Woops =( Something went wrong."
    logger.info e.message
  end
end
