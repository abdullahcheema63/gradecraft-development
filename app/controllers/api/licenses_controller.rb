class API::LicensesController < ApplicationController
  skip_before_action :require_course_membership

  # GET api/licenses
  def index
    @license = License.find_by(user_id: current_user.id)
    if !@license
      render json: { data: nil, errors: [ "License not found" ] }, status: 404
    end
  end

  # POST api/licenses
  def create
    puts "params: "
    puts params
    l = buy_params
    puts "l:"
    puts l
    license_type = LicenseType.find(l[:license_type_id])
    p = l[:payment]
    p[:amount_usd] = license_type.price_usd
    @license = License.new({
      license_type: license_type,
      user: current_user,
      payments: [ Payment.new(p) ],
    })
    return render_error e.message, @license.errors.messages unless @license.valid?
    begin
      @license.start!
      render "api/licenses/index", success: true, status: 201
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      return render_error e.message, e
    end
  end

  # PATCH api/licenses
  def update
    puts "params: "
    puts params
    p = renew_params
    puts "p: "
    puts p
    @license = current_user.license
    p[:payment][:amount_usd] = @license.license_type.price_usd
    payment = Payment.new(p[:payment])
    begin
      @license.renew! payment
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      render_error e.message, e
    else
      render "api/licenses/index", success: true, status: 200
    end
  end

  private

  def render_error(message, errors, status=400)
    render json: {
      message: message,
      errors: errors,
      success: false
    }, status: status
  end

  def payment_permitted_params 
    [ :first_name, :last_name, :organization, :phone, :addr1, :addr2, :country, :state, :zip, :stripe_token ]
  end

  def buy_params
    params.require([:payment, :license_type_id]).permit(payment_attributes: payment_permitted_params)
  end

  def renew_params
    params.require(:payment).permit(payment_attributes: payment_permitted_params)
  end
end