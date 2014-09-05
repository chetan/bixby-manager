
module Bixby
  module ApiView
    class Check < ::ApiView::Base

      for_model ::Check
      attributes :all

      def convert
        super
        self[:name]       = obj.command.name
        self[:runhost_id] = obj.agent.host_id
        self[:runhost]    = obj.agent.host
        self[:command]    = render(obj.command)
        self
      end

    end
  end
end
