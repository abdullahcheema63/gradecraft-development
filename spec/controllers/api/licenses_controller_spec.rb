describe API::LicensesController do
  let(:license_standard) { create :standard_license }
  let(:license_expired) { create :standard_license, :expired }
  let(:license_custom) { create :custom_license }
  let(:user_no_license) { create :user }
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_stripe_real) { create :payment_stripe_real }

  describe "GET index" do
    # Should this exist at all? Maybe just GET User with 'include license'
    it "returns 200", :focus => true do
      login_user(license_expired.user)
      get :index, format: :json
      expect(response.status).to eq 200
    end

    it "returns license in body", :focus => true do
      login_user(license_expired.user)
      get :index, format: :json
      puts response.body
      expect(response).to render_template(:index)
      expect(response.body.length).to be > 0
    end

    it "returns 404 if user has no license", :focus => true do
      login_user(user_no_license)
      get :index, format: :json
      puts response.body
      expect(response.status).to eq 404
    end
  end

  describe "POST create" do
    # New license
    it "returns 409 if license already exists", :focus => true do
      login_user(license_expired.user)
      payment = payment_stripe
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
        license_type_id: license_expired.license_type_id
      }
      post :create, params: params, format: :json
      puts response.body
      expect(response.status).to eq 409
    end

    it "returns 201", :focus => true do
      login_user(user_no_license)
      payment = payment_stripe_real
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
        license_type_id: license_expired.license_type_id
      }
      post :create, params: params, format: :json
      puts response.body
      expect(response.status).to eq 201
    end

    it "returns license in body", :focus => true do
      login_user(user_no_license)
      payment = payment_stripe_real
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
        license_type_id: license_expired.license_type_id
      }
      post :create, params: params, format: :json
      puts response.body
      expect(response.body.length).to be > 0
    end

    # it "creates a license with one payment", :focus => true do
    #   login_user(user_no_license)
    #   # expect()
    #   raise "Not implemented"
    # end
  end

  describe "PATCH update" do
    # Renew license
    it "returns 404 if no license", :focus => true do
      login_user(user_no_license)
      payment = payment_stripe
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
      }
      patch :update, params: params, format: :json
      puts response.body
      expect(response.status).to eq 404
    end

    it "returns 200", :focus => true do
      login_user(license_standard.user)
      payment = payment_stripe_real
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
      }
      patch :update, params: params, format: :json
      puts response.body
      expect(response.status).to eq 200
    end

    it "returns license in body", :focus => true do
      login_user(license_standard.user)
      payment = payment_stripe_real
      params = {
        payment: {
          first_name: payment.first_name,
          last_name: payment.last_name,
          organization: payment.organization,
          phone: payment.phone,
          addr1: payment.addr1,
          city: payment.city,
          country: payment.country,
          stripe_token: payment.stripe_token,
        },
      }
      patch :update, params: params, format: :json
      puts response.body
      expect(response.body.length).to be > 0
    end

    # it "updates a license to have +1 payment", :focus => true do
    #   raise "Not impelemented"
    # end

    # it "updates a license's expiry", :focus => true do
    #   raise "Not impelemented"
    # end
  end
end