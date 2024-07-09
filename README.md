# Posts

A Ruby on Rails plugin for extending the character limit on Mastodon posts.

## Features

- **Extended Character Limit**: Increase the character limit for posts beyond the default limit.
- **Dynamic Configuration**: Set and modify the maximum character limit through server settings.

## Installation

Before installing this gem, please make sure that the following systems are up and running:

- A Mastodon server set up from source
- Patchwork dashboard system

### Step 1: Add the Gem

Add this line to your Mastodon application's Gemfile:

```ruby
gem "posts", git: "https://github.com/patchwork-hub/posts"
```

### Step 2: Install The gem

```ruby
bundle install
```

### Step 3: Restart Your Application

After installing the gem, restart your application to load it in your application.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
