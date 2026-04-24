class ArticleNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: false, dead: true

  def perform(article_data)
    Posts::ArticleNotificationService.new.call(article_data)
  rescue => e
    Rails.logger.error "[ArticleNotificationWorker] Error processing : #{e.message}\n#{e.backtrace.join("\n")}"
    { status: :error, error: e.message }
  end
end
