
module Bixby
  module ApiView

    class Metric < ::ApiView::Base

      for_model ::Metric

      def self.convert(obj)

        # get basic attrs
        hash = attrs(obj, :id, :check_id, :key, :name, :last_value, :status,
          :updated_at, :metadata)

        # attach data
        if obj.data.blank? then
          hash[:data] = obj.data
        else
          hash[:data] = obj.data.map { |d| { :x => d[:time].to_i, :y => d[:val] } }
        end

        # attach query, if we have one
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

        # attach tags
        hash[:tags] = {}
        obj.tags.each do |t|
          hash[:tags][t.key] = t.value
        end

        # attach metric info
        mi = ::MetricInfo.for(obj.check.command, hash[:key]).first
        if not mi.blank? then
          hash[:name]  = mi.name
          hash[:desc]  = mi.desc
          hash[:label] = mi.label
          hash[:unit]  = mi.unit
          hash[:range] = mi.range
          hash[:platforms] = mi.platforms
        end

        return hash
      end

    end # Metric

  end # ApiView
end # Bixby
