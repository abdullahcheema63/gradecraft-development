require "./app/services/creates_submissions_export/generate_export"

describe Services::Actions::GenerateExport do
  let(:csv_file_path) { "/tmp/testing" }
  let(:context) do
    {
      submissions_export: submissions_export,
      csv_file_path: csv_file_path,
      host_url: "http://app.gradecraft.com"
    }
  end

  describe "#execute" do
    let(:submissions_export) { create :submissions_export }
    let(:exporter) do
      instance_double(
        "GradeExporter",
        export_group_grades: CSV.generate { |csv| csv << ["John", "Doe", "A"] },
        export_grades: CSV.generate { |csv| csv << ["Jane", "Doe", "A+"] }
      )
    end

    before(:each) { allow(GradeExporter).to receive(:new).and_return exporter }

    context "when the submission export uses groups" do
      let(:submissions_export) { create :submissions_export, :use_groups }

      it "writes the export data to csv" do
        described_class.execute context
        expect(CSV.read(csv_file_path).first).to eq ["John", "Doe", "A"]
      end
    end

    context "when the submission export does not use groups" do
      it "writes the export data to csv" do
        described_class.execute context
        expect(CSV.read(csv_file_path).first).to eq ["Jane", "Doe", "A+"]
      end
    end

    it "fails the context if no csv is found" do
      allow(described_class).to receive(:csv_created?).and_return false
      result = described_class.execute context
      expect(result).to be_failure
      expect(result.message).to eq "Failed to create export!"
    end
  end
end
