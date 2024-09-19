class CreateDwellingReadModels < ActiveRecord::Migration[7.2]
  def change
    create_table :dwelling_read_models, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :creature_id, null: false
      t.integer :available_creatures, null: false
      t.jsonb :cost_per_troop, null: false

      t.timestamps
    end
  end
end
