# frozen_string_literal: true

Posts::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do

      resources :drafted_statuses, only: [:create, :index, :show, :update, :destroy] do
        member do
          post :publish
        end
      end

      resources :utilities, only: [] do
        collection do
          get :link_preview
        end
      end

      post 'patchwork/relays', to: 'relays#create'
      delete 'patchwork/relays/:id', to: 'relays#destroy'

      post 'ghost_webhooks', to: 'webhooks#handle_ghost'

    end
  end
end
