class Admin::PlayersController < Admin::ApplicationController
  before_action :set_player, only: %i(show edit update destroy)

  def index
    @page_id += '_players_index'
  end

  def new
    @page_id += '_players_new'
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    respond_to do |format|
      if @player.save
        format.html { redirect_to admin_player_path(@player), notice: 'Created.' }
        format.json { render action: 'show', status: :created, location: admin_player_path(@player) }
      else
        format.html { render action: 'new' }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @page_id += '_players_show'
    respond_to do |format|
      format.html { render 'show' }
    end
  end

  def edit
    @page_id += '_players_edit'
  end

  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to admin_player_path(@player), notice: 'Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.html { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to admin_players_path }
      format.json { head :no_content }
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    x = params.require(:player).permit(
      :pid, :name, :pseudonym, :level, :grade, :comment, :play_count,
      :refle, :total_point, :last_play_datetime, :last_play_place)
    x.reject { |_, v| v.blank? }
  end
end
