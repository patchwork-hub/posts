# frozen_string_literal: true

Posts::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      resources :drafted_statuses, only: [:create, :index, :show, :update, :destroy] do
        member do
          post :publish
        end
      end

    end
  end
end

