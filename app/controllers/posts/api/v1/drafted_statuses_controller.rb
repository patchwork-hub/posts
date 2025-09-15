# frozen_string_literal: true

module Posts::Api::V1
  class DraftedStatusesController < Api::BaseController
    include Authorization
    before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, except: [:update, :destroy, :publish]
    before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: [:create, :update, :destroy, :publish]
    
    before_action :require_user!
    before_action :set_statuses, only: :index
    before_action :set_status, except: [:index, :create]
    before_action :set_thread, only: [:create]

    after_action :insert_pagination_headers, only: :index

    def create 
      @status = post_status_service
  
      render json: @status, serializer: LongPost::DraftedStatusSerializer
    rescue PostStatusService::UnexpectedMentionsError => e
      unexpected_accounts = ActiveModel::Serializer::CollectionSerializer.new(
        e.accounts,
        serializer: REST::AccountSerializer
      )
      render json: { error: e.message, unexpected_accounts: unexpected_accounts }, status: 422
    end

    def index
      render json: render_custom_grouped_dates
    end

    def show
      render json: @status, serializer: LongPost::DraftedStatusSerializer
    end

    def update 
      @status.destroy!
      @status = post_status_service
  
      render json: @status, serializer: LongPost::DraftedStatusSerializer
    rescue PostStatusService::UnexpectedMentionsError => e
      unexpected_accounts = ActiveModel::Serializer::CollectionSerializer.new(
        e.accounts,
        serializer: REST::AccountSerializer
      )
      render json: { error: e.message, unexpected_accounts: unexpected_accounts }, status: 422
    end

    def destroy
      @status.destroy!
      render_empty
    end

    def publish
      @status.destroy!

      @status = post_status_service(is_draft: false)
      
      render json: @status, serializer: @status.is_a?(ScheduledStatus) ? REST::ScheduledStatusSerializer : REST::StatusSerializer
    rescue PostStatusService::UnexpectedMentionsError => e
    unexpected_accounts = ActiveModel::Serializer::CollectionSerializer.new(
      e.accounts,
      serializer: REST::AccountSerializer
    )
    render json: { error: e.message, unexpected_accounts: unexpected_accounts }, status: 422
    end

    private

    def render_custom_grouped_dates
      drafted_statuses = @statuses.group_by { |status| status.created_at.to_date }
      drafted_statuses.map do |date, statuses|
        {
          date: date,
          datas: statuses.map { |status| LongPost::DraftedStatusSerializer.new(status) },
        }
      end
    end

    def set_statuses
      @statuses = current_account.patchwork_drafted_statuses.to_a_paginated_by_id(limit_param(DEFAULT_STATUSES_LIMIT), params_slice(:max_id, :since_id, :min_id))
    end

    def set_thread
      @thread = Status.find(drafted_status_params[:in_reply_to_id]) if drafted_status_params[:in_reply_to_id].present?
      authorize(@thread, :show?) if @thread.present?
    rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
      render json: { error: I18n.t('statuses.errors.in_reply_not_found') }, status: 404
    end

    def set_status
      @status = current_account.patchwork_drafted_statuses.find(params[:id])
    end

    def drafted_status_params
      params.permit(
        :status,
        :in_reply_to_id,
        :sensitive,
        :spoiler_text,
        :visibility,
        :language,
        :scheduled_at,
        :is_only_for_followers,
        :is_meta_preview,
        :text_count,
        :drafted,
        allowed_mentions: [],
        media_ids: [],
        media_attributes: [
          :id,
          :thumbnail,
          :description,
          :sensitive,
          :focus,
        ],
        community_ids: [],
        poll: [
          :multiple,
          :hide_totals,
          :expires_in,
          options: [],
        ]
      )
    end

    def pagination_params(core_params)
      params.slice(:limit).permit(:limit).merge(core_params)
    end

    def insert_pagination_headers
      set_pagination_headers(next_path, prev_path)
    end

    def next_path
      api_v1_drafted_statuses_url pagination_params(max_id: pagination_max_id) if records_continue?
    end

    def prev_path
      api_v1_drafted_statuses_url pagination_params(min_id: pagination_since_id) unless @statuses.empty?
    end

    def records_continue?
      @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    end

    def pagination_max_id
      @statuses.last.id
    end

    def pagination_since_id
      @statuses.first.id
    end

    def options_with_objects(options)
      options.tap do |options_hash|
        options_hash[:application] = Doorkeeper::Application.find(options_hash.delete(:application_id)) if options[:application_id]
        options_hash[:thread]      = Status.find(options_hash.delete(:in_reply_to_id)) if options_hash[:in_reply_to_id]
      end
    end

    def post_status_service(is_draft: true)

      PostStatusService.new.call(
        current_user.account,
        text: drafted_status_params[:status],
        thread: @thread,
        media_ids: drafted_status_params[:media_ids],
        sensitive: drafted_status_params[:sensitive],
        spoiler_text: drafted_status_params[:spoiler_text],
        visibility: drafted_status_params[:visibility],
        language: drafted_status_params[:language],
        community_ids: drafted_status_params[:community_ids],
        scheduled_at: drafted_status_params[:scheduled_at],
        drafted: is_draft,
        is_only_for_followers: drafted_status_params.include?(:is_only_for_followers) ? drafted_status_params[:is_only_for_followers] : true,
        is_meta_preview: drafted_status_params.include?(:is_meta_preview)? drafted_status_params[:is_meta_preview] : false,
        application: doorkeeper_token.application,
        poll: drafted_status_params[:poll],
        allowed_mentions: drafted_status_params[:allowed_mentions],
        idempotency: request.headers['Idempotency-Key'],
        with_rate_limit: true,
        text_count: drafted_status_params[:text_count],
        is_rss_content: false
      )
    end

  end
end
