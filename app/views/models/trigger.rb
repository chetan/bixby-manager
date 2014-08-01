
module Bixby
  module ApiView
    class Trigger < ::ApiView::Base

      for_model ::Trigger
      attrs :all

      def convert
        super
        self[:metric] = obj.metric
        self[:check]  = obj.check
        self
      end

    end
  end
end
