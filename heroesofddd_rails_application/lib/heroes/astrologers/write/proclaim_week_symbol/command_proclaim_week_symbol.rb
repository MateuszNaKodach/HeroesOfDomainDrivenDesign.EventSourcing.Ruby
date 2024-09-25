require "rails_event_store"

module Heroes
  module Astrologers
    ProclaimWeekSymbol = Data.define(:month, :week, :week_of, :growth)

    class ProclaimWeekSymbolCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::Astrologers::WeekSymbolProclaimed,
          ::EventStore::Heroes::Astrologers::WeekSymbolProclaimed,
          ::EventStore::Heroes::Astrologers::WeekSymbolProclaimed.method(:from_domain),
          ::EventStore::Heroes::Astrologers::WeekSymbolProclaimed.method(:to_domain)
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
    module Astrologers
      WeekSymbolProclaimed = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::Astrologers::WeekSymbolProclaimed.new(
            data: {
              month: domain_event.month,
              week: domain_event.week,
              week_of: domain_event.week_of,
              growth: domain_event.growth
            }
          )
        end

        def self.to_domain(store_event)
          data = store_event.data.deep_symbolize_keys
          ::Heroes::Astrologers::WeekSymbolProclaimed.new(
            month: data[:month],
            week: data[:week],
            week_of: data[:week_of],
            growth: data[:growth],
          )
        end
      end
    end
  end
end
