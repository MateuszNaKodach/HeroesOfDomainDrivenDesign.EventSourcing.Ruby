class CreateCurrentDateReadModels < ActiveRecord::Migration[7.2]
  def change
    ::Heroes::Calendar::CurrentDateReadModel::Migration.new.change
  end
end
