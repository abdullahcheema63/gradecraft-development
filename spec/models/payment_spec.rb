describe Payment, :focus => true do
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_legacy) { create :payment_legacy }
  
  describe "set_defaults" do
    it "sets source to Stripe if stripe_token" do
      expect(payment_stripe.source).to eq("Stripe")
    end

    it "does not set source if source already set" do
      expect(payment_legacy.source).to eq("Legacy")
    end
  end

  describe "validations" do
    it "requires first_name" do
      payment_stripe.first_name = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:first_name]).to include "can't be blank"
    end

    it "requires last_name" do
      payment_stripe.last_name = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:last_name]).to include "can't be blank"
    end

    it "requires organization" do
      payment_stripe.organization = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:organization]).to include "can't be blank"
    end

    it "requires phone" do
      payment_stripe.phone = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:phone]).to include "can't be blank"
    end

    it "requires addr1" do
      payment_stripe.addr1 = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:addr1]).to include "can't be blank"
    end

    it "requires city" do
      payment_stripe.city = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:city]).to include "can't be blank"
    end

    it "requires country" do
      payment_stripe.country = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:country]).to include "can't be blank"
    end

    it "requires amount_usd" do
      payment_stripe.amount_usd = nil
      expect(payment_stripe).to_not be_valid
      expect(payment_stripe.errors[:amount_usd]).to include "can't be blank"
    end
  end

  describe "charge!" do
    it "charges if stripe token" do
      allow(payment_stripe).to receive(:create_stripe_customer) { double("customer", id: 777) }
      allow(payment_stripe).to receive(:create_stripe_charge) { double("charge", id: 200) }
      expect(payment_stripe.charge!("testerson@test.com", "fake desc")).to eq(200)
    end

    it "populates confirmation if stripe token" do
      allow(payment_stripe).to receive(:create_stripe_customer) { double("customer", id: 777) }
      allow(payment_stripe).to receive(:create_stripe_charge) { double("charge", id: 200) }
      payment_stripe.charge!("testerson@test.com", "fake desc")
      expect(payment_stripe.confirmation).to eq("200")
    end

    it "returns nil if no stripe token" do
      expect(payment_legacy.charge!("testerson@test.com", "fake desc")).to eq(nil)
    end
  end

  describe "refund!" do
    it "refunds if stripe token" do
      allow(payment_stripe).to receive(:create_stripe_customer) { double("customer", id: 777) }
      allow(payment_stripe).to receive(:create_stripe_charge) { double("charge", id: 200) }
      allow(payment_stripe).to receive(:retrieve_stripe_charge) { double("charge", refund: true) }
      payment_stripe.charge!("testerson@test.com", "fake desc")
      expect(payment_stripe.refund!).to eq(true)
    end

    it "returns nil if no stripe token" do
      expect(payment_legacy.refund!).to eq(nil)
    end
  end
end