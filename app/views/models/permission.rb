
module Bixby
  module ApiView

    class Permission < ::ApiView::Base

      for_model ::UserPermission
      for_model ::RolePermission

      def self.convert(obj)
        attrs(obj, :name, :resource, :resource_id)
      end

    end # Permission

  end # ApiView
end # Bixby
