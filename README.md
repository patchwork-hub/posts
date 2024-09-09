## Overview

New post features for your Patchwork enhanced Mastodon server.

To enable this plugin please make sure you have set up a Mastodon server and installed the Patchwork Dashboard, with both running correctly.

[See the full Patchwork ReadMe here.](https://github.com/patchwork-hub/patchwork_dashboard/blob/main/README.md)

### Features

#### Custom Character Limit:
Set a custom character limit for posts on the server.
  
### Installation

Before installing this gem, please make sure that the following systems are up and running:

- Set up a Mastodon server
- Patchwork Dashboard

1. Add this line to your Mastodon application's Gemfile:

```ruby
gem "posts", git: "https://github.com/patchwork-hub/posts"
```

2. Install The gem

```ruby
bundle install
```

3. After installing the gem, restart your application to load it in your application.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
