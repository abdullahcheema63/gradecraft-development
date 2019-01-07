require 'date'

class LicensesController < ApplicationController
  def index
    @license = current_user.license
    if !@license
      redirect_to({ action: :new })
    end
  end

  # Buy
  def new
    @license = License.new
    @license.payments = [Payment.new]
  end

  # Buy Submit
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
    return errors "new" unless @license.valid?
    begin
      charge = @license.payments.last.charge_stripe(p[:stripe_token])
      if @license.save
        render "index", success: true, status: 201
      else
        charge.refund
        errors "new"
      end
    rescue Stripe::CardError => e
      return alert "new", e.message
    end
  end

  # Renew
  def edit
    existing = current_user.license
    @license = License.new
    @license.license_type_id = existing.license_type_id
    @license.payments = [Payment.new]
  end

  # Renew Submit
  def update
    l = renew_params
    @license = current_user.license
    p = l[:payments_attributes]["0"]
    p[:source] = "Stripe"
    p[:amount_usd] = @license.license_type.price_usd
    payment = Payment.create(p)
    begin
      charge = @license.renew! payment, p[:stripe_token]
      if @license.save
        render "index", success: true, status: 200
      else
        charge.refund
        errors "edit"
      end
    rescue Stripe::CardError => e
      return alert "edit", e.message
    end
  end

  private

  def alert(action, alert)
    render action: action, flash: {
      alert: alert
    }
  end

  def errors(action)
    return alert action @license.errors.full_messages.to_sentence
  end

  def payment_permitted_params 
    [ :first_name, :last_name, :organization, :phone, :addr1, :addr2, :country, :state, :zip, :stripe_token ]
  end

  def buy_params
    params.require(:license).permit(:license_type_id, payments_attributes: payment_permitted_params)
  end

  def renew_params
    params.require(:license).permit(payments_attributes: payment_permitted_params)
  end

  def payment_params
    params.require(:payment).permit(*payment_permitted_params)
  end
end
