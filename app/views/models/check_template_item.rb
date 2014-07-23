
module Bixby
  module ApiView
    class CheckTemplateItem < ::ApiView::Base

      for_model ::CheckTemplateItem
      attributes :id, :check_template_id, :command_id, :args

      def convert
        super
        self[:command] = obj.command
        self
      end

    end
  end
end
