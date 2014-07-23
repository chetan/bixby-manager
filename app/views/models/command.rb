
module Bixby
  module ApiView
    class Command < ::ApiView::Base

      for_model ::Command
      attributes :id, :name, :desc, :location, :bundle, :command, :options

      def convert
        super
        self[:repo] = obj.repo.name
        self
      end

    end
  end
end
