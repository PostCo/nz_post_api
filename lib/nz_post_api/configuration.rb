# frozen_string_literal: true

module NzPostApi
  class Configuration
    attr_accessor :prod, :client_id, :access_token

    def initialize
      @prod = false
      @client_id = nil
      @access_token = nil
    end

    def base_url
      if @prod
        "https://api.nzpost.co.nz"
      else
        "https://api.uat.nzpost.co.nz"
      end
    end
  end
end
