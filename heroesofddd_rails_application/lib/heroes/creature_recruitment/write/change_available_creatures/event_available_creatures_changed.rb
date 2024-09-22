module Heroes
  module CreatureRecruitment
    AvailableCreaturesChanged = Data.define(:dwelling_id, :creature_id, :changed_to)
  end
end
