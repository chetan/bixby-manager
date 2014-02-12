
module Bixby
  module ApiView

    class CheckTemplateItem < ::ApiView::Base

      for_model ::CheckTemplateItem

      def self.convert(obj)
        hash = attrs(obj, :id, :check_template_id, :command_id, :args)
        hash[:command] = obj.command
        return hash
      end

    end # CheckTemplateItem

  end # ApiView
end # Bixby
