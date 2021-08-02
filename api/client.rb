require "faraday"
require "faraday_middleware"
require "./api/auth"

module Api
  class Client
    BASE_URL = "https://x0yfzy8wye.execute-api.ap-southeast-2.amazonaws.com/test"

    def initialize
      @client = faraday_client
    end

    attr_reader :client

    def get!(path)
      request do
        client.get do |req|
          req.url(path)
        end
      end
    end

    def delete!(path)
      request do
        client.delete do |req|
          req.url(path)
        end
      end
    end

    def post!(path, payload)
      request do
        client.post do |req|
          req.url(path)
          req.body = payload.to_json
        end
      end
    end

    def put!(path, payload)
      request do
        client.put do |req|
          req.url(path)
          req.body = payload.to_json
        end
      end
    end

    def request
      begin
        response = yield
      rescue Faraday::Error
        Exception.new(message: "Client error")
      end

      if response.success?
        response.body
      else
        raise Exception.new("Server error with status: #{response.status}")
      end
    end

    def faraday_client
      faraday = Faraday.new(url: BASE_URL, headers: headers) do |faraday|
        faraday.request :json
        faraday.response :json, content_type: /\bjson$/, parser_options: { symbolize_names: true }
        faraday.adapter Faraday.default_adapter
      end
      faraday.tap { |conn| conn.authorization(:Bearer, Api::Auth.new.auth_token) }
    end

    def headers
      { content_type: "application/json" }
    end
  end
end