# frozen_string_literal: true

module NzPostApi
  module Resources
    class ShippingOption
      def base_url
        "#{@client.base_url}/shippingoptions/2.0/domestic"
      end

      def initialize(client)
        @client = client
      end

      def list(params = {})
        response = @client.connection.get(base_url, params)

        if response.success?
          Objects::ShippingOption.new(response.body)
        else
          raise NzPostApi::Error, "Failed to list options: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
