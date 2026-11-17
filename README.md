# Finance Tracker 2026

> **Purpose:** This file describes the project as it exists today and explains how to set it up, run it, and test it locally. For the general steps to follow after `rails new`, see [docs/POST_GENERATION_STEPS.md](docs/POST_GENERATION_STEPS.md). For the planned development steps and progress, see [the development roadmap](docs/ROADMAP.md).

## Current status

The application has Devise-based user authentication, names on registration and profile editing, and Bootstrap styling. Users can search for stocks using Twelve Data and add up to ten unique stocks to their portfolios or remove them. Stock search results update with Turbo without a full-page reload.

The friends page lists followed users and allows searching users by name or email. Users can follow people, unfollow them, and view profiles and portfolios.

## Technology

- Ruby (see `.ruby-version`)
- Rails (see `Gemfile` and `Gemfile.lock`)
- PostgreSQL
- Puma
- Bootstrap (compiled from Sass with cssbundling-rails)

## Prerequisites

Install the Ruby version in `.ruby-version`, Bundler, PostgreSQL, Node.js, and Yarn. PostgreSQL must be running, and your local PostgreSQL role must be able to create databases. Configure connection settings through environment variables (`PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, or `DATABASE_URL`) or `config/database.yml`. Do not commit credentials.

## Local setup

From the project root:

1. Install the Ruby dependencies:

   ```sh
   bundle install
   ```

2. Set up development environment variables in a local `.env` file. `dotenv-rails` loads this file when Rails starts. Set the PostgreSQL connection variables for your installation and `SEED_USER_PASSWORD` to a nonblank password accepted by Devise. The `.env` file is ignored by Git.

   For stock lookup, configure `twelve_data.api_key` in Rails encrypted credentials:

   ```sh
   EDITOR="code --wait" bin/rails credentials:edit
   ```

   Add a `twelve_data` mapping containing `api_key`. Keep the API key and `config/master.key` private. Without the appropriate master key, Rails cannot decrypt the existing credentials file. Stock lookup also requires a working connection to Twelve Data.

3. Install JavaScript dependencies and build the Bootstrap stylesheet:

   ```sh
   yarn install --frozen-lockfile
   yarn build:css
   ```

4. Prepare the development database:

   ```sh
   bin/rails db:prepare
   ```

   When initializing a new database, this command may also run the example seeds. Set `SEED_USER_PASSWORD` first, as described in [Example data](#example-data). If database preparation fails, also check that PostgreSQL is running and that your local PostgreSQL role and connection settings are correct.

5. Start the Rails server:

   ```sh
   bin/rails server
   ```

6. Open [http://localhost:3000](http://localhost:3000).

The generated health check is available at `/up`. To rebuild CSS automatically while developing, use `bin/dev` instead of `bin/rails server`; it starts the server and CSS watcher and installs Foreman if it is missing.

## Example data

In development or test, add a password accepted by Devise to the ignored `.env` file in the project root:

```dotenv
SEED_USER_PASSWORD=your_example_password
```

Rails loads this file automatically. Environment variables already exported in the shell take precedence. Then run:

```sh
bin/rails db:seed
```

Sign in using that password and one of these example accounts:

| Email | Scenario |
| --- | --- |
| `investor@seed.example.com` | Three stocks and two followed users, with one mutual friendship. |
| `beginner@seed.example.com` | Empty portfolio and no followed users. |
| `near-limit@seed.example.com` | Nine stocks, with room for one more. |
| `at-limit@seed.example.com` | Ten stocks, at the tracking limit. |
| `anonymous@seed.example.com` | No name, stocks, or followed users. |

When signed in as `near-limit@seed.example.com`, search for `example.com` to find users including the followed investor and users not followed. View their profiles to try adding stocks from another portfolio; `DIS` is also available as an untracked example. Example prices are illustrative, not live quotes. Stock search still requires the Twelve Data API key and a working API connection.

Seeds can be run repeatedly without duplicating their records. They add missing example relationships but do not reset existing users, passwords, stocks, or relationships, so a previously modified example account may differ from the scenarios above. Use a fresh development database for the exact initial scenarios. Existing users keep their current passwords. Seeds refuse to run outside development and test.

## Tests

Run the Rails test suite with:

```sh
bin/rails test
```

System tests run separately with `bin/rails test:system` once they have been added. The system-test job in CI is currently disabled.

## Useful commands

```sh
bin/rails routes       # List application routes
bin/rails db:migrate   # Apply pending database migrations
bin/rails console      # Open a Rails console
bin/rails assets:precompile # Compile assets for deployment
bin/rubocop            # Check Ruby style and lint offenses
bin/bundler-audit      # Check gems for known security advisories
```

## Documentation

- [docs/POST_GENERATION_STEPS.md](docs/POST_GENERATION_STEPS.md): the usual steps to follow after generating a Rails project with `rails new ... --database=postgresql`.
- [docs/COMMAND_HISTORY.md](docs/COMMAND_HISTORY.md): commands used during this project's development and their purposes.
- [docs/ROADMAP.md](docs/ROADMAP.md): the project-specific development plan and progress checklist. Update it as milestones are completed so it reflects the actual state of the project.
