# specs for submission notifications that are sent to students
describe ExportsMailer do
  # brings in helpers for default emails and parts
  extend Toolkits::Mailers::EmailToolkit::Definitions
  define_email_context # defined in EmailToolkit::Definitions

  # brings in shared examples for emails and parts
  include Toolkits::Mailers::EmailToolkit::SharedExamples

  # include SubmissionsExport-specific shared examples
  include Toolkits::Mailers::ExportsMailerToolkit::SharedExamples

  let(:professor) { create(:user) }
  let(:assignment) { create(:assignment, course: course) }
  let(:course) { create(:course, assignment_term: "DECEPTION", team_term: "ASCENSION") }
  let(:team) { create(:team, course: course) }
  let(:team_term) { course.team_term.downcase }
  let(:assignment_term) { course.assignment_term.downcase }
  let(:submissions_export) { create(:submissions_export, assignment: assignment, course: course) }

  let(:secure_token) do
    create(:secure_token,
             user_id: professor.id,
             course_id: course.id,
             target: submissions_export
          )
  end

  let(:archive_data) do
    { format: "zip", url: "http://aws.com/some-archive-hash" }
  end

  before(:each) { deliver_email }

  describe "#submissions_export_success" do
    let(:deliver_email) do
      ExportsMailer
        .submissions_export_success(professor, assignment, submissions_export)
        .deliver_now
    end

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{ assignment_term } #{assignment.name} is ready"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email html part"
    end
  end

  describe "#submissions_export_failure" do
    let(:deliver_email) do
      ExportsMailer
        .submissions_export_failure(professor, assignment)
        .deliver_now
    end

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{ assignment_term } #{assignment.name} failed to build"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "an email html part"
    end
  end
end
