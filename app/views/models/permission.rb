
module Bixby
  module ApiView
    class Permission < ::ApiView::Base

      for_model ::UserPermission
      for_model ::RolePermission
      attrs :name, :resource, :resource_id

    end
  end
end
