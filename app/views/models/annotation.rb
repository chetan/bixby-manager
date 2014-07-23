
module Bixby
  module ApiView
    class Annotation < ::ApiView::Base

      for_model ::Annotation
      attributes :name, :detail, :created_at

      def convert
        super
        self[:tags] = obj.tags
        self
      end

    end
  end
end
