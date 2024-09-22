require "rails_event_store"

module Heroes
  module CreatureRecruitment
    RecruitCreature = Data.define(:dwelling_id, :creature_id, :recruit)

    class RecruitCreatureCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::CreatureRecruitment::CreatureRecruited,
          ::EventStore::Heroes::CreatureRecruitment::CreatureRecruited,
          ::EventStore::Heroes::CreatureRecruitment::CreatureRecruited.method(:from_domain),
          ::EventStore::Heroes::CreatureRecruitment::CreatureRecruited.method(:to_domain)
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
      CreatureRecruited = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::CreatureRecruitment::CreatureRecruited.new(
            data: {
              dwelling_id: domain_event.dwelling_id,
              creature_id: domain_event.creature_id,
              recruited: domain_event.recruited,
              total_cost: domain_event.total_cost
            }
          )
        end

        def self.to_domain(store_event)
          @data = store_event.data
          ::Heroes::CreatureRecruitment::CreatureRecruited.new(
            dwelling_id: @data.fetch(:dwelling_id),
            creature_id: @data.fetch(:creature_id),
            recruited: @data.fetch(:recruited),
            total_cost: @data.fetch(:total_cost),
          )
        end
      end
    end
  end
end
