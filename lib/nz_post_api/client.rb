# frozen_string_literal: true

require "faraday"

module NzPostApi
  class Client
    def initialize
    end

    def client_id
      NzPostApi.configuration.client_id
    end

    def access_token
      NzPostApi.configuration.access_token
    end

    def connection
      @connection ||= Faraday.new do |f|
        f.request :json
        f.response :json
        f.headers["client_id"] = client_id
        f.headers["Authorization"] = "Bearer #{access_token}"
        f.headers["Content-Type"] = "application/json"
      end
    end

    def parcel_address
      Resources::ParcelAddress.new(self)
    end

    def parcel_label
      Resources::ParcelLabel.new(self)
    end

    def shipping_options
      Resources::ShippingOption.new(self)
    end

    def parcel_track
      Resources::ParcelTrack.new(self)
    end
  end
end
