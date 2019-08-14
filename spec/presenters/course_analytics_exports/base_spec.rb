describe Presenters::CourseAnalyticsExports::Base do
  subject { described_class.new params: params }

  before { skip }

  let(:export) { create :course_analytics_export }
  let(:course) { export.course }
  let(:owner) { export.owner }

  let(:params) do
    { id: export.id }
  end

  it "has a resource name" do
    expect(subject.resource_name).to eq "course analytics export"
  end

  describe "#create_and_enqueue_export" do
    context "export is created" do
      it "creates the export and enqueues the job" do
        allow(subject).to receive(:create_export) { true }
        expect(subject).to receive_message_chain :export_job, :enqueue
        subject.create_and_enqueue_export
      end
    end

    context "export does not create" do
      it "fails and doesn't enqueue a job" do
        allow(subject).to receive(:create_export) { false }
        expect(subject).not_to receive :export_job
        subject.create_and_enqueue_export
      end
    end
  end

  describe "#create_export" do
    before do
      allow(subject).to receive_messages \
        current_user: owner,
        current_course: course
    end

    it "creates a new export and sets it to @export" do
      expect(CourseAnalyticsExport).to receive(:create).with(
        course_id: course.id, owner_id: owner.id)

      subject.create_export
    end

    it "sets the export to @export" do
      export = subject.create_export
      expect(subject.instance_variable_get :@export).to eq export
    end
  end

  describe "#export_job" do
    it "builds a new export job" do
      expect(CourseAnalyticsExportJob).to receive(:new)
        .with export_id: export.id
      subject.export_job
    end

    it "caches the export job" do
      export_job = subject.export_job
      expect(subject.instance_variable_get :@export_job).to eq export_job

      # now that we've built one, we shouldn't be building another one
      expect(CourseAnalyticsExportJob).not_to receive(:new)
      subject.export_job
    end
  end

  describe "#export" do
    it "finds the export by id" do
      export # cache the export so it's findable
      expect(subject.export).to eq export
    end

    it "caches the found export" do
      found_export = subject.export
      expect(subject.instance_variable_get :@export).to eq found_export
    end
  end

  describe "#destroy_export" do
    # stub out the s3 client so we don't lag with S3 calls
    let(:export) { double(:export).as_null_object }

    it "destroys the export" do
      allow(subject).to receive(:export) { export }
      allow(export).to receive(:destroy) { "stuff-blowed-up" }
      expect(subject.destroy_export).to eq "stuff-blowed-up"
    end
  end

  describe "#current_course" do
    it "returns the current_course from properties" do
      subject.properties[:current_course] = "the-course"
      expect(subject.current_course).to eq "the-course"
    end
  end

  describe "#current_user" do
    it "returns the current_user from properties" do
      subject.properties[:current_user] = "the-user"
      expect(subject.current_user).to eq "the-user"
    end
  end

  describe "#stream_export" do
    let(:export) { double(:export).as_null_object }

    it "streams the s3 object and returns the stream" do
      allow(subject).to receive(:export) { export }
      allow(export).to receive(:stream_s3_object_body) { "the-stream" }
      expect(subject.stream_export).to eq "the-stream"
    end
  end

  describe "#export_filename" do
    let(:export) { double(:export).as_null_object }

    it "returns the filename of the export" do
      allow(subject).to receive(:export) { export }
      allow(export).to receive(:export_filename) { "the-filename" }
      expect(subject.export_filename).to eq "the-filename"
    end
  end

  describe "token authentication" do
    let(:authenticator) { double(:an_authenticator).as_null_object }

    before(:each) do
      allow(subject).to receive(:authenticator) { authenticator }
    end

    describe "#secure_download_authenticates?" do
      it "checks whether the secure download has authenticated" do
        allow(authenticator).to receive(:authenticates?) { "auth-response" }
        expect(subject.secure_download_authenticates?).to eq "auth-response"
      end
    end

    describe "#secure_download_expired?" do
      it "checks whether the auth is valid, but the token expired" do
        allow(authenticator).to receive(:valid_token_expired?) { "probably" }
        expect(subject.secure_download_expired?).to eq "probably"
      end
    end

    describe "#send_data_options" do
      it "returns the un-splatted options we want to use for send_data" do
        allow(subject).to receive_messages \
          stream_export: "the-data",
          export_filename: "filez.txt"

        expect(subject.send_data_options).to eq \
          ["the-data", { filename: "filez.txt" }]
      end
    end
  end
end
