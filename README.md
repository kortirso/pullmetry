# PullKeeper

[pullkeeper.dev](https://pullkeeper.dev) (or just PullKeeper) is a platform where software developers can get statistics of their pull requests in different repositories and collection of repositories, statistics contains data about approves, comments, changed lines of codes and other.

## Installation

```bash
$ bundle install
$ rails db:create
$ rails db:schema:load
$ rails db:seed
$ yarn install
$ EDITOR=vim rails credentials:edit
```

### Credentials

If you would like to run application locally or on your production server you need to generate new config/master.key and use config/credentials.yml.example for updating config/credentials.yml.enc with your api keys.

## Running application locally

```bash
foreman s
```

### Running application locally in production environment

For running production env locally you can call

```bash
bin/local-production
```

## Testing

### Unit tests

```bash
$ rspec
```

### E2E tests

With browser
```bash
$ rails server -e test -p 5002
$ yarn cypress open --project ./spec/e2e
```

Headless
```bash
$ rails server -e test -p 5002
$ yarn run cypress run --project ./spec/e2e
```

### Sensitive information leaks

```bash
$ bearer scan .
```

## API

API documentation is available at [api-docs](https://pullkeeper.dev/api-docs).

### Refresh API documentation

```bash
$ rails rswag:specs:swaggerize
```

## Application layers

commands - persisters layer with validations and persisting

deliveries, notifiers - delivery layer with different providers

queries - separated database queries

services - business logic layer

policies - authorization logic

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. Please see the [LICENSE](./LICENSE.md) file in our repository for the full text.

## Sponsors

[<img width="200" src="https://evrone.com/logo/evrone-sponsored-logo.png">](https://evrone.com/?utm_source=pullkeeper)
