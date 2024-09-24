class CreateDwellingReadModels < ActiveRecord::Migration[7.2]
  def change
    ::Heroes::CreatureRecruitment::DwellingReadModel::Migration.new.change
  end
end
