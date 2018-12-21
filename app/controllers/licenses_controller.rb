require 'date'

class LicensesController < ApplicationController
  def show
    @license = License.find_by(id: params[:id])
  end

  def new
    @license = License.new
    @license.payments.push(Payment.new)
  end

  def create
    p = license_params
    p[:user] = current_user
    p[:expires] = DateTime.now + 8.months
    license_type = LicenseType.find_by(id: p[:license_type_id])
    p[:max_courses] = license_type.default_max_courses
    p[:max_students] = license_type.default_max_students
    p[:payments_attributes]["0"][:source] = "Stripe"
    p[:payments_attributes]["0"][:amount_usd] = license_type.price_usd
    @license = License.create(p)
    return new_errors unless @license.valid?
    begin
      @license.payments.last.charge_stripe(p[:payments_attributes]["0"][:stripe_token])
    rescue Stripe::CardError => e
      return new_alert e.message
    end
    if @license.save
      render "show", success: true, status: 201
    else
      new_errors
    end
  end

  private

  def new_alert(alert)
    render action: "new", flash: {
      alert: alert
    }
  end

  def new_errors
    return new_alert @license.errors.full_messages.to_sentence
  end

  def license_params
    p = params.require(:license).permit(:license_type_id, payments_attributes: [ :first_name, :last_name, :organization, :phone, :addr1, :addr2, :country, :state, :zip, :stripe_token ])
  end
end
