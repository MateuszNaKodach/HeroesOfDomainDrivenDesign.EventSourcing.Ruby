require "rails_event_store"
require "heroes/shared_kernel/resources"

module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)

    class BuildDwellingCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::CreatureRecruitment::DwellingBuilt,
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt,
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.method(:from_domain),
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.method(:to_domain)
        )
      end

      def call(command)
        @application_service.call(command)
      end
    end
  end
end

module EventStore
  module Heroes
    module CreatureRecruitment
      DwellingBuilt = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.new(
            data: {
              dwelling_id: domain_event.dwelling_id,
              creature_id: domain_event.creature_id,
              cost_per_troop: {
                resources: domain_event.cost_per_troop.resources
              }
            }
          )
        end

        def self.to_domain(store_event)
          data = store_event.data.deep_symbolize_keys
          ::Heroes::CreatureRecruitment::DwellingBuilt.new(
            dwelling_id: data[:dwelling_id],
            creature_id: data[:creature_id],
            cost_per_troop: ::Heroes::SharedKernel::Resources::Cost.new(store_event.data[:cost_per_troop][:resources])
          )
        end
      end
    end
  end
end
