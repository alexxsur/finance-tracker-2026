# Steps After `rails new`

> **Purpose:** This file answers one question: *the project was just generated with `rails new finance-tracker-2026 --database=postgresql`; what are the usual next steps?* It is a general step-by-step guide from a fresh scaffold to a first working feature. For the project-specific plan and progress tracking, see [ROADMAP.md](ROADMAP.md). It also records the commands actually run in this project so far. For how to run the project as it is today, see the [README](../README.md).

## Starting point

```sh
rails new finance-tracker-2026 --database=postgresql
```

## 1. Enter the project and review what was generated

```sh
cd finance-tracker-2026
```

Review the `README.md`, the `Gemfile`, and the application configuration (`config/application.rb`, `config/database.yml`, `config/routes.rb`).

### Set up Ruby with rbenv

If you use rbenv and the Ruby version in `.ruby-version` is not installed, install and activate it by running the following from the project root:

```sh
rbenv install "$(cat .ruby-version)"
rbenv rehash
ruby -v
```

To install a specific version instead, replace `VERSION` with the desired version:

```sh
rbenv install VERSION
rbenv rehash
```

Installing a version does not automatically select it. To use it only in the current shell, run `rbenv shell VERSION`; to select it for the project, run `rbenv local VERSION` from the project root. The latter updates `.ruby-version`, so change it only when intentionally changing the project's Ruby version. Verify the selected version with `ruby -v`.

If `rbenv install` cannot find that version, check the available versions with `rbenv install --list-all`. If ruby-build is installed as an rbenv Git plugin, update it with `git -C ~/.rbenv/plugins/ruby-build pull`; other installation methods require their own update process. Then retry the installation.

## 2. Install dependencies

```sh
bundle install
```

## 3. Configure PostgreSQL

Make sure the PostgreSQL server is installed and running. Set the username, password, host, and port in `config/database.yml`, or provide them through environment variables such as `DATABASE_URL`. Never commit credentials.

## 4. Configure environment variables with `dotenv-rails`

In development and test, Rails loads environment variables from `.env` files through the `dotenv-rails` gem.

1. If the gem is not already in the `development` and `test` group of the `Gemfile`, add it and install it:

   ```sh
   bundle add dotenv-rails --group "development, test"
   ```

2. Create a `.env` file in the project root with the variables for your machine. For this project, configure PostgreSQL and a password for example seeds:

   ```dotenv
   PGHOST=127.0.0.1
   PGPORT=5432
   PGUSER=your_postgresql_user
   PGPASSWORD=your_postgresql_password
   SEED_USER_PASSWORD=your_example_password
   ```

   Adjust these values to your environment. Alternatively, configure `DATABASE_URL`; a URL applies to the database named in it, so do not point test and development at the same database. Optionally use environment-specific files such as `.env.development`, `.env.test`, and `.env.local`. The Twelve Data API key is configured in Rails credentials, not in this `.env` example; see the [README](../README.md#local-setup).

3. Read the values in the application with `ENV["NAME"]` or `ENV.fetch("NAME")`.

4. Confirm the files are ignored by Git. The project's `.gitignore` ignores `/.env*`, including `.env.example` and `.envrc`. To share a placeholder-only template, explicitly allow it in `.gitignore` with `!/.env.example`; never include real secrets.

5. Restart the Rails server after changing a `.env` file.

### Optional: load the variables in the terminal with `direnv`

`direnv` is a shell tool (not a gem) that loads and unloads environment variables when you enter or leave the project directory. This makes them available to commands outside Rails, such as `psql` and `createdb`. It was used in this project before `dotenv-rails` was added. It is optional for Rails commands now that the gem is configured.

1. Install `direnv` and add its hook to your shell configuration (`~/.bashrc` or `~/.zshrc`), then restart the terminal:

   ```sh
   sudo apt install direnv
   echo 'eval "$(direnv hook bash)"' >> ~/.bashrc   # for zsh: eval "$(direnv hook zsh)" in ~/.zshrc
   ```

2. Create a `.envrc` file in the project root that exports everything defined in `.env`:

   ```sh
   set -a
   source .env
   set +a
   ```

   This executes `.env` as shell code: use only trusted, shell-compatible content. The `.envrc` file is covered by the `/.env*` rule in `.gitignore`, so it is not committed.

3. Approve the file. `direnv` refuses to load a new or modified `.envrc` until you allow it, as a security measure:

   ```sh
   direnv allow
   ```

   Run `direnv allow` again every time `.envrc` changes. Changes to `.env` alone are not detected by this `.envrc`; run `direnv reload`, or add the line `watch_file .env` to `.envrc` (and run `direnv allow` once) so `direnv` reloads automatically.

4. Verify the configuration by running a relevant command, such as `pg_isready`. Avoid printing environment variables: they may contain passwords.

Notes:

- The shown `source .env` assignments can overwrite variables already in the shell. Once exported, those values take precedence over `dotenv-rails` defaults, which do not normally overwrite existing environment variables.
- Each collaborator must install `direnv` and configure their own shell; it is not installed by `bundle install`.

In production, set the variables in the hosting environment or use Rails credentials instead of a `.env` file.

## 5. Create and check the database

```sh
bin/rails db:create
bin/rails db:migrate
```

A fresh project has no migrations yet, so `db:migrate` will do nothing until you create models.
This project now has migrations; the commands above apply any pending ones.

**Option:** use a single command instead of the two above:

```sh
bin/rails db:prepare
```

`db:prepare` is safe to run repeatedly. For each configured database, it creates the database if it does not exist and, if the database has no `schema_migrations` table, loads the schema file when one exists. It then runs pending migrations, may update the schema dump, and runs seeds when an eligible database was initialized during that run. It is convenient after cloning the repository or pulling code that includes new migrations. While developing your own migrations, keep using `bin/rails db:migrate`.

The project's example seeds require `SEED_USER_PASSWORD` and only run in development and test. Set the variable before `db:prepare` when it may initialize a database. See [Example data](../README.md#example-data) for configuration and seed behavior.

Because seeds refuse to run outside development and test, production initialization that invokes them will fail; production database setup needs a separate deployment plan.

### When to use `db:seed`

`bin/rails db:seed` runs `db/seeds.rb` to load initial or sample data. Use it:

- To load data the application needs in order to work, such as default categories or lookup values.
- To fill a development database with sample data so you can try the interface without entering everything by hand.
- To reload example data after a database reset. `bin/rails db:reset` and `bin/rails db:setup` already run seeds; `db:reset` deletes existing data.

Notes:

- `db:prepare` runs seeds when it initializes an eligible database, including an existing database without a `schema_migrations` table; it does not re-run them for an already initialized database.
- `db:seed` does not check whether the data already exists. Write `db/seeds.rb` so it can run more than once without creating duplicates (for example, with `find_or_create_by!`).
- Do not put secrets or real user data in `db/seeds.rb`; it is committed to Git.
- This project's seeds require `SEED_USER_PASSWORD`, refuse to run outside development and test, and add missing examples without resetting existing data or passwords. See [Example data](../README.md#example-data).

## 6. Run the application

```sh
bin/rails server
```

Open `http://localhost:3000` and confirm Rails boots correctly. The generated health check is available at `/up`.
For this project, install the JavaScript dependencies and build CSS first; see [Local setup](../README.md#local-setup). `bin/dev` also runs the CSS watcher.

## 7. Define the scope and the data model

For a finance tracker, decide which entities you need, for example: users, accounts, transactions, and categories. Sketch their relationships before generating models.

## 8. Create models and migrations

Use the Rails generators, then run the migrations:

```sh
bin/rails generate model Transaction amount:decimal description:string
bin/rails db:migrate
```

The fields above are only an illustration. Define the real requirements and column types first (for example, precision and scale for money amounts).

## 9. Add validations, domain logic, and tests

Implement the domain rules in models (or service objects) and add tests for the important behavior:

```sh
bin/rails test
```

### System tests and the CI pipeline

System tests (`test/system`) simulate user journeys through the application: they open pages, click, fill in forms, and check what appears on screen. Depending on the configured driver, they can use a real browser.

- They use Capybara (the API for describing user actions) and Selenium (which drives the browser, usually Chrome). Both gems are already in the `Gemfile`.
- They inherit from `ApplicationSystemTestCase`, which defines the browser and its settings.
- They run with `bin/rails test:system`. `bin/rails test` does not include them by default.

Example:

```ruby
class TransactionsTest < ApplicationSystemTestCase
  test "creating a transaction" do
    visit new_transaction_path
    fill_in "Description", with: "Groceries"
    fill_in "Amount", with: "25.50"
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
  end
end
```

| Test type | What it checks | Speed |
|-----------|----------------|-------|
| Model | Validations and logic of a model | Very fast |
| Controller / integration | HTTP requests and responses, without a browser | Fast |
| System | A user flow in a browser, potentially including JavaScript and Turbo | Slow |

Use system tests for the critical user journeys (for example, signing up, creating a transaction, or searching for friends), especially when they depend on JavaScript or Turbo. Because they are slower and more fragile, keep them few and rely mostly on model and integration tests.

#### Why they fail on a fresh project

This project currently has no `test/system` directory, so `bin/rails test:system` fails with `cannot load such file -- .../test/system` (`LoadError`). For the same reason, the `system-test` job in `.github/workflows/ci.yml` is commented out. Until then, use `bin/rails db:test:prepare` and `bin/rails test`.

To enable system tests later:

1. Generate the first one (this creates `test/system/` and `test/application_system_test_case.rb`):

   ```sh
   bin/rails generate system_test NAME
   ```

2. Make sure a supported browser (for example, Chrome) is available.
3. Uncomment the `system-test` job in `.github/workflows/ci.yml`.

## 10. Build routes, controllers, and views

Start with one small feature, such as recording and listing transactions, and expand iteratively.

## 11. Use version control and review configuration

Commit your work regularly. Check that secrets, credentials, and local-only configuration are not included in the repository.

## Commands used in this project so far

These commands were taken from the terminal history, in the order they were run, starting from project generation. Commands that specify a Ruby version use the version from `.ruby-version` below rather than hard-coding it. Add new commands here as the project advances.

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

## Summary

Install dependencies and configure the database, confirm the app boots, define the domain, and build a first feature with tests.
