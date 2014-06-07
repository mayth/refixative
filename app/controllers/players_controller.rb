class PlayersController < ApplicationController
  require 'securerandom'

  before_action :set_player, only: [:show]

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
    stored_data = Rails.cache.read(register_params[:register_token])
    fail 'stored data matched the given register token is not found.' unless stored_data
    player = Player.update_profile(stored_data[:profile])
    updated_scores = player.update_score(stored_data[:musics])
    if updated_scores.all?(&:valid?)
      redirect_to player_path(id: player.pid)
    else
      redirect_to upload_players_path,
        alert: updated_scores.reject(&:valid?).map(&:errors).map(&:full_messages)
    end
  end

  def show
  end

  private

  def upload_params
    params.require(:player).permit(:profile, musics: [])
  end

  def register_params
    params.permit(:register_token)
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
