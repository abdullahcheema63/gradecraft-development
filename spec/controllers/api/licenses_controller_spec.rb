describe API::LicensesController, :focus => true do
  let(:license_standard) { create :standard_license, user: user_professor }
  let(:license_expired) { create :standard_license, :expired, user: user_professor }
  let(:license_custom) { create :custom_license }
  let(:user_no_license) { create :user }
  let!(:course_a) { build :course }
  let!(:course_b) { build :course }
  let!(:user_professor) { create :user, courses: [course_a, course_b], role: :professor }
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_stripe_real) { create :payment_stripe_real }

  describe "GET index" do
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
      expect { post :create, params: params, format: :json }.to change { Payment.count }.by 1
      user_no_license.reload
      expect(user_no_license.license).to_not be_nil
      expect(user_no_license.license.payments.length).to eq 1
    end
  end

  describe "PUT edit" do
    # Edit license
    it "returns 404 if no license" do
      login_user(user_no_license)
      course_ids = license_standard.user.course_memberships.where(role: "professor").map{|cm| cm.course.id}
      params = {
        courses: course_ids,
      }
      put :edit, params: params, format: :json
      expect(response.status).to eq 404
    end

    it "returns 200" do
      login_user(license_standard.user)
      course_ids = license_standard.user.course_memberships.where(role: "professor").map{|cm| cm.course.id}
      params = {
        courses: course_ids,
      }
      put :edit, params: params, format: :json
      expect(response.status).to eq 200
    end

    it "replaces course list" do
      login_user(license_standard.user)
      course_ids = [license_standard.user.course_memberships.where(role: "professor").map(&:course).first.id]
      params = {
        courses: course_ids,
      }
      put :edit, params: params, format: :json
      expect(license_standard.courses.length).to eq 1
    end

    it "returns 401 if user is not instructor in any of the courses" do
      login_user(license_standard.user)
      not_member = create :course
      course_ids = license_standard.user.course_memberships.where(role: "professor").map{|cm| cm.course.id}
      course_ids << not_member
      params = {
        courses: course_ids,
      }
      put :edit, params: params, format: :json
      expect(response.status).to eq 401
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