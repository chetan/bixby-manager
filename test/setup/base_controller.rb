
module Bixby
  class Test::Controllers::TestCase < ::ActionController::TestCase

    def setup
      super
      # common req options
      @request.request_method = "POST"
      @request.env["Content-Type"] = "application/json"
      @request.path = "/api"
    end

    def teardown
      super
      BIXBY_CONFIG[:crypto] = false
      MultiTenant.current_tenant = nil
    end

  end
end
