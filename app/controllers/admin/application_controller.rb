class Admin::ApplicationController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_page_id

  private

  def set_page_id
    @page_id = 'admin'
  end
end