# Posts

A comprehensive Ruby on Rails plugin that enhances Mastodon's posting capabilities with advanced features including customizable character limits, draft management, quote posts, automatic ALT text generation, community management, and relay support.

This gem extends Mastodon's core posting functionality by providing enhanced media handling, flexible post management, automated content enhancement, and advanced filtering capabilities. It integrates seamlessly with the Patchwork Dashboard to provide a complete content management solution for Mastodon instances.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'posts', git: 'https://github.com/patchwork-hub/posts.git'
```

And then execute:

```bash
bundle install
rails posts:install:migrations
rails db:migrate
```

## Features

### Post Management
- **Custom Character Limits**: Configure custom character limits per instance through server settings (default: 500 characters)
- **Draft Status Management**: Create, update, publish, and delete draft posts with full API support
- **Scheduled Posts**: Extended scheduled status management with custom parameters
- **Quote Posts**: Support for quoting other posts with visibility inheritance
- **Reply Threading**: Enhanced reply management with thread validation

### Media & Content Enhancement
- **Automatic ALT Text Generation**: AI-powered automatic ALT text generation for images using external API integration
- **Link Preview Generation**: Automatic link thumbnail generation with customizable metadata extraction
- **Media Attachment Management**: Support for multiple image formats (JPEG, PNG, GIF, WebP, BMP) with validation
- **Draft Media Association**: Media attachments can be associated with draft statuses

### Notification Enhancements
- **Direct Mention Filtering**: Filter notifications to show only direct mentions
- **Private Mention Exclusion**: Option to exclude private/direct mentions from notification lists
- **Grouped Notifications**: Enhanced notification grouping with custom type support
- **Extended Notification API**: V1 and V2 API enhancements for better filtering

### Automation & Integration
- **Post Boosting**: Automatic post boosting to external instances with worker support
- **Relay Management**: Create and delete relay connections for federated content
- **Custom Timeline Filtering**: Extended account status filtering with multiple exclusion options
- **Boost Channel Management**: Special handling for boost bot accounts

### Server Configuration
- **Flexible Server Settings**: Hierarchical server settings with parent-child relationships
- **Environment-Based Toggles**: Feature flags for ALT text generation, post boosting, and user toggles
- **Instance Serialization**: Extended instance metadata with custom configuration exposure

## API Endpoints

### Draft Management
```
POST   /api/v1/drafted_statuses           # Create a new draft
GET    /api/v1/drafted_statuses           # List all drafts (grouped by date)
GET    /api/v1/drafted_statuses/:id       # Show a specific draft
PUT    /api/v1/drafted_statuses/:id       # Update a draft
DELETE /api/v1/drafted_statuses/:id       # Delete a draft
POST   /api/v1/drafted_statuses/:id/publish # Publish a draft as a status
```

### Utilities
```
GET    /api/v1/utilities/link_preview     # Generate link preview for a URL
```

### Relay Management
```
POST   /api/v1/patchwork/relays           # Create a new relay connection
DELETE /api/v1/patchwork/relays/:id       # Remove a relay connection
```

## Configuration

### Environment Variables

#### ALT Text Generation
- `ALT_TEXT_ENABLED` - Enable/disable automatic ALT text generation (`true`/`false`)
- `ALT_TEXT_URL` - Base URL for ALT text API service
- `ALT_TEXT_SECRET` - API key for ALT text service authentication
- `ALT_TEXT_USER_TOGGLE` - Require user opt-in for ALT text generation (`true`/`false`)

#### Post Boosting
- `BOOST_POST_ENABLED` - Enable/disable automatic post boosting (`true`/`false`)
- `BOOST_POST_INSTANCE_URL` - Target instance URL for boosting posts
- `BOOST_POST_API_KEY` - API key for boost service authentication
- `BOOST_POST_API_SECRET` - API secret for boost service authentication
- `BOOST_POST_USERNAME` - Username for boost service account
- `BOOST_POST_USER_DOMAIN` - Domain for boost service account

### Database Models

The gem adds the following database tables:
- `patchwork_drafted_statuses` - Stores draft posts with associated media
- `patchwork_communities` - Community definitions with visibility settings
- `patchwork_communities_admins` - Community administrator associations
- `server_settings` - Hierarchical server configuration settings

### Limits

- **Total Draft Limit**: 300 drafts per account
- **Daily Draft Limit**: 25 new drafts per day per account
- **Media Upload Limit**: 2 MB per community image

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patchwork-hub/posts. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/patchwork-hub/posts/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [AGPL-3.0 License](https://opensource.org/licenses/AGPL-3.0).

## Code of Conduct

Everyone interacting in the Posts project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/patchwork-hub/posts/blob/main/CODE_OF_CONDUCT.md).
