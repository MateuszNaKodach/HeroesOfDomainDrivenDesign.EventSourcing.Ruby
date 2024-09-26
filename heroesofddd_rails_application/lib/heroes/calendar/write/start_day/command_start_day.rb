module Heroes
  module Calendar
    StartDay = Data.define(:month, :week, :day)

    class StartDayCommandHandler
      def initialize(application_service, event_registry)
        @application_service = application_service
        # We'll add event mapping in a later step
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
      DayStarted = Class.new(RubyEventStore::Event) do
        def self.from_domain(domain_event)
          new(data: {
            month: domain_event.month,
            week: domain_event.week,
            day: domain_event.day
          })
        end

        def self.to_domain(store_event)
          data = store_event.data.deep_symbolize_keys
          ::Heroes::Calendar::DayStarted.new(
            month: data[:month],
            week: data[:week],
            day: data[:day]
          )
        end
      end
    end
  end
end