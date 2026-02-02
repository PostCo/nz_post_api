# frozen_string_literal: true

module NzPostApi
  module Resources
    class ShippingOption
      BASE_URL = "https://api.uat.nzpost.co.nz/shippingoptions/2.0/domestic"

      def initialize(client)
        @client = client
      end

      def list(params = {})
        response = @client.connection.get(BASE_URL, params)

        if response.success?
          Objects::ShippingOption.new(response.body)
        else
          raise NzPostApi::Error, "Failed to list options: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
