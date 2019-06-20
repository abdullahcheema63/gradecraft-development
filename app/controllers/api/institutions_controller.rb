# rubocop:disable AndOr
class API::InstitutionsController < ApplicationController
  before_action :ensure_admin?, only: [:index, :instructors]

  # GET api/institutions
  def index
    @institutions = Institution.order_by_name
  end
end
