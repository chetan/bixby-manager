
require "active_record"
require "action_controller"
require "active_model"

require "request_store"

require "rails_ext/multi_tenant/exception"
require "rails_ext/multi_tenant/model"
require "rails_ext/multi_tenant/controller"


# Super simple multi-tenant access controls
module MultiTenant

  class << self

    # Set the current tenant (thread safe)
    #
    # This will also work whithin Fibers:
    # http://devblog.avdi.org/2012/02/02/ruby-thread-locals-are-also-fiber-local/
    def current_tenant=(tenant)
      RequestStore.store[:current_tenant] = tenant
    end

    # Retrieve the current thread's tenant
    def current_tenant
      RequestStore.store[:current_tenant]
    end

    # Sets the current_tenant within the given block. Useful for temporarily
    # changing tenants (for tests, god mode, etc).
    #
    # @param [Tenant] tenant
    # @param [Block] block
    #
    # @return [Object] result of the given block, if any
    #
    #
    # NOTE: when using this method, you must make sure all accesses to objects happen within
    #       the given block. for example, instead of this:
    #
    #       users = MultiTenant.with(nil){ User.all }
    #       do this:
    #       users = MultiTenant.with(nil){ User.all.to_a }
    #       or even better:
    #       MultiTenant.with(nil){ bootstrap User.all, :type => User }
    #
    def with_tenant(tenant, &block)
      if block.nil? then
        raise ArgumentError, "block required"
      end

      old_tenant = self.current_tenant
      self.current_tenant = tenant

      begin
        ret = block.call
      rescue Exception => ex
        # in case of exception, reset and reraise
        self.current_tenant = old_tenant
        raise ex
      end

      # reset and return
      self.current_tenant = old_tenant
      return ret
    end
    alias_method :with, :with_tenant

  end

end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, MultiTenant::ModelExtensions)
  ActionController::Base.extend MultiTenant::ControllerExtensions
end
