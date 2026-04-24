# frozen_string_literal: true
module Posts
  class ArticleNotificationService < BaseService
    include NonChannelHelper

    def call(article_data)
      tokens_table = Posts::NotificationToken.table_name
      settings_table = Posts::PatchworkSetting.table_name
      @notification_tokens = Posts::NotificationToken
        .joins("INNER JOIN #{settings_table} ON #{settings_table}.account_id = #{tokens_table}.account_id")
        .where("#{settings_table}.settings ->> 'article_notifications' = ?", "true")
        .select("#{tokens_table}.*")

      app_title = ENV['ARTICLE_NOTIFICATION_SENDER_NAME'] || 'Development Patchwork'
      body = article_data['title'].truncate_words(8)
      data = {
        noti_type: 'ghost_articles',
        article_id: article_data['article_id'],
      }

      # for ios & android
      @notification_tokens.where.not(platform_type: 'huawei').find_each do |token_record|
        Posts::FirebaseNotificationService.send_notification(token_record.notification_token, app_title, body, data)
      end
    end
  end
end
