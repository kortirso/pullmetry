# Application for getting relevant stats about PRs and reviewers

## Ruby version

- 3.2.0

## Running application locally

```bash
foreman s
```

## Credentials example

If you would like to run application locally or on your production server you need to generate new config/master.key and update config/credentials.yml.enc like this example with your api keys.

```bash
reports_webhook_url:
database_password:
github_oauth:
  production:
    client_id:
    client_secret:
    redirect_url:
  development:
    client_id:
    client_secret:
    redirect_url:
gitlab_oauth:
  production: 
    client_id:
    client_secret:
    redirect_url:
  development:
    client_id:
    client_secret:
    redirect_url:
queweb:
  user:
  password:
secret_key_skylight:
secret_key_bugsnag:
secret_key_base:
```

## Running application locally in production environment

For running production env locally you can call

```bash
bin/local-production
```

## License

The source code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
