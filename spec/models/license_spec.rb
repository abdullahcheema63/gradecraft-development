describe License do
  let(:license_standard) { create :standard_license }
  let(:license_custom) { create :custom_license }
  let(:payment_stripe) { create :payment_stripe }

  describe "validations" do
    it "requires a license_type", :focus => true do
      license_standard.license_type = nil
      license_standard.license_type_id = nil
      expect(license_standard).to_not be_valid
      expect(license_standard.errors[:license_type]).to include "can't be blank"
    end

    it "requires expires", :focus => true do
      license_standard.expires = nil
      expect(license_standard).to_not be_valid
      expect(license_standard.errors[:expires]).to include "can't be blank"
    end
  end

  describe "is_expired?" do
    it "returns false if expires in future", :focus => true do
      license_standard.expires = DateTime.now + 1.weeks
      expect(license_standard.is_expired?).to eq(false)
    end

    it "returns true if expires in past", :focus => true do
      license_standard.expires = DateTime.now - 1.weeks
      expect(license_standard.is_expired?).to eq(true)
    end
  end

  describe "start!" do
    it "adds payment", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.start!(payment_stripe)
      expect(license_standard.payments.length).to eq(1)
    end

    it "charges Stripe", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.start!(payment_stripe)
      expect(payment_stripe).to have_received(:charge).once
    end

    it "forces save", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.start!(payment_stripe)
      expect(license_standard).to have_received(:save!).once
    end
  end

  describe "renew!" do
    it "adds payment", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.renew!(payment_stripe)
      expect(license_standard.payments.length).to eq(1)
    end

    it "charges Stripe", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.renew!(payment_stripe)
      expect(payment_stripe).to have_received(:charge).once
    end

    it "forces save", :focus => true do
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.renew!(payment_stripe)
      expect(license_standard).to have_received(:save!).once
    end

    it "extends expiry by default", :focus => true do
      original_expiry = license_standard.expires
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.renew!(payment_stripe)
      expect(license_standard.expires).to be > original_expiry
      expect(license_standard.expires).to eq(original_expiry + license_standard.license_type.default_duration_months.months)
    end

    it "extends expiry by override", :focus => true do
      original_expiry = license_standard.expires
      override_duration = 5.months
      allow(payment_stripe).to receive(:charge)
      allow(license_standard).to receive(:save!)
      license_standard.renew!(payment_stripe, override_duration)
      expect(license_standard.expires).to be > original_expiry
      expect(license_standard.expires).to eq(original_expiry + override_duration)
    end
  end
end