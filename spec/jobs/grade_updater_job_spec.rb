describe GradeUpdaterJob do
  let(:course) { create :course }
  let(:assignment) { create(:assignment, course: course) }
  let(:student) { create :user, courses: [course], role: :student }
  let(:grade) { create :grade, course: course, assignment: assignment, student: student }

  subject { described_class.new }

  describe "#perform" do
    it "creates a grade announcement" do
      expect(GradeAnnouncement).to receive(:create).with(grade).once
      subject.perform(grade.id)
    end

    it "notifies on grade release" do
      expect{ subject.perform(grade.id) }.to change(ActionMailer::Base.deliveries, :size).by 1
    end
  end
end
