module Posts::Api::V1
  class WebhooksController < Api::BaseController
    before_action :authenticate_ghost_request!, only: [:handle_ghost]

    # manage Ghost webhook
    def handle_ghost
      ghost_post_articles = params[:post]
      if ghost_post_articles.present?
        ghost_post_data = {
          'title' => ghost_post_articles[:current][:title],
          'article_id' => ghost_post_articles[:current][:id].to_s,
        }
        GhostNotificationWorker.perform_async(ghost_post_data)
        render json: { message: "Webhook received" }, status: :ok
      else
        render json: { error: "No post data found" }, status: :unprocessable_entity
      end
    rescue => e
      render json: { errors: e.message }, status: :internal_server_error
    end

    private

    def authenticate_ghost_request!
      sig_header = request.headers['HTTP_X_GHOST_SIGNATURE']
      if sig_header.blank?
        render json: { error: 'Missing Signature' }, status: :unauthorized
        return
      end

      # Parse signature and timestamp
      # Format: "sha256=hash, t=12345"
      parts = sig_header.split(', ').map { |p| p.split('=') }.to_h
      received_hash = parts['sha256']
      timestamp = parts['t']

      # Extract Raw Body
      request.body.rewind
      raw_body = request.body.read
      request.body.rewind # Reset for Rails params usage

      # Verify HMAC (Ghost format: body + timestamp)
      secret = ENV['GHOST_WEBHOOK_SECRET']
      if secret.blank?
        raise "GHOST_WEBHOOK_SECRET environment variable is missing"
      end
      data_to_sign = "#{raw_body}#{timestamp}"
      expected_hash = OpenSSL::HMAC.hexdigest('sha256', secret, data_to_sign)

      # Compare
      unless ActiveSupport::SecurityUtils.secure_compare(expected_hash, received_hash)
        render json: { error: 'Invalid Signature' }, status: :unauthorized
      end
    rescue => e
      Rails.logger.error "Error processing : #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { errors: e.message }, status: :internal_server_error
    end
  end
end
