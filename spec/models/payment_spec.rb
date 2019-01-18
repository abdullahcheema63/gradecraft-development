describe Payment do
  let(:payment_stripe) { create :payment_stripe }
  let(:payment_legacy) { create :payment_legacy }
  
  describe "set_defaults" do
    it "sets source to Stripe if stripe_token", :focus => true do
      expect(payment_stripe.source).to eq("Stripe")
    end
    it "does not set source if source already set", :focus => true do
      expect(payment_legacy.source).to eq("Legacy")
    end
  end

  describe "charge" do
    it "charges if stripe token", :focus => true do
      allow(payment_stripe).to receive(:create_stripe_customer) { double("customer", id: 777) }
      allow(payment_stripe).to receive(:create_stripe_charge) { double("charge", id: 200) }
      expect(payment_stripe.charge!("testerson@test.com", "fake desc")).to eq(200)
      expect(payment_stripe.confirmation).to eq("200")
    end
    it "returns nil if no stripe token", :focus => true do
      expect(payment_legacy.charge!("testerson@test.com", "fake desc")).to eq(nil)
    end
  end

  describe "refund" do

  end
end