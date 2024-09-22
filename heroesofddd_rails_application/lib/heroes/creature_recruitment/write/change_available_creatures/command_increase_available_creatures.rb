require "rails_event_store"

module Heroes
  module CreatureRecruitment
    IncreaseAvailableCreatures = Data.define(:dwelling_id, :creature_id, :increase_by)

    class IncreaseAvailableCreaturesCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::CreatureRecruitment::AvailableCreaturesChanged,
          ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged,
          ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged.method(:from_domain),
          ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged.method(:to_domain)
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
      AvailableCreaturesChanged = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(
            data: {
              dwelling_id: domain_event.dwelling_id,
              creature_id: domain_event.creature_id,
              changed_to: domain_event.changed_to
            }
          )
        end

        def self.to_domain(store_event)
          @data = store_event.data
          ::Heroes::CreatureRecruitment::AvailableCreaturesChanged.new(
            dwelling_id: @data.fetch(:dwelling_id),
            creature_id: @data.fetch(:creature_id),
            changed_to: @data.fetch(:changed_to)
          )
        end
      end
    end
  end
end
