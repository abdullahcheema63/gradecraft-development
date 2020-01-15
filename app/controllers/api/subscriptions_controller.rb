class API::SubscriptionsController < ApplicationController
  skip_before_action :require_course_membership
  before_action :ensure_app_environment?
  before_action :ensure_not_impersonating?
  before_action :ensure_admin?, only: [:all_subscriptions]

  # GET api/subscriptions
  def index
    @subscription = Subscription.find_by(user_id: current_user.id)
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end

    if @subscription.customer_id
      customer_id = @subscription.customer_id
      begin
        customer = Stripe::Customer.retrieve(customer_id)
        @default_payment_method_id = customer.invoice_settings.default_payment_method
        response = Stripe::PaymentMethod.list({customer: customer_id, type: 'card'})
        @payment_methods = response.data
      rescue Stripe::StripeError => e
        @stripe_connection_error = true
      end
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
    # James used this line (good to check for courses subscriptions ? ): @subscription.courses = p[:courses].map {|c| Course.find c }

    if @subscription.save!
      puts("Created a subscription! #{@subscription.inspect}")
      redirect_back(fallback_location: fallback_location)
    else
      puts("Could not create a subscription for:  #{current_user.inspect}")
      # James used this call: ?? return render_error subscription.errors, subscription.errors, 400
      return render json: { data: current_user.subscription, errors: [ "Error creating a new subscription!" ] }, status: 500
    end
  end

  # Get api/subscriptions/failed_payment
  def failed_payment
    subscription = Subscription.find_by(user_id: current_user.id)
    return if !subscription.failed_last_payment?
    @failed_payment = subscription.payments.last
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
    make_default = params[:default_payment_method]

    begin
      payment_method = attachCard(payment_method_id, customer_id)
    rescue Stripe::CardError => e
      return render json: { data: nil, errors: e.error.message, success: false }, status: 403
    end

    if make_default
      set_card_as_default(customer_id, payment_method_id)
    end
  end

  # POST api/subscriptions/edit_card
  def edit_card
    puts "inside edit_card subscriptions api controller"
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    customer_id = @subscription.customer_id
    payment_method_id = params[:id]
    make_default = params[:default_payment_method]

    begin
      editCard(payment_method_id)
    rescue Stripe::CardError => e
      return render json: { data: nil, errors: e.error.message, success: false }, status: 403
    rescue => e
      puts "#{e.inspect}"
    end

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
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify

    set_card_as_default(customer_id, payment_method_id)

  end

  # POST api/subscriptions/remove_card
  def remove_card
    puts "inside REMOVE_CARD subscriptions api controller"
    @subscription = current_user.subscription
    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end
    if card_is_removable?
      payment_method_id = params[:_json]
      #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify

      Stripe::PaymentMethod.detach(payment_method_id)
    else
      error_message = "You cannot remove all of your payment cards while you still have a course subscribed"
      return render_error error_message, 400
    end
  end

  # POST api/subscriptions
  def update
    @subscription = current_user.subscription
    @billing_schemes = BillingScheme.all

    if !@subscription
      return render json: { data: nil, errors: [ "Subscription not found" ] }, status: 404
    end

    success_message = ""
    error_message = ""

    @subscribed_courses = @subscription.courses
    subscribed_course_ids = @subscribed_courses.map(&:id)
    current_subscribed_courses_count = @subscribed_courses.length

    selected_courses = params[:_json]
    #realized why these are :_json, see retryFailedPayment action to give name to variable in JSON.stringify
    selected_course_ids = selected_courses.map{ |c| c["id"].to_i }
    new_subscribed_courses_count = selected_courses.length

    puts("selected: #{selected_course_ids }")
    puts("current: #{ subscribed_course_ids }")

    courses_to_unsubscribe = subscribed_course_ids - selected_course_ids

    courses_to_subscribe = selected_course_ids - subscribed_course_ids

    if new_subscribed_courses_count == current_subscribed_courses_count
      if (selected_course_ids - subscribed_course_ids).empty?
        success_message =  "courses subscribed are the same as courses selected "
        return render_success success_message
      else
        puts("Removing subscription from: #{courses_to_unsubscribe}")
        puts("adding subscription to: #{courses_to_subscribe}")
        if (@subscription.unsubscribe_courses(courses_to_unsubscribe)) && (@subscription.subscribe_courses(courses_to_subscribe))
          success_message = "successfully switched courses on your subscription"
          return render_success success_message
        else
          error_message = "could not switch courses on your subscription"
          return render_error error_message, 500
        end
      end
    elsif new_subscribed_courses_count < current_subscribed_courses_count
      #remove a subscription from a course
      puts("Removing subscription from: #{courses_to_unsubscribe}")
      if(@subscription.unsubscribe_courses(courses_to_unsubscribe))
        success_message = "successfully removed courses from your subscription"
        return render_success success_message
      else
        error_message = "could not remove courses from your subscription"
        return render_error error_message, 500
      end
      @subscription.update_billing_scheme

    else
      # new courses need to be paid for
      puts("more courses selected than currently subscribed, needs payment")
      courses_to_pay_for_count = new_subscribed_courses_count - current_subscribed_courses_count
      new_billing_scheme = determine_new_billing_scheme(new_subscribed_courses_count)

      amount_to_pay = courses_to_pay_for_count * new_billing_scheme.price_per_course
      prorated_total = prorate_total(amount_to_pay)
      rounded_total = prorated_total.round(2, half: :up)

      puts("Cost to pay today: #{rounded_total}")
      puts("Removing subscription from: #{courses_to_unsubscribe}")
      puts("adding subscription to: #{courses_to_subscribe}")

      payment = Payment.new({
        amount_usd: rounded_total,
        billing_scheme_id: new_billing_scheme.id,
        subscription_id: @subscription.id,
      })

      payment.course_ids = courses_to_subscribe if courses_to_subscribe.length

      begin
        intent = @subscription.initiate_payment(payment)
      rescue Stripe::CardError => e
        error_message = e.error.message
        handle_payment_failure error_message
      rescue Stripe::RateLimitError => e
        # Too many requests made to the API too quickly
        error_message = e.error.message
        handle_payment_failure error_message
      rescue Stripe::AuthenticationError => e
        # Authentication with Stripe's API failed
        error_message = e.error.message
        handle_payment_failure error_message
      rescue Stripe::APIConnectionError => e
        # Network communication with Stripe failed
        error_message = e.error.message
        handle_payment_failure error_message
      rescue Stripe::StripeError => e
        error_message = e.error.message
        handle_payment_failure error_message
        # Display a very generic error to the user, and maybe send' yourself an email
      rescue => e
        # Something else happened, completely unrelated to Stripe
        error_message = "Payment failed for an unknown reason"
        handle_payment_failure error_message
      end

      if intent && intent.status === "succeeded"
        puts "!!! Payment was a success !!!"
        if courses_to_unsubscribe.length
          if(@subscription.unsubscribe_courses(courses_to_unsubscribe))
            success_message = "successfully unsubscribed courses from your subscription"
            puts "success message: #{success_message}"
          else
            puts "Could add error message about not being able to unsubscribe course"
          end
        end
        if courses_to_subscribe.length
          if(@subscription.subscribe_courses(courses_to_subscribe))
            success_message = "successfully added courses to your subscription"
            puts "success message: #{success_message}"
          else
            error_message = "Error adding courses to your subscription"
            puts "issue stripe refund ?!! (Please double check your payment was refunded ? )"
            render_error error_message, 500
          end
        end

        payment.status = "succeeded"
        payment.failed = false
        payment.save
        NotificationMailer.inapp_payment_received(payment).deliver_now #needs errors turned on locally or will error here
        @subscription.update_billing_scheme #not needed here ?  I think this was already updated & saved in this method?
        @subscription.extend_renewal_date
        return render_success success_message
      end
    end
  end

  def retry
    puts "inside api subscriptions retry method!!! "
    paymentID = params[:paymentID]

    payment = Payment.find(paymentID)
    @subscription = payment.subscription

    if !@subscription || !payment
      return render json: { data: nil, errors: [ "Subscription or payment not found" ] }, status: 404
    end

    puts "hello"

    selected_courses = params[:courses]
    selected_course_ids = selected_courses.map{ |c| c["id"].to_i }
    payment_course_ids = payment.course_ids

    puts "just before conditonal if block "

#Determine if number of courses on the payment is the same (or less) than the selected_course_ids length
    if selected_course_ids.length == 0
      # cancel subscription
      courses_to_unsubscribe = payment.course_ids

      payment.status = "canceled"
      payment.failed = false
      payment.amount_usd = 0
      payment.save!

      # ? cancel payment on Stripe's side using the payment.payment_intent_id
      # Need to wrap this in a begin / rescue ?

      #Stripe::PaymentIntent.cancel(
        #payment.payment_intent_id,
        #cancellation_reason: "abandoned"
      #)

      if(@subscription.unsubscribe_courses(courses_to_unsubscribe))
        success_message = "successfully removed all courses from your subscription"
        return render_success success_message
      end

    elsif selected_course_ids.length < payment_course_ids.length
      puts "inside elsif (courses removed from subscription)"
      courses_to_unsubscribe = payment_course_ids - selected_course_ids

      @subscription.unsubscribe_courses(courses_to_unsubscribe)

      #determine billing scheme / change on payment
      new_billing_scheme = determine_new_billing_scheme(new_subscribed_courses_count)

      amount_to_pay = selected_course_ids.length * new_billing_scheme.price_per_course
      # Make sure this is in cents ?

      puts "amount_to_pay: #{amount_to_pay}"

      puts "payment before updated attributes: #{payment.inspect}"

      payment.update_attributes(:amount_usd => amount_to_pay, :billing_scheme_id => new_billing_scheme.id)

      payment.course_ids = selected_course_ids

      puts "\n\n payment after updated_attributes: #{payment.inspect}"
    end

    puts "inside #retry method, after if conditonal block, about to initiate payment, payment: #{payment.inspect}"

    begin
      intent = @subscription.initiate_payment(payment)
    rescue Stripe::CardError => e
      puts "error error: #{e}"
      payment.status = e.error.code
    rescue Stripe::RateLimitError => e
      # Too many requests made to the API too quickly
      error_message = e.error.message
      handle_payment_failure error_message
    rescue Stripe::AuthenticationError => e
      # Authentication with Stripe's API failed
      error_message = e.error.message
      handle_payment_failure error_message
    rescue Stripe::APIConnectionError => e
      # Network communication with Stripe failed
      error_message = e.error.message
      handle_payment_failure error_message
    rescue Stripe::StripeError => e
      # Display a very generic error to the user, and maybe send' yourself an email
      error_message = e.error.message
      handle_payment_failure error_message
    rescue => e
      # Something else happened, completely unrelated to Stripe
      error_message = "Payment failed for an unknown reason"
      handle_payment_failure error_message
    end

    if intent && intent.status === "succeeded"
      puts "!!! Payment was a success !!!"
      # TO DO: make sure the courses marked as subscribed by this payment have been updated to subscribed
      @subscription.subscribe_courses(payment.courses.ids)

      payment.status = "succeeded"
      payment.failed = false
      payment.save
      NotificationMailer.inapp_payment_received(payment).deliver_now
      @subscription.update_billing_scheme #not needed here ?
      @subscription.extend_renewal_date

      success_message = "You successfully fixed your monthly auto-payment error. Thanks!"

      return render_success success_message
    end
  end

  private

  def prorate_total(amount_to_pay)
    now = DateTime.now # or should it be current ? maybe the Time class is better for timezones??
    days_in_month = now.end_of_month.day
    remaining_days_in_month = days_in_month - now.day
    if remaining_days_in_month === 0 then remaining_days_in_month = 1 end

    price_per_day = amount_to_pay / days_in_month
    prorated_total = price_per_day * remaining_days_in_month
    return prorated_total
  end

  def determine_new_billing_scheme(courses_count)
    BillingScheme.all.each do |billing_scheme|
      if billing_scheme.min_courses <= courses_count && courses_count <= billing_scheme.max_courses
        return billing_scheme
      end
    end
  end

  def create_new_subscription
    Subscription.new({
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

  def attachCard(payment_method_id, customer_id)
    Stripe::PaymentMethod.attach(
      payment_method_id,
      {
        customer: customer_id
      }
    )
  end

  def editCard(payment_method_id)
    Stripe::PaymentMethod.update(
      payment_method_id,
      {
        billing_details: {
          address: {
            city: params[:city],
            country: params[:country],
            line1: params[:addr1],
            line2: params[:addr2],
            postal_code: params[:postal_code],
          },
          name: params[:full_name],
          phone: params[:phone],
        },
        metadata: {
          nickname: params[:nickname]
        }
      }
    )
  end

  def card_is_removable?
    return true if !@subscription.courses.any?
    response = Stripe::PaymentMethod.list({customer: @subscription.customer_id, type: 'card'})
    if response.data.length > 1
      return true
    else
      return false
    end
  end

  def handle_payment_failure(message)
    # Do we want to try to cancle the payment intent on stripes side ?? / make sure they were not charged
    return render_error message, 500
  end

  def render_error(error, status=400)
    render json: {
      errors: error,
      success: false
    }, status: status
  end

  def render_success(message, status=200)
    render json: {
      message: message,
      success: true
    }, status: status
  end

  def get_courses_where_professor
    current_user.course_memberships.where(role: "professor").map{|cm| cm.course}
  end
end
