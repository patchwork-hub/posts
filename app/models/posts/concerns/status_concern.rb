# frozen_string_literal: true

module Posts::Concerns::StatusConcern
  extend ActiveSupport::Concern

  included do
    scope :fetch_reblogs, -> { where.not(statuses: { reblog_of_id: nil }) }
    scope :without_original_statuses, -> { where.not(reply: false) }
    scope :without_direct_statuses, -> { where.not(visibility: Status.visibilities[:direct]) }
    scope :without_local_only, -> { where(local_only: [false, nil]) }

    before_create :set_locality

    after_create :boost_posts if ENV['BOOST_POST_ENABLED'].present? && ENV['BOOST_POST_ENABLED'].to_s.downcase == 'true'
  end

  def local_only?
    local_only
  end

  private

  def set_locality
    self.local_only = reblog.local_only if reblog?
  end

  def boost_posts
    if self.local? && !self.reblog? && !self.reply?
      return unless ENV.values_at('BOOST_POST_INSTANCE_URL', 'BOOST_POST_USERNAME', 'BOOST_POST_USER_DOMAIN').all?(&:present?)
      post_url = ActivityPub::TagManager.instance.url_for(self)
      return unless post_url

      BoostPostWorker.perform_async(post_url)
    end
  end
end
