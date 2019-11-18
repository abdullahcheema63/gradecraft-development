require "./app/services/creates_submissions_export/create_submission_files"

describe Services::Actions::CreateSubmissionFiles do
  let(:assignment) { create :assignment }
  let(:context) do
    {
      submissions_export: submissions_export,
      archive_root_dir: "/tmp/testing"
    }
  end

  describe "#execute" do
    let(:file_like_object) { StringIO.new }

    before(:each) do
      allow(described_class).to receive(:open).and_yield file_like_object
    end

    context "for groups" do
      let(:group) { create :group }
      let(:assignment) { create :group_assignment }
      let!(:submission) { create :group_submission, assignment: assignment, group: group, text_comment: "blah", link: "https://www.google.com" }
      let(:submissions_export) { create :submissions_export, use_groups: true, assignment: assignment }

      before(:each) do
        group.assignments << assignment
        context[:submitter_directory_names] = group.students.inject({}) { |m, s| m.update(s.id => s.name) }
      end

      xit "creates a submission file for each group submission" do
        described_class.execute context
        expect(file_like_object.string).to eq \
          "Submission items from #{group.name}\n\ntext comment: #{submission.text_comment}\n\nlink: #{submission.link}\n"
      end
    end

    context "for teams" do
      let(:team) { create :team }
      let(:submissions) { create_list :full_submission, 2, assignment: assignment }
      let!(:team_memberships) { create_list :team_membership, 2, team: team }
      let(:submissions_export) { create :submissions_export, team: team, assignment: assignment}

      before(:each) do
        team_memberships.each_with_index { |tm, i| submissions[i].update student: tm.student }
        context[:submitter_directory_names] = team.students.inject({}) { |m, s| m.update(s.id => s.name) }
      end

      it "creates a submission file for each team submission" do
        described_class.execute context
        content = file_like_object.string
        submissions.each do |s|
          expect(content).to include \
            "Submission items from #{s.student.last_name}, #{s.student.first_name}\n\ntext comment: #{s.text_comment}\n\nlink: #{s.link}"
        end
      end
    end

    context "for individuals" do
      let(:submissions_export) { create :submissions_export }

      xit "does some stuff that will require testing"
    end
  end
end
