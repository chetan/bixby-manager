
module Bixby
  module ApiView

    class Trigger < ::ApiView::Base

      for_model ::Trigger

      def self.convert(obj)

        hash = attrs(obj, :all)
        hash[:metric] = obj.metric
        hash[:check] = obj.check

        return hash
      end

    end # Trigger

  end # ApiView
end # Bixby
