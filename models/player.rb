class Player < Sequel::Model
  unrestrict_primary_key
  one_to_one :scoreset
  many_to_one :team

  def Player.update_or_create(prof)
    team = prof[:team] ? Team.update_or_create(prof) : nil
    player = Player.find(:id => prof[:id].to_i)
    if player
      player.pseudonym = prof[:pseudonym]
      player.name = prof[:name]
      player.comment = prof[:comment]
      player.team = team
      player.play_count = prof[:play_count]
      player.stamp = prof[:stamp]
      player.onigiri = prof[:onigiri]
      player.last_play_date = prof[:last_play_date]
      player.last_play_shop = prof[:last_play_shop]
    else
      player = Player.new(
        id: prof[:id].to_i,
        pseudonym: prof[:pseudonym],
        name: prof[:name],
        comment: prof[:comment],
        team: team,
        play_count: prof[:play_count],
        stamp: prof[:stamp],
        onigiri: prof[:onigiri],
        last_play_date: prof[:last_play_date],
        last_play_shop: prof[:last_play_shop],
        latest_scoreset_id: 0)
    end
    player.save
    player
  end

  def create_scoreset(song, registered_at)
    scoreset = Scoreset.new_scores(self, song, registered_at)
    self.latest_scoreset_id = scoreset.id
    self.save
    self
  end
end
