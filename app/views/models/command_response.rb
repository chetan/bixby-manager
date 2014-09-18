
module Bixby
  module ApiView
    class CommandResponse < ::ApiView::Base

      for_model Bixby::CommandResponse
      attributes :status, :stdout, :stderr

      def convert
        super
        self[:log] = render(obj.log)
        self[:log][:user] = if obj.log.user then
          obj.log.user.name || obj.log.user.email
        else
          "system"
        end
        self
      end

    end
  end
end
