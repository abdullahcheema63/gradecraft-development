class API::LicensesController < ApplicationController
  skip_before_action :require_course_membership
  skip_before_action :verify_authenticity_token # Remove me!

  # GET api/licenses
  def index
    @license = License.find_by(user_id: current_user.id)
    if !@license
      return render json: { data: nil, errors: [ "License not found" ] }, status: 404
    end
    @license_types = LicenseType.all
    @courses = get_courses_where_professor
    @payments = @license.payments.all
  end

  def license_type_options
    @license_types = LicenseType.all
  end

  # POST api/licenses
  def create
    if current_user.license
      return render json: { data: current_user.license, errors: [ "License already exists!" ] }, status: 409
    end
    l = buy_params
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
      return render_error e.message, e.message, 500
    rescue => e
      return render_error e.message, e
    else
      @license_types = LicenseType.all
      @courses = get_courses_where_professor
      @payments = @license.payments.all
      render "api/licenses/index", success: true, status: 201
    end
  end

  # PUT api/licenses/edit
  def edit
    @license = current_user.license
    if !@license
      return render json: { data: nil, errors: [ "License not found" ] }, status: 404
    end
    p = edit_params
    if @license.max_courses && p[:courses].length > @license.max_courses
      return render json: { data: { max_courses: @license.max_courses }, errors: [ "Max courses exceeded" ] }, status: 400
    end
    @license.courses = p[:courses].map {|c| Course.find c }
    professor_courses = get_courses_where_professor
    @license.courses.each do |c|
      if !professor_courses.include? c
        return render_error "User is not a professor in course: " + c.id.to_s, c, 401
      end
    end
    if @license.save
      @license_types = LicenseType.all
      @courses = get_courses_where_professor
      @payments = @license.payments.all
      return render "api/licenses/index", success: true, status: 200
    else
      return render_error license.errors, license.errors, 400
    end
  end

  # PATCH api/licenses
  def update
    @license = current_user.license
    if !@license
      return render json: { data: nil, errors: [ "License not found" ] }, status: 404
    end
    p = renew_params
    p[:payment][:amount_usd] = @license.license_type.price_usd
    payment = Payment.new(p[:payment])
    return render_error payment.errors.messages, payment.errors.messages unless payment.valid?
    begin
      @license.renew! payment
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      render_error e.message, e
    else
      @license_types = LicenseType.all
      @courses = get_courses_where_professor
      @payments = @license.payments.all
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

  def edit_params
    params.permit(courses: [])
  end

  def get_courses_where_professor
    current_user.course_memberships.where(role: "professor").map{|cm| cm.course}
  end
end
