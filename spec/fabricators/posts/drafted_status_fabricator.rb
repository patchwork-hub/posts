# frozen_string_literal: true

Fabricator(:drafted_status, from: 'Posts::DraftedStatus') do
  account
  created_at { Time.current }
  params { {} }
end
