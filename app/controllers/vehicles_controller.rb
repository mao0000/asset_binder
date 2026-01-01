class VehiclesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  private

  def after_sign_in_path_for(resource)
    root_path
  end
end