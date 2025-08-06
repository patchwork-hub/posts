module Posts::Api::V1
  class UtilitiesController < Api::BaseController
    def link_preview
      url = params[:url]
      unless url.present?
        return render json: { error: 'URL must be present' }, status: :bad_request
      end

      begin
        data = LinkThumbnailer.generate(url)
        render json: data, status: :ok
      rescue LinkThumbnailer::Exceptions => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
