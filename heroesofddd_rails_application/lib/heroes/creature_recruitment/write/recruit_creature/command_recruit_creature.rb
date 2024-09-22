module Heroes
  module CreatureRecruitment
    RecruitCreature = Data.define(:dwelling_id, :creature_id, :recruit)

    class RecruitCreatureCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::CreatureRecruitment::RecruitCreature,
          ::EventStore::Heroes::CreatureRecruitment::RecruitCreature,
          ::EventStore::Heroes::CreatureRecruitment::RecruitCreature.method(:from_domain),
          ::EventStore::Heroes::CreatureRecruitment::RecruitCreature.method(:to_domain)
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
      RecruitCreature = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::CreatureRecruitment::RecruitCreature.new(
            data: {
              dwelling_id: domain_event.dwelling_id,
              creature_id: domain_event.creature_id,
              recruit: domain_event.recruit
            }
          )
        end

        def self.to_domain(store_event)
          @data = store_event.data
          ::Heroes::CreatureRecruitment::RecruitCreature.new(
            dwelling_id: @data.fetch(:dwelling_id),
            creature_id: @data.fetch(:creature_id),
            recruit: @data.fetch(:recruit)
          )
        end
      end
    end
  end
end
