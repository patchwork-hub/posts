# Posts Gem

A Ruby on Rails plugin that enhances Mastodon's posting features with customizable character limits, draft management, quote posts, and automatic ALT text generation.

## Overview

New post features for your Patchwork enhanced Mastodon server.

To enable this plugin please make sure you have set up a Mastodon server and installed the Patchwork Dashboard, with both running correctly.

[See the full Patchwork ReadMe here.](https://github.com/patchwork-hub/patchwork_dashboard/blob/main/README.md)

## Features

### 🔤 Custom Character Limit
Set a custom character limit for posts on the server through server settings.

### 📝 Draft Management
- Create and manage draft posts
- Save posts as drafts before publishing
- API endpoints for draft operations

### 🖼️ Enhanced Media Handling
- Automatic ALT text generation for images using AI
- Support for multiple image formats (JPG, PNG, GIF, WebP, BMP)
- Media attachment validation and processing

### 🔗 Link Preview Generation
- Automatic link thumbnail generation
- Configurable link preview attributes (title, images, description)
- Custom user agent for web scraping

### ⚙️ Server Configuration
- Flexible server settings management
- Environment-based feature toggles
- Customizable posting limits and restrictions

## Installation

Before installing this gem, please make sure that the following systems are up and running:

- [Set up a Mastodon server](https://docs.joinmastodon.org/admin/install/)
- [Patchwork Dashboard](https://github.com/patchwork-hub/patchwork_dashboard/blob/main/README.md)

1. Add this line to your Mastodon application's Gemfile:

```ruby
gem "posts", git: "https://github.com/patchwork-hub/posts"
```

2. Install the gem:

```bash
bundle install
```

3. Run the migrations:

```bash
rails db:migrate
```

4. After installing the gem, restart your application to load it in your application.

## Configuration

### Environment Variables

- `ALT_TEXT_ENABLED`: Set to `true` to enable automatic ALT text generation for images
- Other configuration options can be set through the Patchwork Dashboard

### Server Settings

Configure posting limits and features through your Patchwork Dashboard or directly via the `Posts::ServerSetting` model.

## API Endpoints

The gem provides additional API endpoints for:

- `/api/v1/drafted_statuses` - Draft management
- Enhanced media attachment handling
- Server settings configuration

## Requirements

- Ruby on Rails 8.0+
- Mastodon server
- Patchwork Dashboard

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/patchwork-hub/posts.

## License

The gem is available as open source under the terms of the [AGPL-3.0 License](https://www.gnu.org/licenses/agpl-3.0.en.html).
