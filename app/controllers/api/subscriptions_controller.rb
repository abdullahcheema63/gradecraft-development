class API::SubscriptionsController < ApplicationController
  skip_before_action :require_course_membership

  # GET api/subscriptions
  def index
    @subscription = Subscription.find_by(user_id: current_user.id)
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    @courses = get_courses_where_professor
    @payments = @subscription.payments.all
  end

  def billing_scheme_tiers
    @billing_schemes = BillingScheme.all
  end

  # POST api/subscriptions
  def create
    if current_user.subscription
      return render json: { data: current_user.subscription, errors: [ "Subscription already exists!" ] }, status: 409
    end

    l = buy_params
    license_type = LicenseType.find(l[:license_type_id])
    #Param for license_type_id ??

    @subscription = Subscription.new({
      billing_scheme: billing_scheme,
      user: current_user,
    })
    p = l[:payment]
    p[:amount_usd] = billing_scheme.price_usd
    #Change this to have the determined total price from price_per_course and num courses on subscription


    payment = Payment.new(p)
    return render_error @subscription.errors.messages.merge(payment.errors.messages), @subscription.errors.messages.merge(payment.errors.messages) unless (@subscription.valid? && payment.valid?)
    begin
      @subscription.start! payment
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      return render_error e.message, e
    else
      @billing_schemes = BillingScheme.all
      #probably wont need this for the API to run ??

      @courses = get_courses_where_professor
      @payments = @subscription.payments.all
      render "api/subscriptions/index", success: true, status: 201
    end
  end

  # PUT api/licenses/edit
  def edit
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    p = edit_params

    #NOT NEEDED because there is no more "max courses" for a subscription
    #needed this the license_type / package limit on a course
    #
    #
    #if @subscription.max_courses && p[:courses].length > @subscription.max_courses
    #  return render json: { data: { max_courses: @license.max_courses }, errors: [ "Max courses exceeded" ] }, status: 400
    #end

    @subscription.courses = p[:courses].map {|c| Course.find c }
    professor_courses = get_courses_where_professor

    @subscription.courses.each do |c|
      if !professor_courses.include? c
        return render_error "User is not a professor in course: " + c.id.to_s, c, 401
      end
    end
    if @subscription.save
      @billing_scheme = BillingScheme.all
      #probably wont need this for the API to run ??

      @courses = get_courses_where_professor
      @payments = @subscription.payments.all
      return render "api/subscriptions/index", success: true, status: 200
    else
      return render_error subscription.errors, subscription.errors, 400
    end
  end

  # PATCH api/licenses
  def update
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end

    p = renew_params
    p[:payment][:amount_usd] = @license.license_type.price_usd
    #Need to change this to calculate the amount they have to pay ?



    payment = Payment.new(p[:payment])
    return render_error payment.errors.messages, payment.errors.messages unless payment.valid?
    begin
      @subscription.renew! payment
    rescue Stripe::CardError => e
      return render_error e.message, e.message, 500
    rescue => e
      render_error e.message, e
    else
      @billing_schemes = BillingScheme.all
      #probably wont need this for the API to run ??

      @courses = get_courses_where_professor
      @payments = @subscription.payments.all
      render "api/subscriptions/index", success: true, status: 200
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
