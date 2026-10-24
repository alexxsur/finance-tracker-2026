# Development Roadmap

> **Purpose:** This file is the step-by-step plan for taking Finance Tracker 2026 from its generated Rails scaffold to a working application. Use the checkboxes to record progress. Keep setup instructions for the current application in the [README](../README.md), and the general steps to follow after `rails new` in [POST_GENERATION_STEPS.md](POST_GENERATION_STEPS.md).

## How to read this roadmap

- The project is a stock tracker with a social component: users sign up, look up and track stocks in a personal portfolio, and follow friends. Adapt names and features to the finance domain as needed; the order and granularity of the tasks are what matter here.
- Tasks are ordered so that each one builds on the previous ones.
- This project uses the latest stable Ruby and Rails (see `.ruby-version` and the `Gemfile`) and the current stable Bootstrap. Avoid outdated techniques and use the current Rails defaults instead:
  - Turbo (Turbo Frames and Turbo Streams) and Stimulus instead of hand-written AJAX or JavaScript response templates.
  - The Rails asset pipeline and import maps (or the project's configured JavaScript tooling) for assets.
  - Bootstrap's current utility and component classes instead of legacy ones.
  - An external data provider that is currently available. Verify availability, terms, and rate limits before depending on it.

## Current baseline

- [x] Generate the Rails application with PostgreSQL.
- [x] Confirm the Rails configuration and default health-check route are present.
- [x] Document local setup and testing in the README.

No application features have been implemented yet.

## Milestones

### 1. Foundation and authentication

- [ ] Add a welcome page as the root route.
- [ ] Add Devise and create users.

### 2. Styling and navigation

- [ ] Add Bootstrap for styling.
- [ ] Style the forms with Bootstrap.
- [ ] Add a navigation partial and style flash messages.

### 3. External data and portfolio

- [ ] Add the stock (or financial asset) model and configure the external data provider credentials, keeping secrets out of source control (use Rails credentials or environment variables).
- [ ] Build the "my portfolio" view and the lookup form.
- [ ] Add a standard (full page) lookup.
- [ ] Make the lookup dynamic with Turbo, including error handling.
- [ ] Add a many-to-many association between users and tracked assets.
- [ ] Add tracking restrictions for users (for example, limits and duplicate prevention).
- [ ] Add tracking removal.
- [ ] Clean up formatting and update the README.

### 4. User profile details

- [ ] Add first and last names to users and let the account edit form accept them.
- [ ] Allow first and last names during sign-up.

### 5. Friends and social features

- [ ] Add a self-referential friendships association (back end).
- [ ] Add a "my friends" view listing followed friends.
- [ ] Add a friend search form.
- [ ] Submit the friend search dynamically with Turbo.
- [ ] Add user search methods.
- [ ] Add friend removal.
- [ ] Create friendships from the browser.
- [ ] Add a user/friend profile page.
- [ ] Add a back button to the user/friend profile page.

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
