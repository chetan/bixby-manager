
require 'helper'

module Bixby
  module Test::Controllers
    class Rest::Models::Checks < TestCase

      tests ::Rest::Models::ChecksController

      def setup
        super
        @user = FactoryGirl.create(:user)
        sign_in @user
        @agent = FactoryGirl.create(:agent)
        @command = FactoryGirl.create(:command)
        change_tenant(@agent.tenant)
      end

      def test_create
        refute Check.all.first
        assert_equal 0, Check.all.size

        post :create, {:host_id => @agent.host.id, :command_id => @command.id}
        assert_response 200

        assert_equal 1, Check.all.size
        c = Check.first
        assert c
        assert_equal @command.id, c.id
      end

      def test_add_check_with_empty_args

        args = {:host_id => @agent.host.id, :command_id => @command.id, :args => {:foo => "bar", :baz => "", :test => nil}}
        post :create, args
        assert_response 200

        ret = Check.first
        assert ret
        assert_kind_of Check, ret

        assert ret.args

        assert_includes ret.args, "foo"
        assert_equal "bar", ret.args["foo"]

        refute_includes ret.args, "baz"
        refute_includes ret.args, "test"
      end

      def test_add_check_with_diff_agent
        agent2 = create_agent_without_validation
        args = {:host_id => @agent.host.id, :command_id => @command.id, :runhost_id => agent2.host.id}
        post :create, args
        assert_response 200

        ret = Check.first

        assert_kind_of Check, ret
        assert_equal @agent.host.id, ret.host_id
        assert_equal agent2.id, ret.agent_id
      end

    end
  end
end
