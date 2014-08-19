
module Bixby
  module ApiView
    class HostWithMetadata < Host

      def convert
        super
        self[:metadata] = render(obj.metadata)
        self
      end

    end
  end
end
