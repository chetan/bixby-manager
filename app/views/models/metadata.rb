
module Bixby
  module ApiView

    class Metadata < ::ApiView::Base

      for_model ::Metadata

      def self.convert(obj)

        hash = attrs(obj, :key, :value)
        hash[:source] = obj.source_name()

        return hash
      end

    end # Metadata

  end # ApiView
end # Bixby
