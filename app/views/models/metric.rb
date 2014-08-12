
module Bixby
  module ApiView
    class Metric < ::ApiView::Base

      for_model ::Metric
      attributes :id, :check_id, :key, :name, :last_value, :status, :updated_at, :metadata

      def convert
        super

        # attach data
        if obj.data.blank? then
          self[:data] = obj.data
        else
          self[:data] = obj.data.map { |d| { :x => d[:time].to_i, :y => d[:val] } }
        end

        # attach query, if we have one
        if obj.query.blank? then
          self[:query] = {}
        else
          self[:query] = {
            :start      => obj.query[:start].to_i,
            :end        => obj.query[:end].to_i,
            :tags       => obj.query[:tags],
            :downsample => obj.query[:downsample]
          }
        end

        # attach tags
        self[:tags] = {}
        obj.tags.each do |t|
          self[:tags][t.key] = t.value
        end

        # attach metric info
        mi = obj.check.metric_infos.find{ |f| f.metric == self[:key] }
        if not mi.blank? then
          self[:name]  = mi.name
          self[:desc]  = mi.desc
          self[:label] = mi.label
          self[:unit]  = mi.unit
          self[:range] = obj.range || mi.range # use the range attached directly to the metric if avail
          self[:platforms] = mi.platforms
        end

        self
      end

    end
  end
end
