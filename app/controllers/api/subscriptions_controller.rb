class API::SubscriptionsController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: [:all_subscriptions]

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

  def all_subscriptions
    @subscriptions = Subscription.all
  end

  # POST api/subscriptions
  def create
    if current_user.subscription
      return render json: { data: current_user.subscription, errors: [ "Subscription already exists!" ] }, status: 409
    end

    @subscription = Subscription.new({
      billing_scheme_id: BillingScheme.find_by(min_courses: 0).id,
      user_id: current_user.id,
      renewal_date: DateTime.yesterday
    })
    if @subscription.save!
      @subscription.create_stripe_customer(current_user.email)
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
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    customer_id = @subscription.customer_id
    payment_method_id = params[:payment_method_id]
    make_default = params[:default]
    puts "default: #{make_default}"

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

  # PATCH api/subscriptions
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

        respond_to do |format|
          format.json { head :ok }
        end

      else
        puts("Removing subscription from: #{courses_to_unsubscribe}")
        unsubscribe_courses(courses_to_unsubscribe)

        puts("adding subscription to: #{courses_to_subscribe}")
        subscribe_courses(courses_to_subscribe, @subscription.id)
      end

    elsif new_subscribed_courses_count < current_subscribed_courses_count
      #remove a subscription from a course

      puts("Removing subscription from: #{courses_to_unsubscribe}")
      unsubscribe_courses(courses_to_unsubscribe)
      change_billing_scheme(new_subscribed_courses_count)

    else
      # new courses need to be paid for
      puts("more courses selected than currently subscribed, needs payment")
      courses_to_pay_for_count = new_subscribed_courses_count - current_subscribed_courses_count
      new_billing_scheme = determine_billing_scheme(new_subscribed_courses_count)
      #Need to make a new function to pro-rate the days for amount to pay
      amount_to_pay = courses_to_pay_for_count * new_billing_scheme.price_per_course

      puts("Cost to pay today: #{amount_to_pay}")
      puts("Removing subscription from: #{courses_to_unsubscribe}")
      puts("adding subscription to: #{courses_to_subscribe}")

      p = renew_params
      p[:payment][:amount_usd] = amount_to_pay

      payment = Payment.new(p[:payment])
      return render_error payment.errors.messages, payment.errors.messages unless payment.valid?
      begin
        @subscription.renew! payment

        if courses_to_unsubscribe.length
          unsubscribe_courses(courses_to_unsubscribe)
        end
        if courses_to_subscribe.length
          subscribe_courses(courses_to_subscribe, @subscription.id)
        end
        change_billing_scheme(new_subscribed_courses_count)

      rescue Stripe::CardError => e
        return render_error e.message, e.message, 500
      rescue => e
        render_error e.message, e
      else
        #subscription was successfully updated

        #not sure how to successfully return
        render "api/subscriptions/index", success: true, status: 200


        #BELOW IS FROM JAMES's work
        @billing_schemes = BillingScheme.all
        #probably wont need this for the API to run ??

        @courses = get_courses_where_professor
        @payments = @subscription.payments.all
        render "api/subscriptions/index", success: true, status: 200
      end

    end
  end

  private

  def set_card_as_default(customer_id, pm_id)
    puts "setting card as default"
    Stripe::Customer.update(
      customer_id,
      {
        invoice_settings: { default_payment_method: pm_id }
      }
    )
  end

  def unsubscribe_courses(course_ids)
    course_ids.each do |id|
      course = Course.find(id)
      course.unsubscribe
    end
  end

  def subscribe_courses(course_ids, subscription_id)
    course_ids.each do |id|
      course = Course.find(id)
      course.subscribe(subscription_id)
    end
  end

  def determine_billing_scheme(course_count)
    @billing_schemes.each do |billing_scheme|
      if billing_scheme.min_courses <= course_count && course_count <= billing_scheme.max_courses
        return billing_scheme
      end
    end
  end

  def change_billing_scheme(course_count)
    billing_scheme = determine_billing_scheme(course_count)
    puts("determined bs: #{billing_scheme.inspect}")
    if @subscription.billing_scheme_id != billing_scheme.id
      @subscription.update_billing_scheme_id(billing_scheme.id)
    end
  end

  def render_error(message, errors, status=400)
    render json: {
      message: message,
      errors: errors,
      success: false
    }, status: status
  end

  def subscription_id_params
    params.permit(_json: [:id])
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
