RSpec.shared_examples "a model that needs sanitization" do |fixture, attribute|
  let(:model) { build fixture }

  describe "relaxed html sanitization" do
    describe "##{attribute}" do
      def get(attribute)
        model.send attribute
      end

      def set(attribute, value)
        model.send "#{attribute}=", value
      end

      it "html-escapes entities" do
        set attribute, "Hello & Goodbye"

        # don't test an invalid factory
        # you'll end up pulling your hair out!
        expect(model).to be_valid

        model.save
        expect(get attribute).to eq "Hello &amp; Goodbye"
      end
    end
  end
end
