#coding: utf-8

get '/teams' do
  teams = Team.order(:id)
  @teams = Array.new
  teams.each do |t|
    @teams << {
      id: t.id,
      name: t.name,
      members: Player.filter(team_id: t.id).count
    }
  end
  @page_title = 'チーム一覧'
  haml :teams
end

get '/team/:id' do
  @team = Team.find(id: params[:id])
  halt 404 unless @team
  @members = Player.filter(team_id: @team.id).order(:id)
  @page_title = "#{@team.name}のチームデータ"
  haml :team
end
