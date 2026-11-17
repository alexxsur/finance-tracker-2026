# Project Command History

> **Purpose:** This file records commands used while developing this project and explains their purpose. For the general setup guide see [POST_GENERATION_STEPS.md](POST_GENERATION_STEPS.md); for current setup see the [README](../README.md).


This is an illustrative record of commands used during development, not a verbatim or exhaustive terminal transcript. Some entries are grouped or normalized, and commands specifying a Ruby version use the current `.ruby-version` rather than a hard-coded historical value. Add relevant commands as the project advances.

| Command | Purpose |
|---------|---------|
| `rails new --help` | Review the available generator options. |
| `rails new finance-tracker-2026 --database=postgresql` | Generate the application using PostgreSQL. |
| `rails s` | Start the Rails server to confirm the app boots. |
| `rails -v` / `ruby -v` | Check the installed Rails and Ruby versions. |
| `bundle install` | Install the gems listed in the `Gemfile`. |
| `gem update --system` | Update RubyGems before reinstalling dependencies. |
| `gem install dotenv-rails` | Install the `dotenv-rails` gem locally; use Bundler to install the version declared in the `Gemfile`. |
| `direnv allow` | Approve the local `.envrc` so `direnv` can load `.env` into the terminal. Rails now also loads `.env` through `dotenv-rails`. |
| `bin/rails db:prepare` | Create the database (if needed), load the schema, and run pending migrations. |
| `rails generate controller welcome index` | Generate the `Welcome` controller with an `index` action, its view, helper, and test, and add a `get "welcome/index"` route. The route was then replaced with `root "welcome#index"` so the welcome page is the home page. |
| `bundle add devise` | Add the Devise authentication gem to the `Gemfile` and install it. |
| `rails generate devise:install` | Create the Devise initializer (`config/initializers/devise.rb`) and locale file, and print the required setup notes (for example, the mailer `default_url_options`). |
| `rails generate devise MODEL` | Show Devise's generator usage with the literal placeholder `MODEL`; replace it with a real model name, as in the next command. |
| `rails generate devise User` | Generate the `User` model with Devise modules, a migration, and the `devise_for :users` route. |
| `rails generate devise:views` | Copy Devise's default authentication views into `app/views/devise` so they can be customized for the application. |
| `rails routes \| grep users` | List the routes that mention `users` to confirm the Devise routes were added. |
| `rails db:migrate` | Apply the migration that creates the `users` table. |
| `bundle add cssbundling-rails` | Add Rails CSS bundling support to the `Gemfile` and install the dependency. |
| `rails css:install:bootstrap` | Configure Bootstrap Sass, package scripts, and the CSS build setup for Rails. |
| `rails assets:precompile` | Compile the application assets, including the Bootstrap CSS bundle, for deployment. |
| `rails g model Stock ticker:string name:string last_price:decimal` | Generate the `Stock` model, its migration, and a test and fixture file. `g` is shorthand for `generate`. |
| `rails db:migrate` | Apply the migration that creates the `stocks` table (the same command is used above for `users`). |
| `EDITOR='code --wait' rails credentials:edit` | Open the encrypted Rails credentials in VS Code and wait until the file is closed to save it. Used to store the external stock data provider API key under `twelve_data: api_key:`. Never commit `config/master.key`. |
| `Rails.application.credentials.dig(:twelve_data, :api_key).present?` | Run in `rails console` to confirm the API key is stored, without printing the secret. |
| `rails g controller users my_portfolio` | Generate the `UsersController#my_portfolio` action, view, helper, test, and `get "my_portfolio"` route. The generated view is only a placeholder; implement the portfolio behavior separately. |
| `rbenv install "$(cat .ruby-version)"` | Install the Ruby version specified by the project. |
| `rbenv rehash` | Refresh rbenv's executable shims. |
| `git -C ~/.rbenv/plugins/ruby-build pull` | Update the ruby-build Git plugin's local checkout. |
| `rbenv install --list-all` | List the Ruby versions available through ruby-build. |
| `rbenv install --list-all \| grep -Fx "$(cat .ruby-version)"` | Check whether ruby-build lists the project's exact Ruby version. |
| `ruby -v` | Check the Ruby version selected in the project directory. |
| `bundle install` | Install the project's Ruby dependencies for the selected Ruby installation. |
| `rails g resource UserStock user:references stock:references` | Generate the `UserStock` model, migration, controller, helper, tests, fixture, and resource routes; the migration was subsequently applied. |
| `rails routes --expanded \| grep user_stocks` | Filter expanded route output for lines containing `user_stocks`. |
| `rails db:migrate` | Apply the `user_stocks` migration so users' tracked stocks can be stored in PostgreSQL. |
| `rails g migration add_first_last_name_to_users` | Generate a migration file for adding first and last name columns to users; edit the generated migration to define the columns before applying it. |
| `rails db:migrate` | Apply the user name migration so first and last names can be stored in the database. |
| `rubocop` | Check Ruby files for style and lint offenses using the project's RuboCop configuration. |
| `rubocop -f github` | Run the same RuboCop checks with output formatted for GitHub Actions annotations. |
| `bin/bundler-audit update` | Update the local vulnerability database used by `bundler-audit`; this does not update project gems. |
| `bin/bundler-audit` | Check the dependencies in `Gemfile.lock` for known security advisories. |
| `bundle update puma msgpack` | Update the named gems and compatible dependencies, recording resolved versions in `Gemfile.lock`. |
| `bundle update` | Update all gems allowed by the `Gemfile` constraints and refresh `Gemfile.lock`; review and test the resulting changes. |
| `rails g model Friendship user:references` | Generate the `Friendship` model, migration, test, and fixture with a user reference. The migration was subsequently extended with a friend reference to users. |
| `rails db:migrate` | Apply the friendships migration and create its table. |
| `rails test` | Run the Rails test suite, excluding system tests by default. |
| `rails db:prepare` | Prepare the database; when initializing it, this may also run the seeds and require `SEED_USER_PASSWORD`. |
| `rails db:seed` | Load example users, stocks, portfolios, and friendships after setting `SEED_USER_PASSWORD`. |
| `bundle install --gemfile` | The option requires a Gemfile path, for example `bundle install --gemfile=./Gemfile`; the command as written omits that value. From the project root, `bundle install` uses the project's Gemfile by default. |
