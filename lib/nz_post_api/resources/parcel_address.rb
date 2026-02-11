# frozen_string_literal: true

module NzPostApi
  module Resources
    class ParcelAddress
      def base_url
        "#{@client.base_url}/parceladdress/2.0/domestic/addresses"
      end

      def initialize(client)
        @client = client
      end

      def search(q:, count: 10)
        response = @client.connection.get(base_url, { q: q, count: count })

        if response.success?
          response.body["addresses"].map { |addr| Objects::Address.new(addr) }
        else
          raise NzPostApi::Error.new(
            "Failed to search addresses: #{response.status} - #{response.body}",
            response_http_code: response.status,
            response_body: response.body
          )
        end
      end
    end
  end
end
