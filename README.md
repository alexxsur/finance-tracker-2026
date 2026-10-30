# Finance Tracker 2026

> **Purpose:** This file describes the project as it exists today and explains how to set it up, run it, and test it locally. For the general steps to follow after `rails new`, see [docs/POST_GENERATION_STEPS.md](docs/POST_GENERATION_STEPS.md). For the planned development steps and progress, see [the development roadmap](docs/ROADMAP.md).

## Current status

The application currently has a welcome page, Devise-based user authentication, and Bootstrap configured through the CSS bundling pipeline. Finance-tracking features such as accounts, transactions, and reports are not implemented yet.

## Technology

- Ruby 3.3.10 (see `.ruby-version`)
- Rails 8.1.4 (see `Gemfile`)
- PostgreSQL
- Puma
- Bootstrap (compiled from Sass with cssbundling-rails)

## Prerequisites

Install Ruby 3.3.10, PostgreSQL, and Bundler. PostgreSQL must be running, and your local PostgreSQL role must be able to create databases. If your PostgreSQL setup requires a username, password, host, or port, configure it in `config/database.yml` or through the supported `DATABASE_URL` environment variable. Do not commit credentials.

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
```

## Documentation

- [docs/POST_GENERATION_STEPS.md](docs/POST_GENERATION_STEPS.md): the usual steps to follow after generating a Rails project with `rails new ... --database=postgresql`.
- [docs/ROADMAP.md](docs/ROADMAP.md): the project-specific development plan and progress checklist. Update it as milestones are completed so it reflects the actual state of the project.
