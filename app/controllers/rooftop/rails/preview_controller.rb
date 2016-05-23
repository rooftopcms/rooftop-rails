class Rooftop::Rails::PreviewController < ActionController::Base
  skip_before_filter :verify_authenticity_token, :only => [:create]

  #this is where we receive a message from Rooftop via a POST
  def create
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
      redirect_to Rooftop::Rails::RouteResolver.new(params[:post_type].to_sym, slug).resolve(preview: session[:preview][:secret])
    else
      raise Rooftop::Content::PreviewKeyMismatchError, "The preview key received doesn't match the key in Rooftop"
    end
  end

  private

  def preview_params
    params.permit!
  end



end