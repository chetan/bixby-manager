
module Bixby
  module ApiView

    class Command < ::ApiView::Base

      for_model ::Command

      def self.convert(obj)

        hash = attrs(obj, :id, :name, :desc, :location, :bundle, :command, :options)
        hash[:repo] = obj.repo.name

        return hash
      end

    end # Command

  end # ApiView
end # Bixby
