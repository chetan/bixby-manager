
module Bixby
  class Test::Controllers::TestCase < ::ActionController::TestCase

    def setup
      super
      # common req options
      @request.request_method = "POST"
      @request.env["Content-Type"] = "application/json"
      @request.path = "/api"
      @request.env["action_dispatch.request.formats"] = [ Mime::Type.lookup_by_extension("json") ]
    end

    def teardown
      super
      BIXBY_CONFIG[:crypto] = false
      MultiTenant.current_tenant = nil
    end

    def get(action, *args)
      if args then
        if args.last.kind_of?(Hash) then
          args.last[:format] = "json"
        else
          args << {:format => "json"}
        end
      else
        args = [ {:format => "json"} ]
      end
      super(action, *args)
    end

  end
end

module ActionDispatch
  module Routing
    class RouteSet

      # override to avoid stupid wroute lookup which doesn't work
      def extra_keys(*args)
        {}
      end

    end
  end
end
