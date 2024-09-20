module Heroes
  module CreatureRecruitment
    class DwellingReadModel < ApplicationRecord
      validates :id, presence: true, uniqueness: true
      validates :creature_id, presence: true
      validates :available_creatures, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :cost_per_troop, presence: true
    end

  class DwellingProjection
    def call(event_store, event_type_mapper)
      infra_event_class = event_type_mapper.domain_to_store_class(DwellingBuilt)
      event_store.subscribe(OnDwellingBuilt, to: [ infra_event_class ])
    end
  end

  class OnDwellingBuilt
    def call(event)
      id = event.data.dwelling_id
      creature_id = event.data.creature_id
      available_creatures = 4 # for a while
      cost_per_troop = event.data.cost_per_troop
      dwelling = DwellingReadModel.create(
        id: id,
        creature_id: creature_id,
        available_creatures: available_creatures,
        cost_per_troop: cost_per_troop)
      dwelling.save!
    end
  end
  end
end
