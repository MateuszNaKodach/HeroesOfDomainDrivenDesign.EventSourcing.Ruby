class DwellingReadModel < ApplicationRecord
  validates :id, presence: true, uniqueness: true
  validates :creature_id, presence: true
  validates :available_creatures, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_per_troop, presence: true
end
