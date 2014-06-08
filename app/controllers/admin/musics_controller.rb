class Admin::MusicsController < Admin::ApplicationController
  before_action :set_music, only: %i(show edit update destroy)

  def index
  end

  def new
    @music = Music.new
  end

  def create
    @music = Music.new(music_params)
    respond_to do |format|
      if @music.save
        format.html { redirect_to admin_music_path(@music), notice: 'Created.' }
        format.json { render action: 'show', status: :created, location: admin_music_path(@music) }
      else
        format.html { render action: 'new' }
        format.json { render json: @music.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @scores = Score.where(music: @music)
  end

  def edit
  end

  def update
    respond_to do |format|
      if @music.update(music_params)
        format.html { redirect_to admin_music_path(@music), notice: 'Updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.html { render json: @music.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @music.destroy
    respond_to do |format|
      format.html { redirect_to admin_musics_path }
      format.json { head :no_content }
    end
  end

  private

  def set_music
    @music = Music.find(params[:id])
  end

  def music_params
    x = params.require(:music).permit(
      :name, :basic_lv, :medium_lv, :hard_lv, :special_lv, :added_at)
    x.reject { |_, v| v.blank? }
  end
end
