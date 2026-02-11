# frozen_string_literal: true

require_relative "nz_post_api/version"
require_relative "nz_post_api/objects/base"
require_relative "nz_post_api/objects/address"
require_relative "nz_post_api/objects/label"
require_relative "nz_post_api/objects/shipping_option"
require_relative "nz_post_api/objects/parcel_track"
require_relative "nz_post_api/objects/parcel_track_subscription"
require_relative "nz_post_api/auth"
require_relative "nz_post_api/client"
require_relative "nz_post_api/resources/parcel_address"
require_relative "nz_post_api/resources/parcel_label"
require_relative "nz_post_api/resources/shipping_option"
require_relative "nz_post_api/resources/parcel_track"

module NzPostApi
  class Error < StandardError
    attr_reader :response_http_code, :response_body

    def initialize(message = nil, response_http_code: nil, response_body: nil)
      @response_http_code = response_http_code
      @response_body = response_body
      super(message)
    end
  end
end
