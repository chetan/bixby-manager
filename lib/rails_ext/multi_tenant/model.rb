
module MultiTenant

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
          MultiTenant.pending_verification << [ rec, model ]
        }

      end # multi_tenant

    end # ClassMethods

  end # ModelExtensions

end
