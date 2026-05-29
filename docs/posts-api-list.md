# Posts API Inventory

Source: Rails engine routes from `config/routes.rb`.

The engine mounts at `/`, so the full request paths below are the engine routes as exposed by the host app.

| Method | Path | Controller#Action | Auth | Common params |
| --- | --- | --- | --- | --- |
| POST | `/api/v1/drafted_statuses` | `Posts::Api::V1::DraftedStatusesController#create` | Required | Body: `status`, `in_reply_to_id`, `sensitive`, `spoiler_text`, `visibility`, `language`, `scheduled_at`, `is_only_for_followers`, `is_meta_preview`, `text_count`, `drafted`, `allowed_mentions[]`, `media_ids[]`, `media_attributes[]`, `community_ids[]`, `poll` |
| GET | `/api/v1/drafted_statuses` | `Posts::Api::V1::DraftedStatusesController#index` | Required | Query: `limit`, `max_id`, `since_id`, `min_id` |
| GET | `/api/v1/drafted_statuses/:id` | `Posts::Api::V1::DraftedStatusesController#show` | Required | Path: `id` |
| PATCH | `/api/v1/drafted_statuses/:id` | `Posts::Api::V1::DraftedStatusesController#update` | Required | Path: `id`; Body: same as create |
| PUT | `/api/v1/drafted_statuses/:id` | `Posts::Api::V1::DraftedStatusesController#update` | Required | Path: `id`; Body: same as create |
| DELETE | `/api/v1/drafted_statuses/:id` | `Posts::Api::V1::DraftedStatusesController#destroy` | Required | Path: `id` |
| POST | `/api/v1/drafted_statuses/:id/publish` | `Posts::Api::V1::DraftedStatusesController#publish` | Required | Path: `id`; Body: same as create |
| GET | `/api/v1/utilities/link_preview` | `Posts::Api::V1::UtilitiesController#link_preview` | Public | Query: `url` |
| POST | `/api/v1/patchwork/relays` | `Posts::Api::V1::RelaysController#create` | Required | Body: `inbox_url` |
| DELETE | `/api/v1/patchwork/relays/:id` | `Posts::Api::V1::RelaysController#destroy` | Required | Path: `id` |
| POST | `/api/v1/ghost_webhooks` | `Posts::Api::V1::WebhooksController#handle_ghost` | Public | Body: Ghost webhook payload with `post.current.title` and `post.current.id`; signature header: `X-Ghost-Signature` |
| POST | `/api/v1/wordpress_webhooks` | `Posts::Api::V1::WebhooksController#handle_wordpress` | Public | Body: WordPress webhook payload with `post.post_title` and `post_id`; query/body auth token: `auth_token` |

## Notes

- Authenticated endpoints use Bearer token auth in Postman.
- Public endpoints override auth to `noauth` in Postman.
- Drafted status create/update/publish all share the same permitted body fields from `drafted_status_params`.
- The webhook endpoints are public at the HTTP auth layer, but each one enforces its own request verification.
