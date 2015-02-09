
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

    # Patch process method to always add json format
    def process(action, verb, *args)
      if args then
        if args.last.kind_of?(Hash) then
          args.last[:format] = "json"
        else
          args << {:format => "json"}
        end
      else
        args = [ {:format => "json"} ]
      end
      ret = super(action, verb, *args)
      # puts @response.body
      ret
    end

    def change_tenant(tenant)
      @user.org_id = tenant.orgs.first.id
      @user.save
      @user = ::User.find(@user.id)
      # couldn't get sign_in/sign_out to work so just stub it out
      @controller.expects(:current_user).returns(@user).at_least_once
    end

    def sign_in(user)
      session[:current_user] = user.id
      @current_user = user
    end

    def sign_with_agent
      @agent = FactoryGirl.create(:agent)
      @host = Host.first
      BIXBY_CONFIG[:crypto] = true
      ApiAuth.sign!(@request, @agent.access_key, @agent.secret_key)
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
