describe Presenters::SubmissionFiles::Base do
  subject { described_class.new }

  let(:submission_file) do
    double(:submission_file,
      submission: double(Submission),
      id: rand(1000)
    )
  end

  let(:presenter_params) do
    { submission_file_id: submission_file.id }
  end

  before do
    allow(subject).to receive(:params) { presenter_params }
    allow(subject).to receive(:submission_file) { submission_file }
  end

  describe "#submission_file" do
    let(:result) { subject.submission_file }
    before do
      allow(subject).to receive(:submission_file).and_call_original
    end

    context "params[:submission_file_id] exists" do
      before do
        allow(SubmissionFile).to receive(:where) { [submission_file] }
      end

      it "finds the submission file by id" do
        expect(SubmissionFile).to receive(:where).with id: submission_file.id
        result
      end

      it "caches the submission_file" do
        result
        expect(SubmissionFile).not_to receive(:where)
        result
      end

      it "sets an ivar for the submission_file" do
        result
        expect(subject.instance_variable_get(:@submission_file))
          .to eq submission_file
      end
    end

    context "params[:submission_file_id] does not exist" do
      let(:presenter_params) do
        { submission_file_id: nil }
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end

  describe "#submission" do
    context "submission_file does not exist" do
      it "returns nil" do
        allow(subject).to receive(:submission_file) { nil }
        expect(subject.submission).to be_nil
      end
    end

    context "submission_file exists" do
      it "returns the submission from the submission_file" do
        expect(subject.submission).to eq submission_file.submission
      end
    end
  end

  describe "#filename" do
    let(:presenter_params) { { index: "10" } }
    it "returns the instructor_filename for the submission file" do
      expect(submission_file).to receive(:instructor_filename).with(10)
      subject.filename
    end
  end

  describe "#mark_submission_file_missing" do
    let(:result) { subject.mark_submission_file_missing }

    context "submission_file does not exist" do
      it "returns false" do
        allow(subject).to receive(:submission_file) { nil }
        expect(result).to eq false
      end
    end

    context "submission_file exists" do
      it "marks the submission_file missing" do
        expect(submission_file).to receive(:mark_file_missing)
        result
      end
    end
  end

  describe "#send_data_options" do
    it "returns a splattable array with the options for send_data" do
      allow(subject).to receive_messages \
        stream_submission_file: "filez", filename: "stuff.txt"
      expect(subject.send_data_options).to eq ["filez", filename: "stuff.txt"]
    end
  end
end
