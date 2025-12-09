module Posts::Api::V1
  class UtilitiesController < Api::BaseController
    include Authorization
    before_action :require_user!, only: [:getLocalOnlySetting]

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

    def getLocalOnlySetting
      # Early return if Posts::ServerSetting doesn't exist
      unless Object.const_defined?('Posts::ServerSetting')
        return render json: { local_only: false }, status: :ok
      end

      setting = Posts::ServerSetting.find_by(name: "Local only posts")
      return render json: { local_only: false }, status: :ok if setting.nil?

      render json: { local_only: setting.value }, status: :ok
    end
  end
end
