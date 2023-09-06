# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
