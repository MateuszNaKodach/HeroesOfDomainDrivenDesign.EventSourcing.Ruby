module Heroes
  module Astrologers
    module Presentation
      class WeekSymbolModal
        def call(event)
          Turbo::StreamsChannel.broadcast_append_later_to(
            "week_symbol_modal",
            target: "week_symbol_modal",
            partial: "heroes/astrologers/week_symbol_modal",
            locals: {
              month: event.data[:month],
              week: event.data[:week],
              week_of: event.data[:week_of],
              growth: event.data[:growth]
            }
          )
        end
      end
    end
  end
end
