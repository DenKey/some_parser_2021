require "faraday"
require "faraday_middleware"
require "json"

module Api
  class Auth
    AUTH_URL = "https://au-dev-idp.auth.ap-southeast-2.amazoncognito.com/oauth2/token"

    def initialize
      @client = Faraday.new
    end

    attr_reader :client

    def auth_token
      response = client.post AUTH_URL, payload
      JSON.parse(response.body, symbolize_names: true)[:access_token]
    end

    def payload
      {
        grant_type: :client_credentials,
        # Of course this must keep in ENV
        client_id: "2q3tl0eu4kpcd2r77p9avikumu",
        client_secret: "1voennaunvq5s878qouj84fbuflpqka8r0d5it7t66f32bknoqt8"
      }
    end
  end
end