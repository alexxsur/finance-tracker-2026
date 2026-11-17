# Development Roadmap

> **Purpose:** This file is the step-by-step plan for taking Finance Tracker 2026 from its generated Rails scaffold to a working application. Use the checkboxes to record progress. Keep setup instructions for the current application in the [README](../README.md), and the general steps to follow after `rails new` in [POST_GENERATION_STEPS.md](POST_GENERATION_STEPS.md).

## How to read this roadmap

- The project is a stock tracker with a social component: users sign up, look up and track stocks in a personal portfolio, and follow friends. Adapt names and features to the finance domain as needed; the order and granularity of the tasks are what matter here.
- Tasks are grouped by milestone; checkboxes track completed work rather than a strict dependency order.
- Use the project versions specified in `.ruby-version`, `Gemfile.lock`, and `yarn.lock`, and update dependencies deliberately. Prefer the configured Rails tooling:
  - Turbo (Turbo Frames and Turbo Streams) and Stimulus instead of hand-written AJAX or JavaScript response templates.
  - The Rails asset pipeline and import maps (or the project's configured JavaScript tooling) for assets.
  - Bootstrap's current utility and component classes instead of legacy ones.
  - An external data provider that is currently available. Verify availability, terms, and rate limits before depending on it.

## Current baseline

- [x] Generate the Rails application with PostgreSQL.
- [x] Confirm the Rails configuration and default health-check route are present.
- [x] Document local setup and testing in the README.
- [x] Add `dotenv-rails` to the `Gemfile` (development and test groups) and ignore local `.env` files. See [POST_GENERATION_STEPS.md](POST_GENERATION_STEPS.md).

Stock lookup, portfolio tracking and removal, friend search, following, removal, and user profiles are implemented.

## Milestones

### 1. Foundation and authentication

- [x] Add a welcome page as the root route.
- [x] Add Devise and create users.

### 2. Styling and navigation

- [x] Add Bootstrap for styling with `cssbundling-rails` and the Bootstrap Sass setup.
- [x] Style the forms with Bootstrap.
- [x] Add a navigation partial and style flash messages.

### 3. External data and portfolio

- [x] Add the stock (or financial asset) model with ticker, name, and last price.
- [x] Configure the external data provider credentials, keeping secrets out of source control (use Rails credentials or environment variables).
- [x] Generate the `UsersController#my_portfolio` action and placeholder view.
- [x] Build the "my portfolio" view and stock lookup form.
- [x] Add a standard (full page) stock lookup with result and error handling.
- [x] Make the lookup dynamic with Turbo, including error handling.
- [x] Generate the `UserStock` resource and migration with references to users and stocks.
- [x] Add a many-to-many association between users and tracked stocks through `UserStock`.
- [x] Allow users to add stocks to their portfolios and display their tracked stocks.
- [x] Add tracking restrictions: prevent duplicate stocks and limit each user to ten tracked stocks.
- [x] Add tracking removal.
- [ ] Clean up formatting and update the README.

### 4. User profile details

- [x] Add first and last names to users and let the account edit form accept them.
- [x] Allow first and last names during sign-up.

### 5. Friends and social features

- [x] Add a self-referential friendships association (back end).
- [x] Add a "my friends" view listing followed friends.
- [x] Add a friend search form.
- [x] Submit the friend search dynamically with Turbo.
- [x] Add user search methods.
- [x] Add friend removal.
- [x] Create friendships from the browser.
- [x] Add a user/friend profile page.
- [x] Add a back button to the user/friend profile page.

### 6. Polish and documentation

- [ ] Review button sizes and other UI details using Bootstrap's current classes.
- [ ] Update the README with the final state of the project.

## Extra steps for this project

These are recommended before release:

- [ ] Add tests for models, requests, and the main user journeys at each milestone.
- [ ] Run the configured code-quality and security checks (`bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`).
- [ ] Document production configuration, database setup, and deployment.

## Progress notes

Add brief notes here when a milestone changes materially. For detailed change history, use Git commits rather than turning this roadmap into a full development diary.
