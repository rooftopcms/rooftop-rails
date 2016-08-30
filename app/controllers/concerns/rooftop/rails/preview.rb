module Rooftop
  module Rails
    # A controller mixin with utility methods for handling previews. This presupposes you're using the mounted Rooftop::Rails::PreviewController to receive POST requests for previews from Rooftop.
    module Preview

      def self.included(base)
        base.send(:before_action, -> {
          if preview?
            Rooftop.include_drafts = true
          else
            Rooftop.include_drafts = false
          end

        })
      end

      def preview?
        params[:preview].present? && session[:preview].present? && params[:preview] == session[:preview]["secret"]
      end
    end
  end
end


