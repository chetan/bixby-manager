
module Bixby
  module ApiView
    class CommandLog < ::ApiView::Base

      for_model ::CommandLog
      attributes :all

      def convert
        super
        self[:command]    = obj.command.name
        self[:user]       = obj.user.nil? ? nil : (obj.user.name || obj.user.email)
        self[:host]       = obj.agent.host.alias || obj.agent.host.hostname
        self
      end

    end
  end
end
