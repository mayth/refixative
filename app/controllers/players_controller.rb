class PlayersController < ApplicationController
  before_action :set_player, only: %i(show)

  # GET upload
  def upload
  end

  # POST upload
  def parse
    parser = Parser::Groovin.new
    profile = parser.parse_profile(upload_params[:profile].read)
    musics = upload_params[:musics].map do |x|
      parser.parse_music(x.read)
    end
    musics.flatten!
    render json: { result: 'success', profile: profile, musics: musics }
  end

  # GET confirm
  def confirm
  end

  # POST register
  def register
  end

  def show
  end

  private

  def upload_params
    params.require(:player).permit(:profile, musics: [])
  end

  def set_player
    @player = Player.find_by(id: params[:id])
    # find with PlayerID ('RB-XXXX-XXXX')
    unless @player
      @player = Player.find_by(pid: params[:id].upcase)
      fail ActiveRecord::RecordNotFound unless @player
    end
  end
end
