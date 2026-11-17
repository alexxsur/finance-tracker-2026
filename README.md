# Finance Tracker 2026

> **Purpose:** This file describes the project as it exists today and explains how to set it up, run it, and test it locally. For the general steps to follow after `rails new`, see [docs/POST_GENERATION_STEPS.md](docs/POST_GENERATION_STEPS.md). For the planned development steps and progress, see [the development roadmap](docs/ROADMAP.md).

## Current status

The application has Devise-based user authentication, names on registration and profile editing, and Bootstrap styling. Users can search for stocks using Twelve Data and add up to ten unique stocks to their portfolios or remove them. Stock search results update with Turbo without a full-page reload.

The friends page lists followed users and allows searching users by name or email. Users can follow people from search results and unfollow them from the friends list.

## Technology

- Ruby 3.3.13 (see `.ruby-version`)
- Rails (see `Gemfile` and `Gemfile.lock`)
- PostgreSQL
- Puma
- Bootstrap (compiled from Sass with cssbundling-rails)

## Prerequisites

Install Ruby 3.3.13, PostgreSQL, and Bundler. PostgreSQL must be running, and your local PostgreSQL role must be able to create databases. If your PostgreSQL setup requires a username, password, host, or port, configure it in `config/database.yml` or through the supported `DATABASE_URL` environment variable. Do not commit credentials.

## Local setup

From the project root:

1. Install the Ruby dependencies:

   ```sh
   bundle install
   ```

2. Prepare the development database:

   ```sh
   bin/rails db:prepare
   ```

   If database preparation fails, check that PostgreSQL is running and that your local PostgreSQL role and connection settings are correct.

3. Start the Rails server:

   ```sh
   bin/rails server
   ```

4. Open [http://localhost:3000](http://localhost:3000).

The generated health check is available at `/up`.

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

Search for `Lee` to find two users, including one followed and one not followed when signed in as `near-limit@seed.example.com`. View their profiles to try adding stocks from another portfolio; `DIS` is also available as an untracked example. Example prices are illustrative, not live quotes. Stock search still requires the Twelve Data API key and a working API connection.

Seeds can be run repeatedly without duplicating their records. They add missing example relationships but do not reset existing users, passwords, stocks, or relationships, so a previously modified example account may differ from the scenarios above. Use a fresh development database for the exact initial scenarios. Existing users keep their current passwords. Seeds refuse to run outside development and test.

## Tests

Run the Rails test suite with:

```sh
bin/rails test
```

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
- [docs/ROADMAP.md](docs/ROADMAP.md): the project-specific development plan and progress checklist. Update it as milestones are completed so it reflects the actual state of the project.
