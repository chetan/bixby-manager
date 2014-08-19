
module Bixby
  module ApiView
    class Host < ::ApiView::Base

      for_model ::Host
      attributes :id, :ip, :hostname, :alias, :desc

      def convert
        super

        self[:org]      = obj.org.name
        self[:tags]     = obj.tag_list.join(",")
        self
      end

    end
  end
end
