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
      infra_event = event_type_mapper.
      event_store.subscribe(OnDwellingBuilt, to: [ infra_event ])
    end

    def create_infra_event_class(name)
      @infra_module = Object.const_get("EventStore::Heroes::CreatureRecruitment")
      safe_const_set(@infra_module, name, Class.new(RailsEventStore::Event))
    end

    def safe_const_set(mod, const_name, value)
      mod.const_set(const_name, value) unless mod.const_defined?(const_name)
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
end
