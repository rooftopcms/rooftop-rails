module Rooftop
  module Rails
    module PreviewModel
      include ActiveSupport::Concern

      # Call the preview() method defined in Rooftop, but expire the cache afterwards
      def preview
        # super here is defined in Rooftop::Preview#preview()
        preview = super
        # expire is defined in Rooftop::Rails::ObjectCache#expire!
        preview.expire!
        return preview
      end
    end
  end
end