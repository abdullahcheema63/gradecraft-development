describe EventLogger::Exceptions::DocumentSizeExceededError do
  subject { described_class.new "An error occurred", event_attrs }

  let(:event_attrs) { { event_type: "test", id: 1 } }

  it "returns an error with the event attribute details" do
    expect(subject.message).to eq "An error occurred; attributes: #{event_attrs}"
  end
end
