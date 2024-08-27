# frozen_string_literal: true

#rspec ../posts/spec/requests/posts/api/v1/drafted_statuses_controller_spec.rb
require 'rails_helper'

RSpec.describe 'Posts::Api::V1::DraftedStatuses', type: :request do

  let(:user) { Fabricate(:user) }
  let(:scopes)  { 'write read' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:params) do 
    {
      in_reply_to_id: nil,
      language: "en",
      media_ids: [],
      community_ids: [],
      poll: nil,
      sensitive: false,
      spoiler_text: "",
      status: Faker::Lorem.paragraph,
      drafted: true,
      visibility: "public"
    }
  end

  let(:drafted_status) { Fabricate(:drafted_status, account: user.account, params: params) }


  describe "GET /api/v1/drafted_statuses" do
    subject do
      get "/api/v1/drafted_statuses", headers: headers
    end
    it "renders a successful response" do
      subject
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/drafted_statuses/:id" do
    subject do
      get "/api/v1/drafted_statuses/#{drafted_status.id}", headers: headers
    end

    it "renders a successful response" do 
      subject
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /api/v1/drafted_statuses/" do
    subject do
      post "/api/v1/drafted_statuses", headers: headers, params: params
    end

    it "renders a successful response" do 
      subject
      expect(response).to have_http_status(200)
    end
  end

  describe "PUT /api/v1/drafted_statuses/:id" do

    subject do
      patch "/api/v1/drafted_statuses/#{drafted_status.id}", headers: headers, params: params
    end

    it "renders a successful response" do 
      subject
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /api/v1/drafted_statuses/:id/publish" do

    subject do
      post "/api/v1/drafted_statuses/#{drafted_status.id}/publish", headers: headers, params: params
    end

    it "renders a successful response" do 
      subject
      expect(response).to have_http_status(200)
    end
  end

  describe "DELETE /api/v1/drafted_statuses/:id" do

    subject do
      delete "/api/v1/drafted_statuses/#{drafted_status.id}", headers: headers
    end

    it "renders a successful response" do 
      subject
      expect(response).to have_http_status(200)
    end
  end

end
