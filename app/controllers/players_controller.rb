class PlayersController < ApplicationController
  require 'securerandom'
  require 'parser/groovin'

  before_action :set_player, only: [:show]

  # GET upload
  def upload
  end

  # POST upload
  def parse
    parser = ::GroovinParser.new
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
    updates, new_plays = player.check_updates musics if player
    is_new_player = player.nil?
    render :confirm,
      locals: {
        profile: profile,
        musics: musics, updates: updates, new_plays: new_plays,
        is_new_player: is_new_player
      }
  end

  # GET confirm
  def confirm
  end

  # POST register
  def register
    stored_data = Rails.cache.read(register_params[:token])
    fail 'stored data matched the given register token is not found.' unless stored_data
    update_time = Time.now
    player = Player.update_profile(stored_data[:profile], update_time)
    unless player.valid?
      redirect_to upload_players_path,
        alert: player.map(&:errors).map(&:full_messages)
    end
    updated_scores = player.update_score(stored_data[:musics], update_time)
    if updated_scores.all?(&:valid?)
      redirect_to player_path(id: player.pid),
        notice: I18n.t('players.register.flash.success')
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
    params.require(:register).permit(:token)
  end

  def set_player
    @player = Player.find_by(id: params[:id]) || Player.find_by(pid: params[:id].upcase)
    fail ActiveRecord::RecordNotFound unless @player
  end
end
