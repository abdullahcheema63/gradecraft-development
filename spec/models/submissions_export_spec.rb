RSpec.describe SubmissionsExport do
  subject { build :submissions_export }

  it "includes Export::Model::ActiveRecord" do
    expect(subject).to respond_to :object_key_microseconds
  end

  describe "#local_file_path_prefix" do
    before do
      allow(subject).to receive_messages \
        object_key_date: "some-date",
        object_key_microseconds: "12345",
        course_id: 99,
        assignment_id: 100
    end

    it "builds a path for the s3 object" do
      expect(subject.local_file_path_prefix).to eq \
        "files/exports/courses/99/assignments/100/some-date/12345"
    end
  end

  describe "export_file_basename" do
    before(:each) do
      allow(subject).to receive_messages \
        archive_basename: "some_great_submissions",
        filename_timestamp: "2000-01-01 - 123AM"

      subject.instance_variable_set :@export_file_basename, nil
    end

    it "includes the fileized_assignment_name" do
      expect(subject.export_file_basename).to match /^some_great_submissions/
    end

    it "is appended with a YYYY-MM-DD formatted timestamp" do
      expect(subject.export_file_basename).to match /2000-01-01/
    end

    it "caches the filename" do
      subject.export_file_basename
      expect(subject).not_to receive :archive_basename
      subject.export_file_basename
    end

    it "sets the filename to an @export_file_basename" do
      subject.export_file_basename
      expect(subject.instance_variable_get :@export_file_basename)
        .to eq "some_great_submissions - 2000-01-01 - 123AM"
    end
  end

  describe "archive_basename" do
    let(:result) { subject.archive_basename }

    before do
      allow(subject).to receive_messages \
        formatted_assignment_name: "The Assignment",
        formatted_team_name: "The Team",
        group_suffix: "Some Group"
    end

    it "combines the formatted assignment and team names" do
      expect(result).to eq "The Assignment - The Team - Some Group"
    end

    it "strips out whitespace" do
      allow(subject).to receive_messages \
        formatted_assignment_name: "           The Assignment",
        group_suffix: "Some Group               "

      expect(result).to eq "The Assignment - The Team - Some Group"
    end

    it "compacts out nil team names" do
      allow(subject).to receive(:formatted_team_name) { nil }
      expect(result).to eq "The Assignment - Some Group"
    end
  end

  describe "#group_suffix" do
    context "export uses groups" do
      it "returns the suffix" do
        allow(subject).to receive(:use_groups) { true }
        expect(subject.group_suffix).to eq "Group Submissions"
      end
    end

    context "export does not use groups" do
      it "returns nil" do
        allow(subject).to receive(:use_groups) { false }
        expect(subject.group_suffix).to be_nil
      end
    end
  end

  describe "#formatted_team_name" do
    let(:result) { subject.formatted_team_name }

    # make sure that stale instance variables don't interfere with caching
    before(:each) { subject.instance_variable_set(:@team_name, nil) }

    it "formats the team name if a team exists" do
      allow(subject).to receive(:team) { create :team, name: "Super Team" }
      expect(Formatter::Filename).to receive(:titleize).with "Super Team"
      result
    end

    it "returns nil if no team exists" do
      allow(subject).to receive(:team) { nil }
      expect(result).to be_nil
    end
  end
end
