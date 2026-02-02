# frozen_string_literal: true

require "faraday"
require "json"

module NzPostApi
  class Auth
    TOKEN_URL = "https://oauth.nzpost.co.nz/as/token.oauth2"

    def self.fetch_token(client_id, client_secret)
      response = Faraday.post(TOKEN_URL, {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: "client_credentials"
      })

      if response.success?
        JSON.parse(response.body)
      else
        raise NzPostApi::Error, "Failed to fetch token: #{response.status} - #{response.body}"
      end
    end
  end
end
