module BuildingBlocks
  module Application
    Metadata = Data.define(:game_id) do
      def self.for_game(game_id)
        new(game_id)
      end

    end
  end
end
