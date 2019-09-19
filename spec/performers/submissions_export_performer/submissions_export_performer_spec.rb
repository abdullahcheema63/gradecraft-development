RSpec.describe SubmissionsExportPerformer, type: :background_job do
  extend Toolkits::Performers::SubmissionsExport::Context
  define_context

  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  # private and protected methods

  describe "sorted_submitter_directory_keys" do
    it "sorts the keys alphabetically" do
      submitters = { "dave_hoggworthy"=>"", "carla_makeshift"=>"", "bordwell_hamhock"=>"" }

      allow(subject).to receive(:submissions_grouped_by_submitter)
        .and_return submitters

      expect(performer.instance_eval { sorted_submitter_directory_keys })
        .to eq %w[bordwell_hamhock carla_makeshift dave_hoggworthy]
    end
  end

  describe "generate_export_csv" do
    subject { performer.instance_eval { generate_export_csv }}

    let(:dogs_csv) { CSV.generate {|csv| csv << ["dogs", "are", "nice"]} }
    let(:csv_path) { performer.instance_eval { csv_file_path }}

    before(:each) do
      performer.instance_variable_set(:@submitters_for_csv, submitters)
      performer.instance_variable_set(:@assignment, assignment)
    end

    context "export uses groups" do
      let(:submitters) { create_list :group, 2 }

      it "saves the result of assignment#grade_import" do
        allow(performer.submissions_export).to receive(:use_groups) { true }
        allow_any_instance_of(GradeExporter).to \
          receive(:export_group_grades).with(assignment, submitters) { dogs_csv }

        subject
        expect(CSV.read(csv_path).first).to eq(["dogs", "are", "nice"])
      end
    end

    context "export uses students" do
      let(:submitters) { create_list(:user, 2) }

      it "saves the result of assignment#grade_import" do
        allow(assignment).to receive(:grade_import).with(submitters) { dogs_csv }

        subject
        expect(CSV.read(csv_path).first).to eq(["dogs", "are", "nice"])
      end
    end
  end

  describe "confirm_export_csv_integrity" do
    subject { performer.instance_eval { confirm_export_csv_integrity }}
    let(:tmp_dir) { Dir.mktmpdir }
    let(:test_file_path) { File.expand_path("csv_test.txt", tmp_dir) }

    context "the csv was successfully created" do
      before do
        File.open(test_file_path, "w") {|f| f.write("test file") }
        allow(performer).to receive(:csv_file_path) { test_file_path }
      end

      it "returns true" do
        expect(subject).to be_truthy
      end

      it "sets an @confirm_export_csv_integrity ivar" do
        subject
        expect(performer.instance_variable_get(:@confirm_export_csv_integrity)).to be_truthy
      end

      it "caches the value" do
        subject # call it once to cache it
        expect(File).to_not receive(:exist?).with("csv_test.txt")
        subject # shouldn't check again after caching
      end

      after do
        File.delete(test_file_path) if File.exist?(test_file_path)
      end
    end

    context "the csv was not created" do
      let(:false_file_path) { File.expand_path("false_test.txt", tmp_dir) }

      before do
        allow(performer).to receive(:csv_file_path) { "false_test.txt" }
      end

      it "returns false" do
        expect(subject).to be_falsey
      end

      it "doesn't cache the value" do
        expect(performer.instance_variable_get(:@confirm_export_csv_integrity)).to eq(nil)
      end

      after do
        File.delete(false_file_path) if File.exist?(false_file_path)
      end
    end

  end

  describe "csv_file_path" do
    subject { performer.instance_eval { csv_file_path }}
    it "uses the grade import template" do
      expect(subject).to match(/grade_import_template\.csv$/)
    end

    it "expands the path off of archive_root_dir" do
      allow(performer).to receive(:archive_root_dir) { "/some/weird/path/" }
      expect(subject).to match(/^\/some\/weird\/path\//)
    end

    it "caches the file path" do
      cached_call = subject
      expect(subject).to eq(cached_call)
    end
  end

  describe "work_resources_present?" do
    let(:assignment_present) { performer.instance_variable_set(:@assignment, true) }
    let(:assignment_not_present) { performer.instance_variable_set(:@assignment, false) }
    let(:submitters_present) { performer.instance_variable_set(:@submitters, true) }
    let(:submitters_not_present) { performer.instance_variable_set(:@submitters, false) }

    subject { performer.instance_eval { work_resources_present? }}

    context "both @assignment and @submitters are present" do
      before { assignment_present; submitters_present }
      it { should be_truthy }
    end

    context "@assignment is present but @submitters are not" do
      before { assignment_present; submitters_not_present }
      it { should be_falsey }
    end

    context "@submitters is present but @assignment is not" do
      before { submitters_present; assignment_not_present }
      it { should be_falsey }
    end

    context "neither @submitters nor @assignment are present" do
      before { submitters_not_present; assignment_not_present }
      it { should be_falsey }
    end
  end

  describe "submissions_by_submitter" do
    let(:student1) { create(:user, first_name: "Ben", last_name: "Bailey", username: "benfriend") }
    let(:student2) { create(:user, first_name: "Mike", last_name: "McCaffrey") }
    let(:student3) { create(:user, first_name: "Dana", last_name: "Dafferty") }
    let(:student4) { create(:user, first_name: "Ben", last_name: "Bailey", username: "benweirdo") }

    let(:submission1) { double(:submission, id: 1, submitter_id: student1.id) }
    let(:submission2) { double(:submission, id: 2, submitter_id: student2.id) }
    let(:submission3) { double(:submission, id: 3, submitter_id: student3.id) }
    let(:submission4) { double(:submission, id: 4, submitter_id: student2.id) } # note that this uses student 2
    let(:submission5) { double(:submission, id: 5, submitter_id: student4.id) }

    let(:grouped_submission_expectation) {{
      "Bailey, Ben - benfriend" => [submission1],
      "McCaffrey, Mike" => [submission2, submission4],
      "Dafferty, Dana" => [submission3],
      "Bailey, Ben - benweirdo" => [submission5]
    }}

    let(:submissions_by_id) { [submission1, submission2, submission3, submission4, submission5].sort_by(&:id) }

    before(:each) do
      performer.instance_variable_set(:@submissions, submissions_by_id)
      performer.instance_variable_set(:@submitters, [ student1, student2, student3, student4 ])
    end

    subject do
      performer.instance_eval { submissions_grouped_by_submitter }
    end

    it "should reorder the @submissions array by student" do
      expect(subject).to eq(grouped_submission_expectation)
    end

    it "should use 'last_name_first_name-id' for the hash keys" do
      expect(subject.keys.first).to eq("Bailey, Ben - benfriend")
    end

    it "should return an array of submissions for each student" do
      expect(subject["McCaffrey, Mike"]).to eq([submission2, submission4])
    end
  end
end
