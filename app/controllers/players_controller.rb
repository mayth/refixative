class PlayersController < ApplicationController
  require 'securerandom'

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
    @register_token = SecureRandom.uuid
    Rails.cache.write(@register_token,
      { profile: profile, musics: musics },
      expires_in: 30.minutes
    )
    player = Player.find_by(pid: profile[:id])
    player.check_updates musics if player
    is_new_player = player.nil?
    render :confirm,
      locals: { profile: profile, musics: musics, is_new_player: is_new_player }
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
