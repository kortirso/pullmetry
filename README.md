# Application for getting relevant stats about PRs and reviewers

## Ruby version

- 3.2.0

## Running application locally

```bash
foreman s
```

## Application layers

contracts - model schemas for validators
schemas - model schemas for validating controller params
validators - model validations
forms - service object to interact with user form input

deliveries, notifiers - delivery layer with different providers

queries - separated database queries
services - business logic layer
policies - authorization logic

## Credentials example

If you would like to run application locally or on your production server you need to generate new config/master.key and use config/credentials.yml.example for updating config/credentials.yml.enc with your api keys.

## Running application locally in production environment

For running production env locally you can call

```bash
bin/local-production
```

## License

The source code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
