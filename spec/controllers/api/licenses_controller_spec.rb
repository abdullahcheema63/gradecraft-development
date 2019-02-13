describe API::LicensesController, :focus => true do
  let(:license_standard) { create :standard_license }
  let(:license_expired) { create :standard_license, :expired }
  let(:license_custom) { create :custom_license }
  let(:user_no_license) { create :user }
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_stripe_real) { create :payment_stripe_real }

  describe "GET index" do
    # Should this exist at all? Maybe just GET User with 'include license'
    it "returns 200" do
      login_user(license_expired.user)
      get :index, format: :json
      expect(response.status).to eq 200
    end

    it "renders index" do
      login_user(license_expired.user)
      get :index, format: :json
      expect(response).to render_template(:index)
    end

    it "returns 404 if user has no license" do
      login_user(user_no_license)
      get :index, format: :json
      expect(response.status).to eq 404
    end
  end

  describe "POST create" do
    # New license
    it "returns 409 if license already exists" do
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
      expect(response.status).to eq 409
    end

    it "returns 201" do
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
      expect(response.status).to eq 201
    end

    it "renders index" do
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
      expect(response).to render_template(:index)
    end

    it "creates a license with one payment" do
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
      expect { post :create, params: params , format: :json }.to change { Payment.count }.by 1
      user_no_license.reload
      expect(user_no_license.license).to_not be_nil
      expect(user_no_license.license.payments.length).to eq 1
    end
  end

  describe "PATCH update" do
    # Renew license
    it "returns 404 if no license" do
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
      expect(response.status).to eq 404
    end

    it "returns 200" do
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
      expect(response.status).to eq 200
    end

    it "renders index" do
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
      expect(response).to render_template(:index)
    end

    it "updates a license to have +1 payment" do
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
      expect { patch :update, params: params, format: :json }.to change { license_standard.payments.length }.by 1
    end

    it "updates a license's expiry" do
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
      expect { patch :update, params: params, format: :json }.to change { license_standard.expires }
    end
  end
end