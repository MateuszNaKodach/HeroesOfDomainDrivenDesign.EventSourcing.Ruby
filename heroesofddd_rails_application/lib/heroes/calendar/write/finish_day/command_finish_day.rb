require_relative "../calendar"

module Heroes
  module Calendar
    FinishDay = Data.define(:month, :week, :day)

    class FinishDayCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        event_registry.map_event_type(
          Heroes::Calendar::DayFinished,
          EventStore::Heroes::Calendar::DayFinished,
          EventStore::Heroes::Calendar::DayFinished.method(:from_domain),
          EventStore::Heroes::Calendar::DayFinished.method(:to_domain)
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
    module Calendar
      DayFinished = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          new(data: {
            month: domain_event.month,
            week: domain_event.week,
            day: domain_event.day
          })
        end

        def self.to_domain(store_event)
          data = store_event.data.deep_symbolize_keys
          ::Heroes::Calendar::DayFinished.new(
            month: data[:month],
            week: data[:week],
            day: data[:day]
          )
        end
      end
    end
  end
end
