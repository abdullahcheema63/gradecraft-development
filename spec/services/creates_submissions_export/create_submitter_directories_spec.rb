require "./app/services/creates_submissions_export/create_submitter_directories"

describe Services::Actions::CreateSubmitterDirectories do
  let(:submissions_export) { create :submissions_export }
  let(:submitters) { create_list :user, 2 }
  let(:context) do
    {
      submissions_export: submissions_export,
      submitters: submitters,
      submitter_directory_names: {
        submitters.first.id => submitters.first.name,
        submitters.second.id => submitters.second.name,
      },
      archive_root_dir: "/tmp/testing"
    }
  end

  describe "#execute" do
    it "creates a directory for each submitter" do
      allow(described_class).to receive(:valid_directories?).and_return true
      expect(FileUtils).to receive(:mkdir_p).twice
      described_class.execute context
    end

    it "fails the context if a directory is missing" do
      allow(FileUtils).to receive(:mkdir_p).and_return nil
      result = described_class.execute context
      expect(result).to be_failure
    end
  end
end
