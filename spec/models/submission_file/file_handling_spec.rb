describe SubmissionFile do
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment) }
  let(:student) { build(:user) }
  let(:submission) { build(:submission, course: course, assignment: assignment, student: student) }
  let(:submission_file) { submission.submission_files.last }

  describe "#check_and_set_confirmed_status" do
    subject { submission_file.check_and_set_confirmed_status }
    let(:submission_file) { build(:submission_file) }
    let(:someday) { Date.parse("June 20 2502").to_time }

    before do
      allow(Time).to receive(:now) { someday }
      allow(submission_file).to receive(:file_missing?) { "probably" }
    end

    it "checks whether the file is missing and updates the confirmed attributes" do
      expect(submission_file).to receive(:update_attributes).with(file_missing: "probably", last_confirmed_at: someday)
      subject
    end
  end

  describe "#mark_file_missing" do
    subject { submission_file.mark_file_missing }
    let(:submission_file) { create(:submission_file, file_missing: false, last_confirmed_at: Time.now) }
    let(:someday) { Date.parse("June 20 2502").to_time }

    before do
      allow(Time).to receive(:now) { someday }
    end

    it "sets the file as missing and updates the last confirmed day" do
      expect(submission_file).to receive(:update_attributes).with(file_missing: true, last_confirmed_at: someday)
      subject
    end

    it "actually updates the submission file" do
      subject
      expect(submission_file[:file_missing]).to be_truthy
      expect(submission_file[:last_confirmed_at]).to eq(someday)
    end
  end

  describe "#file_missing?" do
    subject { submission_file.file_missing? }
    let(:submission_file) { build(:submission_file) }
    before { allow(submission_file).to receive(:exists_on_storage?) { false }}

    it "negates #exists_on_storage?" do
      expect(subject).to be_truthy
    end
  end

end
