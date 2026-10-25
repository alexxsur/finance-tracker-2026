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

## 2. Install dependencies

```sh
bundle install
```

## 3. Configure PostgreSQL

Make sure the PostgreSQL server is installed and running. Set the username, password, host, and port in `config/database.yml`, or provide them through environment variables such as `DATABASE_URL`. Never commit credentials.

## 4. Configure environment variables with `dotenv-rails`

In development and test, environment variables are loaded from `.env` files by the `dotenv-rails` gem.

1. Add the gem to the `development` and `test` group of the `Gemfile` (it is only installed locally so far), then install it:

   ```sh
   bundle add dotenv-rails --group "development, test"
   ```

2. Create a `.env` file in the project root with the variables for your machine, for example the database connection and any external API keys:

   ```sh
   DATABASE_URL=postgresql://USERNAME:PASSWORD@localhost:5432/finance_tracker_2026_development
   EXTERNAL_API_KEY=your_key_here
   ```

   Optionally create environment-specific files such as `.env.development`, `.env.test`, and `.env.local` for values that differ per environment or developer.

3. Read the values in the application with `ENV["NAME"]` or `ENV.fetch("NAME")`.

4. Confirm the files are ignored by Git. The generated `.gitignore` already ignores `/.env*`, so real values are never committed. To share the list of required variables, create a placeholder-only template (for example `.env.example`) and explicitly allow it in `.gitignore` with `!/.env.example`.

5. Restart the Rails server after changing a `.env` file.

### Optional: load the variables in the terminal with `direnv`

`dotenv-rails` only loads the `.env` file when Rails boots. `direnv` is a shell tool (not a gem) that automatically loads and unloads environment variables when you enter or leave the project directory, so they are also available to commands that do not boot Rails, such as `psql`, `pg_isready`, or `createdb`. It was needed in this project so that `bin/rails db:prepare` picked up the variables from `.env` in the terminal session.

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

   The `.envrc` file is already covered by the `/.env*` rule in `.gitignore`, so it is not committed.

3. Approve the file. `direnv` refuses to load a new or modified `.envrc` until you allow it, as a security measure:

   ```sh
   direnv allow
   ```

   Run `direnv allow` again every time `.envrc` changes. Changes to `.env` alone are not detected by this `.envrc`; run `direnv reload`, or add the line `watch_file .env` to `.envrc` (and run `direnv allow` once) so `direnv` reloads automatically.

4. Verify the variables are loaded:

   ```sh
   env | grep PG
   ```

Notes:

- `direnv` loads variables into the shell, and `dotenv-rails` does not overwrite variables that already exist, so using both is safe.
- Variables already exported in the terminal for another project take precedence over the ones in `.env`. If values do not match, check `env | grep PG`.
- Each collaborator must install `direnv` and configure their own shell; it is not installed by `bundle install`.

In production, set the variables in the hosting environment or use Rails credentials instead of a `.env` file.

## 5. Create and check the database

```sh
bin/rails db:create
bin/rails db:migrate
```

A fresh project has no migrations yet, so `db:migrate` will do nothing until you create models.

**Option:** use a single command instead of the two above:

```sh
bin/rails db:prepare
```

`db:prepare` is safe to run repeatedly. For each configured database, it creates the database if it does not exist and, if the database is empty (no `schema_migrations` table), loads the schema file when one exists. It then always runs any pending migrations, updates the schema file if the migrations changed it, and runs the seeds only if a database was initialized during that run. It never deletes data. It is convenient after cloning the repository or pulling code that includes new migrations. While developing your own migrations, keep using `bin/rails db:migrate`.

### When to use `db:seed`

`bin/rails db:seed` runs `db/seeds.rb` to load initial or sample data. Use it:

- To load data the application needs in order to work, such as default categories or lookup values.
- To fill a development database with sample data so you can try the interface without entering everything by hand.
- After resetting the database, for example with `bin/rails db:reset` (drop, create, load schema, seed) or `bin/rails db:setup`.

Notes:

- `db:prepare` already runs the seeds, but only when it initializes a new database; running `db:prepare` on an existing database does not re-run them.
- `db:seed` does not check whether the data already exists. Write `db/seeds.rb` so it can run more than once without creating duplicates (for example, with `find_or_create_by!`).
- Do not put secrets or real user data in `db/seeds.rb`; it is committed to Git.

## 6. Run the application

```sh
bin/rails server
```

Open `http://localhost:3000` and confirm Rails boots correctly. The generated health check is available at `/up`.

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

System tests (`test/system`) are end-to-end tests that simulate a real user working with the application in a real browser: they open pages, click, fill in forms, and check what appears on screen.

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
| System | The complete flow in a browser, including JavaScript, Turbo, and CSS | Slow |

Use system tests for the critical user journeys (for example, signing up, creating a transaction, or searching for friends), especially when they depend on JavaScript or Turbo. Because they are slower and more fragile, keep them few and rely mostly on model and integration tests.

#### Why they fail on a fresh project

A fresh Rails project has no `test/system` directory, so `bin/rails test:system` fails with `cannot load such file -- .../test/system` (`LoadError`) until the first system test exists. For the same reason, the `system-test` job in `.github/workflows/ci.yml` is commented out. Until then, use `bin/rails db:test:prepare` and `bin/rails test`.

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

These commands were taken from the terminal history, in the order they were run, starting from project generation. Add new commands here as the project advances.

| Command | Purpose |
|---------|---------|
| `rails new --help` | Review the available generator options. |
| `rails new finance-tracker-2026 --database=postgresql` | Generate the application using PostgreSQL. |
| `rails s` | Start the Rails server to confirm the app boots. |
| `rails -v` / `ruby -v` | Check the installed Rails and Ruby versions. |
| `bundle install` | Install the gems listed in the `Gemfile`. |
| `gem update --system` | Update RubyGems before reinstalling dependencies. |
| `gem install dotenv-rails` | Install the `dotenv-rails` gem locally. It is not in the `Gemfile` yet; see step 4 to add it. |
| `direnv allow` | Approve the project's `.envrc` so `direnv` loads the variables from `.env` into the terminal (needed for `bin/rails db:prepare` to see them). |
| `bin/rails db:prepare` | Create the database (if needed), load the schema, and run pending migrations. |

## Summary

Install dependencies and configure the database, confirm the app boots, define the domain, and build a first feature with tests.
