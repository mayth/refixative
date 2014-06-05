class PlayersController < ApplicationController
  before_action :set_player, only: %i(show)

  def new
  end

  def create
  end

  def show
  end

  private

  def set_player
    @player = Player.find_by(id: params[:id])
    # find with PlayerID ('RB-XXXX-XXXX')
    unless @player
      @player = Player.find_by(pid: params[:id].upcase)
      fail ActiveRecord::RecordNotFound unless @player
    end
  end
end
