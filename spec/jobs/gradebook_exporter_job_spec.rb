describe GradebookExporterJob do
  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:job_attributes) { {"user_id" => user.id, "course_id" => course.id} }

  describe "#perform_async" do
    let(:gradebook_exporter_queue) { queue(GradebookExporterJob) }
    subject { GradebookExporterJob.perform_async(job_attributes) }

    it "increases the queue size by one" do
      expect{ subject }.to change(GradebookExporterJob.jobs, :size).by 1
    end

    it "queues the job with the correct arguments" do
      subject
      expect(GradebookExporterJob.jobs.last["args"]).to \
        eq [job_attributes]
    end

    it "queues the job in the proper queue" do
      subject
      expect(GradebookExporterJob.jobs.last["class"]).to \
        eq GradebookExporterJob.name
    end
  end
end
