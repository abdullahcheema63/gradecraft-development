describe Payment do
  let(:payment_stripe) { create :payment_stripe }
  
  describe "set_defaults" do
    it "sets source to Stripe if stripe_token", :focus => true do
      expect(payment_stripe.source).to eq("Stripe")
    end
  end
end