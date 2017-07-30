class Rooftop::Rails::PreviewController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]

  #this is where we receive a message from Rooftop via a POST
  def create
    raise Rooftop::Content::PreviewKeyMissingError, "You need to POST a preview key" unless params[:preview_key].present?
    session.delete(:preview)
    # Rooftop will POST data to this endpoint
    Rooftop.include_drafts = true

    request.format = :json
    session[:preview] = {
      secret: Digest::SHA256.hexdigest(params[:preview_key]),
      key: params[:preview_key]
    }
    item = Rooftop::Rails::PostTypeResolver.new(params[:post_type]).resolve.find(params[:id])
    slug = item.respond_to?(:nested_path) ? item.nested_path : item.slug
    if item.preview_key_matches?(params[:preview_key])
      redirect_path = Rooftop::Rails::RouteResolver.new(params[:post_type].to_sym, slug).resolve(preview: session[:preview][:secret])
      if redirect_path.nil?
        raise ActionController::RoutingError, "Couldn't find a route to preview this post type"
      else
        redirect_to redirect_path
      end
    else
      raise Rooftop::Content::PreviewKeyMismatchError, "The preview key received doesn't match the key in Rooftop"
    end
  end

  private

  def preview_params
    params.permit!
  end



end