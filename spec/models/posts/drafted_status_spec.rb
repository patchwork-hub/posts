# frozen_string_literal: true

# rspec ../posts/spec/models/posts/drafted_status_spec.rb
require 'rails_helper'

RSpec.describe Posts::DraftedStatus, type: :model do
  let(:account) { Fabricate(:account) }
  let(:drafted_status) { Fabricate.build(:drafted_status, account: account) }

  describe 'validations' do

    context 'when total limit is exceeded' do

      before do
        Fabricate.times(Posts::DraftedStatus::TOTAL_LIMIT, :drafted_status, account: account)
      end

      it 'is not valid' do
        expect(drafted_status).not_to be_valid
        expect(drafted_status.errors[:base]).to include(I18n.t('scheduled_statuses.over_total_limit', limit: Posts::DraftedStatus::TOTAL_LIMIT))
      end
      
    end

    context 'when daily limit is exceeded' do
      before do
        Fabricate.times(Posts::DraftedStatus::DAILY_LIMIT, :drafted_status, account: account, created_at: Time.current)
      end

      it 'is not valid' do
        expect(drafted_status).not_to be_valid
        expect(drafted_status.errors[:base]).to include(I18n.t('scheduled_statuses.over_daily_limit', limit: Posts::DraftedStatus::DAILY_LIMIT))
      end
    end
  end

  describe 'associations' do
    it "should have many patchwork_drafted_statuses" do
      t = Account.reflect_on_association(:patchwork_drafted_statuses)
      expect(t.macro).to eq(:has_many)
    end

    it "should have many medias" do
      t = Posts::DraftedStatus.reflect_on_association(:media_attachments)
      expect(t.macro).to eq(:has_many)
    end

  end
end