describe MultipliedGradebookExporterJob do
  let(:user) { create :user}
  let(:course) { create :course }
  let(:exporter) { instance_double("MultipliedGradebookExporter", gradebook: {}) }

  before(:each) do
    allow(MultipliedGradebookExporter).to receive(:new).and_return exporter
  end

  subject { described_class.new }

  describe "#perform" do
    it "fetches the csv data for the export" do
      expect(exporter).to receive(:gradebook).with(course).once
      subject.perform user.id, course.id
    end

    it "sends the gradebook export via email" do
      expect{ subject.perform user.id, course.id }.to change(ActionMailer::Base.deliveries, :size).by 1
    end
  end
end
