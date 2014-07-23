
module Bixby
  module ApiView
    class MetricInfo < ::ApiView::Base

      for_model ::MetricInfo
      attributes :except => :command_id

    end
  end
end
