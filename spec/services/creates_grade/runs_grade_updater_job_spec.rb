describe Services::Actions::RunsGradeUpdaterJob do
  let(:grade) { build :grade }
  let(:context) { { grade: grade } }

  it "expects grade passed to service" do
    expect { described_class.execute({ })}.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "with grade not student visible" do
    it "does not enqueue the grade updater job" do
      expect{ described_class.execute context }.not_to change(GradeUpdaterJob.jobs, :size)
    end
  end

  context "with grade student visible" do
    let(:grade) { build :student_visible_grade}

    it "enqueues the grade updater job" do
      expect{ described_class.execute context }.to change(GradeUpdaterJob.jobs, :size).by 1
    end
  end
end
