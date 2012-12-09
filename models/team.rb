class Team < Sequel::Model
  unrestrict_primary_key
  one_to_one :player

  def Team.update_or_create(prof)
    team = Team.find(:id => prof[:team][:id])
    if team
      team.name = prof[:team][:name]
    else
      team = Team.new(id: prof[:team][:id], name: prof[:team][:name])
    end
    team.save
    team
  end
end
