class API::Licenses::LicensesController < ApplicationController
  # GET api/licenses
  def index
    @license = current_user.license
  end

  # POST api/licenses
  def create
    l = buy_params
    l[:user] = current_user
    license_type = LicenseType.find_by(id: l[:license_type_id])
    l[:expires] = DateTime.now + license_type.default_duration_months.months
    l[:max_courses] = license_type.default_max_courses
    l[:max_students] = license_type.default_max_students
    p = l[:payments_attributes]["0"]
    p[:source] = "Stripe"
    p[:amount_usd] = license_type.price_usd
    @license = License.create(l)
    return render_error e.message, @license.errors.messages unless @license.valid?
    begin
      charge = @license.payments.last.charge_stripe(p[:stripe_token])
      if @license.save
        render "api/licenses/index", success: true, status: 201
      else
        charge.refund
        errors "new"
      end
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    end
  end

  # PATCH api/licenses
  def update
    l = renew_params
    @license = current_user.license
    p = l[:payments_attributes]["0"]
    p[:source] = "Stripe"
    p[:amount_usd] = @license.license_type.price_usd
    payment = Payment.create(p)
    begin
      @license.renew! payment, p[:stripe_token]
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      render_error e.message, @license.errors.messages
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
end