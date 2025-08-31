class BoostPostWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

  def perform(post_url)
    Rails.logger.info "[BoostPostWorker] Start processing: #{post_url}"
    Posts::BoostPostService.new(post_url).call
  rescue => e
    Rails.logger.error "[BoostPostWorker] Error processing #{post_url}: #{e.class} - #{e.message}"
    { status: :error, error: e.message }
  end
end
