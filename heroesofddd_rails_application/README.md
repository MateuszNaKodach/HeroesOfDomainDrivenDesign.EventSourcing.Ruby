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
- http://127.0.0.1:3000/heroes/games/fcc8f601-76cb-4b5a-972d-b7431303f69a/creature_recruitment/dwellings/cecc4307-e940-4ef2-8436-80c475729938

You can run the server with test env: `rails server -e test`


## Claude.ai
Generate code in one file for LLM context:
`npx ai-digest --whitespace-removal`


3 things:
- when first day -> week symbol
- first day -> increase dwelling population / renew - increase for simplicity
- calendar read model

add UI to passing days in calendar, show astrologers on first week day