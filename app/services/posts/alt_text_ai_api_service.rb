module Posts
  class AltTextAiApiService
    require 'httparty'
    require 'json'

    def initialize(options = {})
      @options = options
      @base_url = ENV['ALT_TEXT_URL']
      @api_key =  ENV['ALT_TEXT_SECRET']
      @payload = @options[:payload] if @options.key?(:payload)
    end

    def get_account
      respon = make_get_request('account')
      return respon
    end

    def create_image
      respon = make_post_request('images')
      return respon
    end

    def make_get_request(endpoint)
      base_url = @base_url + endpoint
      headers = {
      'X-API-Key' => @api_key,
      'Content-Type' => 'application/json',
      }
      begin
        response = HTTParty.get(base_url, headers: headers)
        resp_body_obj = Posts::AlttextGetAccount.new(JSON.parse(response.body))
        Rails.logger.info "alttest.ai get account info resp body >> #{resp_body_obj.to_json}"
        return resp_body_obj
      rescue StandardError => e
        Rails.logger.info "Error making GET request: #{e.message}" 
      end
    end

    def make_post_request(endpoint)
      base_url = @base_url + endpoint
      headers = {
      'X-API-Key' => @api_key,
      'Content-Type' => 'application/json',
      }
      begin
        response = HTTParty.post(base_url,
                  body: @payload.to_json, headers: headers)
        resp_body_obj = Posts::AlttextCreateImage.new(JSON.parse(response.body))
        Rails.logger.info "alttest.ai create image resp body >> #{resp_body_obj.to_json}"
        return resp_body_obj
      rescue StandardError => e
        Rails.logger.info "Error making POST request: #{e.message}"
      end
    end
  end
end
  