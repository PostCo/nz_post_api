# frozen_string_literal: true

module NzPostApi
  class Configuration
    attr_accessor :prod

    def initialize
      @prod = false
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
