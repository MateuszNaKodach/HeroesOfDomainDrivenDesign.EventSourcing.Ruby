# Heroes of Domain-Driven Design (Ruby)

Shows how to use Domain-Driven Design, Event Storming, Event Modeling and Event Sourcing in Heroes of Might & Magic III domain.

- [Read the Heroes of Domain-Driven Design series on LinkedIn]( https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7208819112179908609)

This project probably won't be fully-functional HOMM3 engine implementation, because it's done for educational purposes.
If you'd like to talk with me about mentioned development practices fell free to contact on [linkedin.com/in/mateusznakodach/](https://www.linkedin.com/in/mateusznakodach/).

## 🚀 How to run the project locally?

1. `cd heroesofddd_rails_application`
2. `docker compose up`
3. `bundle install`
2. `rails db:drop db:create db:migrate db:seed` - (re)creates database and seed with example data
7. `rails server`

Go to the url and play around with the app: 
- Creature Recruitment: http://127.0.0.1:3000/heroes/games/fcc8f601-76cb-4b5a-972d-b7431303f69a/creature_recruitment/dwellings/cecc4307-e940-4ef2-8436-80c475729938
Recruit Angels and click "Next day" in order to wait for the astrologers proclamation of the week symbol.

## 🧱 Modules

Modules (mostly designed using Bounded Context heuristic) are designed and documented on EventModeling below.
Each slice in a module is in certain color which shows the progress:
- green -> completed
- yellow -> implementation in progress
- red -> to do 
- grey -> design in progress

List of modules you can see in `lib/heroes` directory of the Rails application.
```
heroes/
├── astrologers
├── calendar
├── creature_recruitment
```

Each domain-focused module follows Vertical-Slice Architecture of three possible types: write, read and automation following Event Modeling nomenclature.

### 👾 Creature Recruitment

![EventModeling_Module_CreatureRecruitment.png](docs/images/EventModeling_Module_CreatureRecruitment.png)

Slices:
- Write: `BuildDwelling` -> `DwellingBuilt`
- Write: `IncreaseAvailableCreatures` -> `AvailableCreaturesChanged`
- Write: `RecruitCreatured` -> `CreatureRecruited`

### 🧙 Astrologers

![EventModeling_Module_Astrologers.png](docs/images/EventModeling_Module_Astrologers.png)

Slices:
- Write: `ProclaimWeekSymbol` -> `WeekSymbolProclaimed`
- Automation: When week symbol proclaimed then increase dwellings available creatures if dwelling creature == symbol

### 📅 Calendar

![EventModeling_Module_Calendar.png](docs/images/EventModeling_Module_Calendar.png)

Slices:
- Write: `StartDay` -> `DayStarted`
- Write: `FinishDay` -> `DayFinished`
- Automation: When week started (DayStarted with day == 1) then proclaim week symbol.

## 🤖 Working with AI Large Language Models:
If you'd like to use the whole source code as your prompt context generate codebase file by:
`npx ai-digest --whitespace-removal`

## 🧪 Testing
Tests using Real postgres Event Store, follows the approach: 
- write slice: given(events) -> when(command) -> then(events)
- read slice: given(events) -> then(read model)
- automation: when(event, state?) -> then(command)

```ruby
def test_given_dwelling_with_3_creature_when_recruit_2_creature_then_success
  # given
  given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
  given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 3))

  # when
  recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 2)
  execute_command(recruit_creature, @app_context)

  # then
  expected_cost = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 6000 ], [ :GEM, 2 ])
  expected_event = CreatureRecruited.new(@dwelling_id, @creature_id, 2, expected_cost)
  then_domain_event(@stream_name, expected_event)
end
```


-------

### 💼 Hire me

If you'd like to hire me for Domain-Driven Design and/or Event Sourcing projects I'm available to work with:
Kotlin, Java, C#, Ruby and TypeScript.
Please reach me out on LinkedIn [linkedin.com/in/mateusznakodach/](https://www.linkedin.com/in/mateusznakodach/).