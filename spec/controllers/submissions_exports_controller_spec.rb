RSpec.describe SubmissionsExportsController, type: :controller do

  let(:teams) { create_list(:team, 2) }
  let(:team) { teams.first }
  let(:course) { create(:course, teams: teams) }
  let(:submissions_exports) { create_list(:submissions_export, 2, course: course, assignment: assignment, local_file_path: "some thing") }
  let(:submissions_export) { create(:submissions_export, course: course, assignment: assignment, local_file_path: "some thing") }
  let(:assignment) { create(:assignment) }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:group) { double :group, id: 30 }

  before do
    login_user(professor)
    allow(controller).to receive(:current_course) { course }
    allow(controller).to receive(:current_user) { professor }
  end

  describe "POST #create" do
    subject { post :create, params: { assignment_id: assignment.id, team_id: team.id }}

    it "creates an submissions export" do
      expect(controller).to receive(:create_submissions_export)
      subject
    end

    describe "enqueuing the submissions export job" do
      context "the submissions export job is enqueued" do
        before { allow(controller).to receive_message_chain(:submissions_export_job, :success) }
        it "sets the job success flash message" do
          subject
          expect(flash[:success]).to match(/Your submissions export is being prepared/)
        end
      end
    end

    it "redirects to the assignment page for the given assignment" do
      subject
      expect(response).to redirect_to(assignment_path(assignment))
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: submissions_export.id }}

    before(:each) do
      allow(controller).to receive(:submissions_export) { submissions_export }
    end

    describe "determining success and failure" do
      context "the submissions export is destroyed and the s3 object deleted" do
        before do
          allow(submissions_export).to receive(:delete_object_from_s3) { true }
        end

        it "destroys the submissions export" do
          expect(submissions_export).to receive(:destroy)
          subject
        end

        it "notifies the user of success" do
          subject
          expect(flash[:success]).to match(/Assignment export successfully deleted/)
        end
      end
    end

    it "redirects to the exports path" do
      subject
      expect(response).to redirect_to(downloads_path)
    end
  end

  describe "secure downloads" do
    let(:secure_download_params) do
      {
        secure_token_uuid: secure_token.uuid,
        secret_key: secure_token.random_secret_key,
        id: submissions_export.id
      }
    end

    let(:authenticator) { SecureTokenAuthenticator.new authenticator_params }
    let(:authenticator_params) do
      secure_download_params.except(:id).merge(
        target_class: secure_token.target_type,
        target_id: secure_token.target_id
      )
    end

    let(:secure_token) { create(:secure_token, target: submissions_export) }

    describe "GET #secure_download" do
      let(:result) { get :secure_download, params: secure_download_params }

      before(:each) do
        allow(controller).to receive(:secure_download_authenticator)
          .and_return authenticator
      end

      context "the SecureDownloadAuthenticator doesn't authenticate" do
        before do
          allow(authenticator).to receive(:authenticates?) { false }
        end

        context "the request was for a valid token that has expired" do
          it "alerts the user that their token has expired" do
            allow(authenticator).to receive(:valid_token_expired?) { true }
            result
            expect(flash[:alert]).to match /email link.*expired/
          end
        end

        context "the request completely failed to authenticate" do
          it "alerts the user that their request was invalid" do
            allow(authenticator).to receive(:valid_token_expired?) { false }
            result
            expect(flash[:alert]).to match /does not exist/
          end
        end

        it "redirects the user to the root page and tells them to log in" do
          result
          expect(flash[:alert]).to match /Please login/
          expect(response).to redirect_to root_path
        end
      end
    end

    describe "#secure_download_authenticator" do
      let(:result) do
        controller.instance_eval { secure_download_authenticator }
      end

      let(:authenticator_attrs) do
        {
          secure_token_uuid: secure_token.uuid,
          secret_key: secure_token.random_secret_key,
          target_id: submissions_export.id,
          target_class: "SubmissionsExport"
        }
      end

      before do
        allow(controller).to receive(:params) { secure_download_params }
      end

      it "builds a new SecureTokenAuthenticator" do
        expect(SecureTokenAuthenticator).to receive(:new)
          .with authenticator_attrs
        result
      end

      it "caches the SecureTokenAuthenticator" do
        result
        expect(SecureTokenAuthenticator).not_to receive(:new)
        result
      end

      it "sets the returned value to @secure_token_authenticator" do
        authenticator = SecureTokenAuthenticator.new authenticator_attrs
        allow(SecureTokenAuthenticator).to receive(:new) { authenticator }
        result
        expect(controller.instance_variable_get(:@secure_download_authenticator))
          .to eq(authenticator)
      end
    end
  end

  describe "#submissions_export" do
    subject { controller.instance_eval { submissions_export } }
    before { allow(controller).to receive(:params) {{ id: submissions_export.id }} }

    it "fetches an submissions export by id" do
      expect(SubmissionsExport).to receive(:find).with(submissions_export.id)
      subject
    end

    it "caches the submissions export outcome" do
      subject
      expect(SubmissionsExport).not_to receive(:find).with(submissions_export.id)
      subject
    end
  end

  describe "#create_submissions_export" do
    subject { controller.instance_eval { create_submissions_export } }

    let(:submissions_export_attrs) do
      {
        assignment_id: assignment.id,
        course_id: course.id,
        professor_id: professor.id,
        team_id: team.id,
        use_groups: true
      }
    end

    before do
      allow(controller).to receive(:params) do
        { assignment_id: assignment.id, team_id: team.id, use_groups: true }
      end

      allow(controller).to receive_messages(current_course: course, current_user: professor)
    end

    it "creates an submissions export" do
      expect(SubmissionsExport).to receive(:create).with(submissions_export_attrs)
      subject
    end

    it "caches the created submissions export" do
      subject
      expect(SubmissionsExport).not_to receive(:create)
      subject
    end
  end

  describe "#submissions_export_job" do
    subject { controller.instance_eval { submissions_export } }

    before do
      controller.instance_variable_set(:@submissions_export, submissions_export)
    end

    it "instantiates a new submissions export job" do
      expect{ get :create, params: { id: course.id, assignment_id: assignment.id } }.to \
        change(SubmissionListExporterJob.jobs, :size).by 1
    end

    it "caches the submissions export job" do
      subject
      expect(SubmissionListExporterJob).not_to receive(:new)
      subject
    end
  end

  describe "#assignment" do
    subject { controller.instance_eval { assignment } }
    before { allow(controller).to receive(:params) {{ assignment_id: assignment.id }} }

    it "fetches an assignment by assignment id" do
      expect(Assignment).to receive(:find).with(assignment.id)
      subject
    end

    it "caches the fetch assignment outcome" do
      subject
      expect(Assignment).not_to receive(:find).with(submissions_export.id)
      subject
    end
  end
end
