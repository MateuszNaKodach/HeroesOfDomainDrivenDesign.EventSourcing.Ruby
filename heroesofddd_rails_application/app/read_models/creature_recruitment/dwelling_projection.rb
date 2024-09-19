module Heroes
  module CreatureRecruitment
    class DwellingReadModel < ApplicationRecord
      validates :id, presence: true, uniqueness: true
      validates :creature_id, presence: true
      validates :available_creatures, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :cost_per_troop, presence: true
    end
  end

  class DwellingProjection
    def call(event_store)
      event_store.subscribe(OnDwellingBuilt, to: [ DwellingBuilt ])
    end
  end

  class OnDwellingBuilt
    def call(event)
      id = event.data.fetch(:dwelling_id)
      creature_id = event.data.fetch(:creature_id)
      available_creatures = event.data.fetch(:available_creatures)
      cost_per_troop = event.data.fetch(:cost_per_troop)
      dwelling = DwellingReadModel.create(
        id: id,
        creature_id: creature_id,
        available_creatures: available_creatures,
        cost_per_troop: cost_per_troop) # todo: transform to domain event before?
      dwelling.save!
    end
  end
end
