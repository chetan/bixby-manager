
module Bixby
  module ApiView
    class Annotation < ::ApiView::Base

      for_model ::Annotation

      def self.convert(obj)
        hash = attrs(obj, :name, :detail, :created_at)
        hash[:tags] = obj.tags
        return hash
      end

    end # Check
  end # ApiView
end # Bixby
