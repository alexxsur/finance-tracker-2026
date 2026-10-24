# Steps After `rails new`

> **Purpose:** This file answers one question: *the project was just generated with `rails new finance-tracker-2026 --database=postgresql`; what are the usual next steps?* It is a general step-by-step guide from a fresh scaffold to a first working feature. For the project-specific plan and progress tracking, see [ROADMAP.md](ROADMAP.md). For how to run the project as it is today, see the [README](../README.md).

## Starting point

```sh
rails new finance-tracker-2026 --database=postgresql
```

## 1. Enter the project and review what was generated

```sh
cd finance-tracker-2026
```

Review the `README.md`, the `Gemfile`, and the application configuration (`config/application.rb`, `config/database.yml`, `config/routes.rb`).

## 2. Install dependencies

```sh
bundle install
```

## 3. Configure PostgreSQL

Make sure the PostgreSQL server is installed and running. Set the username, password, host, and port in `config/database.yml`, or provide them through environment variables such as `DATABASE_URL`. Never commit credentials.

## 4. Create and check the database

```sh
bin/rails db:create
bin/rails db:migrate
```

A fresh project has no migrations yet, so `db:migrate` will do nothing until you create models.

## 5. Run the application

```sh
bin/rails server
```

Open `http://localhost:3000` and confirm Rails boots correctly. The generated health check is available at `/up`.

## 6. Define the scope and the data model

For a finance tracker, decide which entities you need, for example: users, accounts, transactions, and categories. Sketch their relationships before generating models.

## 7. Create models and migrations

Use the Rails generators, then run the migrations:

```sh
bin/rails generate model Transaction amount:decimal description:string
bin/rails db:migrate
```

The fields above are only an illustration. Define the real requirements and column types first (for example, precision and scale for money amounts).

## 8. Add validations, domain logic, and tests

Implement the domain rules in models (or service objects) and add tests for the important behavior:

```sh
bin/rails test
```

## 9. Build routes, controllers, and views

Start with one small feature, such as recording and listing transactions, and expand iteratively.

## 10. Use version control and review configuration

Commit your work regularly. Check that secrets, credentials, and local-only configuration are not included in the repository.

## Summary

Install dependencies and configure the database, confirm the app boots, define the domain, and build a first feature with tests.
