
module Bixby
  module ApiView
    class Host < ::ApiView::Base

      for_model ::Host
      attributes :id, :ip, :hostname, :alias, :desc

      def convert
        super

        self[:org]      = obj.org.name
        self[:tags]     = obj.tag_list.join(",")

        if obj.agent then
          # include a couple of agent attributes
          self[:last_seen_at] = obj.agent.last_seen_at
          self[:is_connected] = obj.agent.is_connected
        end

        self
      end

    end
  end
end
