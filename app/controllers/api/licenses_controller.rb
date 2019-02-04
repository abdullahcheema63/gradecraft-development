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
    if current_user.license
      return render json: { data: current_user.license, errors: [ "License already exists!" ] }, status: 409
    end
    puts "params: "
    puts params
    l = buy_params
    puts "l:"
    puts l
    license_type = LicenseType.find(l[:license_type_id])
    @license = License.new({
      license_type: license_type,
      user: current_user,
    })
    p = l[:payment]
    p[:amount_usd] = license_type.price_usd
    payment = Payment.new(p)
    return render_error @license.errors.messages.merge(payment.errors.messages), @license.errors.messages.merge(payment.errors.messages) unless (@license.valid? && payment.valid?)
    begin
      @license.start! payment
    rescue Stripe::CardError => e
      puts "Stripe error:"
      puts e
      return render_error e.message, e.message, 500
    rescue => e
      puts "Other error:"
      puts e
      return render_error e.message, e
    else
      render "api/licenses/index", success: true, status: 201
    end
  end

  # PATCH api/licenses
  def update
    @license = current_user.license
    if !@license
      return render json: { data: nil, errors: [ "License not found" ] }, status: 404
    end
    puts "params: "
    puts params
    p = renew_params
    puts "p: "
    puts p
    p[:payment][:amount_usd] = @license.license_type.price_usd
    payment = Payment.new(p[:payment])
    return render_error payment.errors.messages, payment.errors.messages unless payment.valid?
    begin
      @license.renew! payment
    rescue Stripe::CardError => e
      puts "Stripe error:"
      puts e
      return render_error e.message, e.message, 500
    rescue => e
      puts "Other error:"
      puts e
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
    [ :first_name, :last_name, :organization, :phone, :addr1, :addr2, :country, :state, :city, :zip, :stripe_token ]
  end

  def buy_params
    params.permit(:license_type_id, payment: payment_permitted_params)
  end

  def renew_params
    params.permit(payment: payment_permitted_params)
  end
end