RSpec.describe FileManager::PathFinder do
  subject { PathFinderTest.new local_file_path: local_file_path }

  # add some helpers for stubbing the environment
  include UniMock::StubRails

  let(:local_file_path) { "some-fake-key" }
  let(:temp_file) { Tempfile.new("some-file") }

  describe "callbacks" do
    subject { create :submissions_export, export_filename: "stuffs_bro.txt" }

    describe "rebuilding the file path before save" do
      context "export_filename changed" do
        it "rebuilds the file path" do
          expect(subject).to receive(:rebuild_file_path)
          subject.export_filename = "some_filename.txt"
          subject.save
        end
      end

      context "export_filename did not change" do
        it "doesn't rebuild the file path" do
          expect(subject).not_to receive(:rebuild_file_path)
          subject.update_attributes team_id: 5
        end
      end
    end
  end

  describe "#rebuild_file_path" do
    before do
      allow(subject).to receive_messages(
        build_file_path: "new-key",
        export_filename: "some_filename.txt"
      )
    end

    it "builds a new local_file_path and caches it" do
      subject.rebuild_file_path
      expect(subject.local_file_path).to eq "new-key"
    end
  end

  describe "#build_file_path" do
    subject { create(:submissions_export) }
    let(:result) { subject.build_file_path("stuff.zip") }

    let(:expected_base_path) do
      "exports/courses/40/assignments/50" \
      "/#{subject.object_key_date}" \
      "/#{subject.object_key_microseconds}/stuff.zip"
    end
  end

  describe "behaviors that don't define s3_manager" do
    describe "#upload_file_to_s3" do
      it "puts the encrypted object to s3" do
        expect(s3_manager).to receive(:put_encrypted_object)
          .with(s3_object_key, temp_file)
        subject.upload_file_to_s3(temp_file)
      end
    end

    describe "#local_file_exists?" do
      it "checks whether the local_file_exists?" do
        expect(subject).to receive_message_chain(:s3_object_summary, :exists?)
        subject.local_file_exists?
      end
    end
  end
end
