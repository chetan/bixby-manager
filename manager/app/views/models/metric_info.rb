
module Bixby
  module ApiView

    class MetricInfo < ::ApiView::Base

      for_model ::MetricInfo

      def self.convert(obj)
        hash = attrs_except(obj, :command_id)

        return hash
      end

    end # MetricInfo

  end # ApiView
end # Bixby
