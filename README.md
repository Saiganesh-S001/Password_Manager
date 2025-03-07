# Password Manager API

This is a Rails-based API application for managing passwords, built with Grape and Swagger for API documentation. It uses PostgreSQL as the database and includes JWT authentication with Devise.

## Prerequisites

- Ruby 3.x
- Rails 8.0.1
- PostgreSQL 9.3 or higher
- Node.js and Yarn (for managing JavaScript dependencies)

## Setup

### Clone the Repository

```bash
git clone https://github.com/yourusername/password_manager.git
cd password_manager
```

### Install Dependencies

Install the required gems:

```bash
bundle install
```

Install JavaScript dependencies:

```bash
yarn install
```

### Database Configuration

Ensure PostgreSQL is installed and running. Configure your database settings in `config/database.yml`. Use environment variables or Rails credentials for passwords.
#### Example Database Configuration

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: password_manager_development
  username: postgres
  password: <%= Rails.application.credentials.dig(:database, :db_password) %>
  host: localhost
  port: 5433

test:
  <<: *default
  database: password_manager_test
  username: postgres
  password: <%= Rails.application.credentials.dig(:database, :db_password %>
  host: localhost
  port: 5433

production:
  <<: *default
  database: password_manager_production
  username: password_manager
  password: <%= ENV["PASSWORD_MANAGER_DATABASE_PASSWORD"] %>
```

### Setup Rails Credentials

Store sensitive information like database passwords and secret keys in Rails credentials. To edit credentials, run:

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

Add the following entries:

```yaml
database:
  db_password: your_database_password
secret_key_base: your_secret_key_base
jwt_secret: your_jwt_secret
```

### Database Setup

Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

### Running the Server

Start the Rails server:

```bash
bin/rails server (or)
bin/dev
```

Access the application at `http://localhost:3000`.


### Running Tests

Run the test suite using RSpec:

```bash
bundle exec rspec
```
