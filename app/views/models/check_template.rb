
module Bixby
  module ApiView
    class CheckTemplate < ::ApiView::Base

      for_model ::CheckTemplate
      attributes :id, :name, :tags

      def convert
        super
        self[:mode]  = ::CheckTemplate::Mode[obj.mode]
        self[:items] = render(obj.items)
        self
      end

    end
  end
end
