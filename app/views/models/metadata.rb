
module Bixby
  module ApiView
    class Metadata < ::ApiView::Base

      for_model ::Metadata
      attributes :key, :value

      def convert
        super
        self[:source] = obj.source_name()
        self
      end

    end
  end
end
