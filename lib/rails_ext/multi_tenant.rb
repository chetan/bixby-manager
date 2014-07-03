
require "active_record"
require "action_controller"
require "active_model"

require "request_store"


# Super simple multi-tenant access controls
module MultiTenant

  class AccessException < Exception
  end

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

  # Included into ActiveRecord::Base, this is where security checks occur
  module ModelExtensions
    extend ActiveSupport::Concern
    module ClassMethods

      # Mark the model as being part of a multi-tenant system. Enforces
      # the tenant security model.
      def multi_tenant(opts={})

        model = (opts.delete(:model) || :tenant).to_sym

        if opts.include? :via then
          define_method model do
            via = self.send(opts[:via])
            return nil if via.nil?
            return via.send(model)
          end

        elsif respond_to? model or reflect_on_all_associations(:belongs_to).find{ |a| a.name == model } then
          # just use the current accessor

        else
          raise "don't know how to locate #{model}"

        end

        self.after_find lambda { |rec|
          return if rec.nil? or MultiTenant.current_tenant.nil?
          curr_id = MultiTenant.current_tenant.id

          multi_tenant_incr()

          rec_tenant = rec.send(model)
          if rec_tenant.nil? then
            # if no tenant, then must be globally accessible
            multi_tenant_decr()
            return
          end

          other_id = rec_tenant.id
          if curr_id != other_id then
            # PANIC
            multi_tenant_reset()
            raise AccessException, "illegal access: tried to access tenant.id=#{other_id}; current_tenant.id=#{curr_id}"
          end
          multi_tenant_decr()
        }

      end # multi_tenant

    end # ClassMethods

    def multi_tenant_logger
      Logging.logger[ActiveRecord::Base]
    end

    def multi_tenant_incr
      return if !multi_tenant_logger.debug?
      RequestStore[:multi_tenant_verify] ||= 0
      if (RequestStore[:multi_tenant_verify] += 1) == 1 then
        multi_tenant_logger.debug { "MULTI_TENANT CHECK {" }
      end
    end

    def multi_tenant_reset
      return if !multi_tenant_logger.debug?
      RequestStore[:multi_tenant_verify] = 0
    end

    def multi_tenant_decr
      return if !multi_tenant_logger.debug?
      if (RequestStore[:multi_tenant_verify] -= 1) <= 0 then
        multi_tenant_logger.debug { "} # MULTI_TENANT OK" }
      end
    end

  end # ModelExtensions

  # Included into ActionController::Base to allow easy access to the
  # current_tenant
  module ControllerExtensions
    def multi_tenant
      self.class_eval do
        helper_method :current_tenant
        after_filter :clear_current_tenant

        private

        # helper method to have the current_tenant available in the controller
        def current_tenant
          MultiTenant.current_tenant
        end

        # Clear current tenant after the request is completed
        def clear_current_tenant
          MultiTenant.current_tenant = nil
        end
      end
    end
  end

end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, MultiTenant::ModelExtensions)
  ActionController::Base.extend MultiTenant::ControllerExtensions
end
