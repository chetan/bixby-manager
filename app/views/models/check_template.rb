
module Bixby
  module ApiView

    class CheckTemplate < ::ApiView::Base

      for_model ::CheckTemplate

      def self.convert(obj)

        hash = attrs(obj, :id, :name, :tags)
        hash[:mode] = ::CheckTemplate::Mode[obj.mode]
        hash[:items] = render(obj.items)

        return hash
      end

    end # CheckTemplate

  end # ApiView
end # Bixby
