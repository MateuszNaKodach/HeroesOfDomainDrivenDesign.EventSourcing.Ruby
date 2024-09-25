# README

## How to run?

Install ruby on your machine and Rails:
`gem install rails`

0. `bundle install`
1. `docker compose up`
2. `rails db:create`
3. `rails db:migrate`
4. `rails server`

Fixing format errors:
`rubocop --autocorrect`

## Routes:
- http://127.0.0.1:3000/heroes/creature_recruitment/dwellings

You can run the server with test env: `rails server -e test`


## Claude.ai
Generate code in one file for LLM context:
`npx ai-digest --whitespace-removal `

## Assumptions:
- Domain Events do not contain ValueObjects. Be

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
