
require "active_record"
require "action_controller"
require "active_model"

module MultiTenant

  class AccessException < Exception
  end

  class << self

    # Set the current tenant (thread safe)
    #
    # This will also work whithin Fibers:
    # http://devblog.avdi.org/2012/02/02/ruby-thread-locals-are-also-fiber-local/
    def current_tenant=(tenant)
      Thread.current[:current_tenant] = tenant
    end

    # Retrieve the current thread's tenant
    def current_tenant
      Thread.current[:current_tenant]
    end

    # Sets the current_tenant within the given block
    def with_tenant(tenant, &block)
      if block.nil?
        raise ArgumentError, "block required"
      end

      old_tenant = self.current_tenant
      self.current_tenant = tenant

      block.call

      self.current_tenant = old_tenant
    end
  end

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

        self.after_find do |rec|
          return if rec.nil? or MultiTenant.current_tenant.nil?
          curr_id = MultiTenant.current_tenant.id

          rec_tenant = rec.send(model)
          return if rec_tenant.nil? # if no tenant, then must be globally accessible
          other_id = rec_tenant.id
          if curr_id != other_id then
            # PANIC
            raise AccessException, "illegal access: #{curr_id} != #{other_id}"
          end
        end

      end

    end # ClassMethods
  end # ModelExtensions

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
