
module Bixby
  module ApiView
    class CommandLog < ::ApiView::Base

      for_model ::CommandLog
      attributes :all

      def convert
        super
        self[:command] = obj.command.name

        self[:user] = if obj.user then
          obj.user.name || obj.user.email
        else
          nil
        end

        self[:host] = if obj.agent && obj.agent.host
          obj.agent.host.alias || obj.agent.host.hostname
        else
          nil
        end

        self
      end

    end
  end
end
