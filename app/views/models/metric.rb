
module Bixby
  module ApiView

    class Metric < ::ApiView::Base

      for_model ::Metric

      def self.convert(obj)
        hash = attrs(obj, :id, :check_id, :key, :name, :last_value, :status,
          :updated_at, :metadata, :query)

        hash[:data] = ::Metric.for_ui(obj.data)

        # attach metric info
        mi = ::MetricInfo.for(obj.check.command, hash[:key]).first
        if not mi.blank? then
          hash[:desc] = mi.desc
          hash[:unit] = mi.unit
        end

        return hash
      end

    end # Metric

  end # ApiView
end # Bixby
