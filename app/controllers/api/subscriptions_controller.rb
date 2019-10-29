class API::SubscriptionsController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: [:all_subscriptions]

  # GET api/subscriptions
  def index
    @subscription = Subscription.find_by(user_id: current_user.id)
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end

    if @subscription.customer_id
      customer_id = @subscription.customer_id
      customer = Stripe::Customer.retrieve(customer_id)
      @default_payment_method_id = customer.invoice_settings.default_payment_method
      response = Stripe::PaymentMethod.list({customer: customer_id, type: 'card'})
      @payment_methods = response.data
    end
    @courses = get_courses_where_professor
    @payments = @subscription.payments.all
  end

  def billing_scheme_tiers
    @billing_schemes = BillingScheme.all
  end

  def all_subscriptions
    @subscriptions = Subscription.all
  end

  # POST api/subscriptions
  def create
    if current_user.subscription
      return render json: { data: current_user.subscription, errors: [ "Subscription already exists!" ] }, status: 409
    end

    @subscription = create_new_subscription

    if @subscription.save!
      puts("Created a subscription! #{@subscription.inspect}")
      redirect_back(fallback_location: fallback_location)
    else
      puts("Could not create a subscription for:  #{current_user.inspect}")

      return render json: { data: current_user.subscription, errors: [ "Error creating a new subscription!" ] }, status: 500
    end
  end

  # POST api/subscriptions/add_card
  def add_card
    puts "inside ADD_CARD subscriptions api controller"
    @subscription = current_user.subscription
    if !@subscription
      @subscription = create_new_subscription
      @subscription.save!
    end
    if !@subscription.customer_id
      @subscription.create_stripe_customer(current_user.email)
    end

    customer_id = @subscription.customer_id
    payment_method_id = params[:payment_method_id]
    make_default = params[:default]

    payment_method = Stripe::PaymentMethod.attach(
      payment_method_id,
      {
        customer: customer_id
      }
    )
    if make_default
      set_card_as_default(customer_id, payment_method_id)
    end
  end

  def make_payment_method_default
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    customer_id = @subscription.customer_id
    payment_method_id = params[:_json]

    set_card_as_default(customer_id, payment_method_id)

  end

  # POST api/subscriptions/remove_card
  def remove_card
    puts "inside REMOVE_CARD subscriptions api controller"
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    payment_method_id = params[:_json]

    Stripe::PaymentMethod.detach(payment_method_id)
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
      @billing_schemes = BillingScheme.all
      #probably wont need this for the API to run ??

      @courses = get_courses_where_professor
      @payments = @subscription.payments.all
      return render "api/subscriptions/index", success: true, status: 200
    else
      return render_error subscription.errors, subscription.errors, 400
    end
  end

  # PUT api/subscriptions
  def update
    @subscription = current_user.subscription
    @billing_schemes = BillingScheme.all

    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end

    @subscribed_courses = @subscription.courses
    subscribed_course_ids = @subscribed_courses.map(&:id)
    current_subscribed_courses_count = @subscribed_courses.length

    selected_courses = params[:_json]
    selected_course_ids = selected_courses.map{ |c| c["id"].to_i }
    new_subscribed_courses_count = selected_courses.length

    puts("selected: #{selected_course_ids }")
    puts("current: #{ subscribed_course_ids }")

    courses_to_unsubscribe = subscribed_course_ids - selected_course_ids

    courses_to_subscribe = selected_course_ids - subscribed_course_ids

    if new_subscribed_courses_count == current_subscribed_courses_count
      #check if courses are the same / swap courses, won't need to update Billing Scheme id
      if (selected_course_ids - subscribed_course_ids).empty?
        puts("courses subscribed are the same as courses selected ")
      else
        puts("Removing subscription from: #{courses_to_unsubscribe}")
        @subscription.unsubscribe_courses(courses_to_unsubscribe)

        puts("adding subscription to: #{courses_to_subscribe}")
        @subscription.subscribe_courses(courses_to_subscribe)
      end

    elsif new_subscribed_courses_count < current_subscribed_courses_count
      #remove a subscription from a course

      puts("Removing subscription from: #{courses_to_unsubscribe}")
      @subscription.unsubscribe_courses(courses_to_unsubscribe)
      @subscription.update_billing_scheme

    else
      # new courses need to be paid for
      puts("more courses selected than currently subscribed, needs payment")
      courses_to_pay_for_count = new_subscribed_courses_count - current_subscribed_courses_count
      new_billing_scheme = determine_new_billing_scheme(new_subscribed_courses_count)

      #Need to make a new function to pro-rate the days for amount to pay
      amount_to_pay = courses_to_pay_for_count * new_billing_scheme.price_per_course

      now = DateTime.now # or should it be current ? maybe the Time class is better for timezones??
      days_in_month = now.end_of_month.day
      remaing_days_in_month = days_in_month - now.day

      price_per_day = amount_to_pay / days_in_month
      prorated_total = price_per_day * remaing_days_in_month


      puts("Cost to pay today: #{prorated_total}")
      puts("price_per_day: #{price_per_day}")
      puts("days_in_month: #{days_in_month}")
      puts("remaingDaysInMonth: #{remaing_days_in_month}")
      puts("Removing subscription from: #{courses_to_unsubscribe}")
      puts("adding subscription to: #{courses_to_subscribe}")

      payment = Payment.new({
        amount_usd: prorated_total,
        billing_scheme_id: new_billing_scheme.id,
        subscription_id: @subscription.id,
      })

      intent = @subscription.initiate_payment(payment)

      if intent.status === "succeeded"
        puts "!!! Payment was a success !!!"
        if courses_to_unsubscribe.length
          @subscription.unsubscribe_courses(courses_to_unsubscribe)
        end
        if courses_to_subscribe.length
          @subscription.subscribe_courses(courses_to_subscribe)
          payment.course_ids = courses_to_subscribe
        end
        payment.confirmation = "succeeded"
        payment.charge_id = intent.charges.data.first.id
        payment.save
        NotificationMailer.payment_received(payment).deliver_now
        @subscription.update_billing_scheme
        @subscription.extend_renewal_date
      else
        puts "payment failed ): "
        puts "failed payment intent: #{intent.inspect}"
      end

      # not sure how to return to the my subscriptions page
      render "api/subscriptions/index", success: true, status: 200
    end
  end

  private

  def determine_new_billing_scheme(courses_count)
    BillingScheme.all.each do |billing_scheme|
      if billing_scheme.min_courses <= courses_count && courses_count <= billing_scheme.max_courses
        return billing_scheme
      end
    end
  end

  def create_new_subscription
    @subscription = Subscription.new({
      billing_scheme_id: BillingScheme.find_by(min_courses: 0).id,
      user_id: current_user.id
    })
  end

  def set_card_as_default(customer_id, pm_id)
    puts "setting card as default"
    Stripe::Customer.update(
      customer_id,
      {
        invoice_settings: { default_payment_method: pm_id }
      }
    )
  end

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
