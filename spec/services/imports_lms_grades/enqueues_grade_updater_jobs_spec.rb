describe Services::Actions::EnqueuesGradeUpdaterJobs do
  let(:first_grade) { create :student_visible_grade }
  let(:second_grade) { create :student_visible_grade }
  let(:grades_import_result) { double(:result, successful: [first_grade, second_grade ]) }

  it "expects grade import results" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "enqueues the grade updater job for all sucessful imported grades" do
    expect{ described_class.execute grades_import_result: grades_import_result }.to \
      change(GradeUpdaterJob.jobs, :size).by 2

    expect(GradeUpdaterJob.jobs.first["args"]).to eq [first_grade.id]
    expect(GradeUpdaterJob.jobs.last["args"]).to eq [second_grade.id]
  end

  it "does not enqueue in progress grades" do
    in_progress_grade = create :grade, status: "In Progress"
    allow(grades_import_result).to receive(:successful).and_return [in_progress_grade]

    expect{ described_class.execute grades_import_result: grades_import_result }.not_to \
      change(GradeUpdaterJob.jobs, :size)
  end

  it "does not enqueue grades that are not visible to the student" do
    allow_any_instance_of(Grade).to receive(:student_visible?).and_return false

    expect{ described_class.execute grades_import_result: grades_import_result }.not_to \
      change(GradeUpdaterJob.jobs, :size)
  end
end
