module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop) do
      def event_type
        "creature-recruitment:dwelling-built"
      end
    end

    class BuildDwellingCommandHandler
      def initialize(event_store)
        @event_store = event_store
      end

      def call(command)

      end

    end
  end
end
