
module Bixby
  module ApiView

    class Metric < ::ApiView::Base

      for_model ::Metric

      def self.convert(obj)
        hash = attrs(obj, :id, :check_id, :key, :name, :last_value, :status,
          :updated_at, :metadata)

        if obj.data.blank? then
          hash[:data] = obj.data
        else
          hash[:data] = obj.data.map { |d| { :x => d[:time].to_i, :y => d[:val] } }
        end

        if obj.query.blank? then
          hash[:query] = {}
        else
          hash[:query] = {
            :start      => obj.query[:start].to_i,
            :end        => obj.query[:end].to_i,
            :tags       => obj.query[:tags],
            :downsample => obj.query[:downsample]
          }
        end

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
