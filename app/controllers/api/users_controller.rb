# rubocop:disable AndOr
class API::UsersController < ApplicationController
  before_action :ensure_admin?, only: :index

  # GET api/users
  def index
    @users = User.all
  end
end
