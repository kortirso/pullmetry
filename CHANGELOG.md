# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- time_since_last_open_pull_seconds insight

### Fixed
- multiple notifications sending

## [1.8.1] - 2024-07-12
### Added
- rendering PDF with insights

### Modified
- Notification and Webhook models
- edit form of notifications and webhooks
- highlight access token button
- frontend folders structure

## [1.8.0] - 2024-07-04
### Added
- co-owners for accounts
- expiration time for access tokens
- creating/removing API access tokens
- API documentation
- fetching insights by API

### Modified
- skip reseting invites email after accepting invite
- deliveries/notifiers structure

## [1.7.10] - 2024-06-16
### Added
- Google oauth

### Modified
- feedback attributes

### Fixed
- bug with unknown github's review state

## [1.7.9] - 2024-05-04
### Added
- parsing body of comments with checking convention
- rendering conventional comments count

### Modified
- fetching commented and uniq accepted reviews from Github
- calculating commented PRs

## [1.7.8] - 2024-05-03
### Added
- transfering companies to another users
- encrypting sensitive data
- basis for API

### Fixed
- bug with calculating review involving

## [1.7.7] - 2024-04-23
### Added
- calculating bad reviews

## [1.7.6] - 2024-04-11
### Added
- support of multiple subscription plans

### Fixed
- seeds

## [1.7.5] - 2024-03-21
### Added
- statistics at welcome page

### Modified
- repository link validation of ending with .git

## [1.7.4] - 2024-03-17
### Fixed
- bug with login to app after invite

## [1.7.3] - 2024-03-09
### Added
- admin page for rendering users
- rendering company users amount at admin page
- notifications about long time review for pull requests
- admin page for rendering notifications
- admin page for rendering webhooks
- admin page for rendering subscribers

### Modified
- refactoring Api::Frontend endpoints

## [1.7.2] - 2024-02-20
### Added
- third pricing plan for enterprise clients
- subscribing for newslist

### Modified
- titles and descriptions for landing page

## [1.7.1] - 2024-02-08
### Added
- basis for E2E tests with Cypress
- limit for premium repositories
- deleting repositories from admin panel

### Modified
- navigation styles for better mobile
- H structure for home page
- validating repository url

## [1.7.0] - 2024-01-25
### Added
- receiving payments in crypto for subscription
- validating payments amount in webhook
- monitoring system with notifications to Bugsnag

### Modified
- welcome page

## [1.6.8] - 2024-01-09
### Added
- admin page for checking company configurations

## [1.6.7] - 2023-12-27
### Added
- changing fetch period
- invites for coworkers

## [1.6.6] - 2023-12-17
### Added
- sending repository insights as notifications

### Modified
- excludes rules configuration

## [1.6.5] - 2023-12-10
### Added
- connecting account to Telegram
- receiving Telegram notifications from bot

## [1.6.4] - 2023-12-03
### Added
- admin routes for repositories
- custom webhooks notifications with insights

## [1.6.3] - 2023-12-03
### Added
- Webhook model

### Modified
- vacation form to modal window
- refresh views

## [1.6.2] - 2023-11-30
### Added
- ignoring entities for Company
- showing next sync time
- tooltip for Insight table
- admin pages

## [1.6.1] - 2023-11-17
### Fixed
- fix rendering insights with unavailable main attribute
- saving configuration

## [1.6.0] - 2023-11-08
### Added
- feedback form
- modal component for simple forms
- removing identities
- page with metrics description

### Modified
- validating access token for companies

## [1.5.9] - 2023-10-31
### Added
- sorting for insights table

### Modified
- use cookies for auth

## [1.5.8] - 2023-10-30
### Modified
- mobile UI

## [1.5.7] - 2023-10-24
### Added
- privacy for companies for hiding insights

### Modified
- running sync job 1 hour before work time start
- creating repository with existing link
- color schema

## [1.5.6] - 2023-10-19
### Fixed
- bug with blank pull_request_exclude_rules
- bug with blank work_time_zone for companies

## [1.5.5] - 2023-10-19
### Added
- frontend time formatting
- js component for rendering alerts

### Modified
- welcome page formatting
- rendering alerts

## [1.5.4] - 2023-10-19
### Added
- notifications layer for export and emails

### Fixed
- saving owner_avatar_url for repository
- running job with including timezone offset

## [1.5.3] - 2023-10-13
### Added
- validating access token format

## [1.5.2] - 2023-10-12
### Added
- pull request exclude rules

### Modified
- more forms and services with container
- import services structure
- text for access token page

## [1.5.1] - 2023-09-26
### Added
- js compression
- responsive styles for guest screens

### Fixed
- achievements calculations

## [1.5.0] - 2023-09-25
### Added
- owner avatar url for repositories

### Modified
- design with tailwind and react
- render source logo as link to repository
- favicon

### Fixed
- bug with rendering repositories for not user companies

## [1.4.4] - 2023-09-21
### Modified
- repositories and access token routes

## [1.4.3] - 2023-09-19
### Added
- how it works page

## [1.4.2] - 2023-09-18
### Added
- container with dependencies injection for common used classes
- repository insights

## [1.4.1] - 2023-09-15
### Added
- operations layer for services run from controllers

### Modified
- rendering insight ratios

## [1.4.0] - 2023-09-14
### Added
- previous insights calculated 1 time per day for faster insight ratio calculations
- LOC insights attributes
- importing LOC data from Github
- generating LOC data for insights

### Modified
- skip using PullRequests::Entity model
- calculating company insights by using repository insights
- updating pull_requests_count counter after import
- remove ratio insights attributes

### Fixed
- calculate insight ratios for average_open_pr_comments field

## [1.3.8] - 2023-09-11
### Added
- query objects
- cache entities data for skipping redundant queries
- form object to interact with users input

### Fixed
- rendering robots file for text/html request
- rendering sitemap zgip file

### Modified
- cache store from memcached to redis

## [1.3.7] - 2023-09-06
### Added
- Emailbutler integration for tracking email delivery

## [1.3.6] - 2023-09-06
### Added
- absolute changes for insights
- clear insights ratios after changing type
- sending emails about repository access errors

### Modified
- rendering access error warnings
- trial period

## [1.3.5] - 2023-06-23
### Added
- trial subscription
- soft deleting user, left only subscriptions

## [1.3.4] - 2023-06-17
### Added
- login through Gitlab
- expiration time to auth tokens
- removing expired users sessions
- attaching more identities to one account

### Modified
- default insight fields

### Fixed
- creating new repositories

## [1.3.3] - 2023-06-12
### Added
- configuring time zones for users and companies
- average time calculations for night working time
- restoring accessability of repositories
- checking accessability of companies
- sending accessability errors to slack and discord

## [1.3.2] - 2023-06-08
### Added
- editing users working time
- ignore user work time for companies

### Modified
- average time calculating based on user working time

### Fixed
- calculations for achievements

## [1.3.1] - 2023-06-06
### Added
- checking accessability of repositories for invalid link and/or access token

## [1.3.0] - 2023-06-03
### Added
- slack notifications after job running

## [1.2.9] - 2023-06-03
### Added
- admin users
- companies and repositories pages pagination
- Github Actions CI integration

### Modified
- better seeds
- achievements rendering

## [1.2.8] - 2023-04-11
### Added
- Discord notifications

## [1.2.7] - 2023-03-30
### Added
- sending company notifications only at work time
- sending company notifications only at weekdays

## [1.2.6] - 2023-03-18
### Modified
- using main attribute for insights sorting

### Fixed
- Import::SyncRepositoriesService, bug with first fetching already closed PRs
- rendering decimal values of Average PR comments column for insights table

## [1.2.5] - 2023-03-18
### Fixed
- creating identities after login

## [1.2.4] - 2023-03-04
### Added
- excluding vacation time from calculating of average time
- editing vacation time for users

## [1.2.3] - 2023-02-26
### Fixed
- awarding for comment creating

## [1.2.2] - 2023-02-25
### Added
- achievements system with Kudos library
- event store for publishing achievement events
- rendering earned achievements
- rendering unreceived achievements

### Modified
- rendering grouped achievements based on award_name

## [1.2.1] - 2023-02-24
### Added
- geometric_mean for average calculations
- new insights attributes - average_open_pr_comments
- rounding average values

### Fixed
- FindAverageService calculations

## [1.2.0] - 2023-02-18
### Added
- configuring Slack webhook url for notifications
- sending insights notifications to Slack
- changing average calculation type
- selecting main insights attribute for sorting

### Modified
- rendering insights data
- generating slack insights payload
- welcome page

## [1.1.6] - 2023-01-25
### Modified
- speed improvements for importing pull requests
- better average time calculations for PRs that were draft

## [1.1.5] - 2023-01-25
### Modified
- for import service skip closed pull requests

## [1.1.4] - 2023-01-24
### Added
- link to support group in Telegram

### Modified
- x2 speed improvements for saving comments data

## [1.1.3] - 2023-01-22
### Added
- rendering/updating insight attributes at configuration edit form
- calculating/rendering insight ratios
- render end time of premium

### Modified
- update gems
- generating insight attributes based on available insight_fields
- rendering insight attributes based on configuration

## [1.1.2] - 2023-01-20
### Added
- deleting account

### Fixed
- rendering entities links to different providers

## [1.1.1] - 2023-01-20
### Added
- saving and rendering last synced_at time for repositories

### Modified
- small SEO changes

## [1.1.0] - 2023-01-20
### Added
- changelog file
- fetching/representing/saving gitlab data
- creating repository with for specific provider and external_id

### Modified
- text at welcome page

## [1.0.0] - 2023-01-18
### Added
- release 1.0.0
