describe Payment do
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_legacy) { create :payment_legacy }

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
