describe Course do
  let(:course1) { create(:course) }
  let(:course2) { create(:course) }
  let(:staff_membership) { create :course_membership, :staff, course: course1, instructor_of_record: true }
  let(:student_membership1) { create :course_membership, :student, course: course1 }
  let(:student_membership2) { create :course_membership, :student, course: course1 }
  let(:student_membership3) { create :course_membership, :student, course: course2 }

  describe "recalculate_student_scores" do
    before do
      CourseMembership.where(course_id: course1.id).destroy_all
      @course1 = course1
      @student_membership1 = student_membership1
      @student_membership2 = student_membership2
    end

    subject { @course1.recalculate_student_scores }

    context "no student ids are present" do
      it "doesn't increase the queue size" do
        allow(@course1).to receive(:ordered_student_ids) { [] }
        expect{ subject }.not_to change(ScoreRecalculatorJob.jobs, :size)
      end
    end

    it "increases the queue size by two" do
      expect{ subject }.to change(ScoreRecalculatorJob.jobs, :size).by 2
    end
  end

  describe "ordered_student_ids" do
    before do
      @course1 = course1
      @student_membership1 = student_membership1
      @student_membership2 = student_membership2
      @student_membership3 = student_membership3
      @staff_membership = staff_membership
    end

    subject { @course1.ordered_student_ids }

    it "should order the ids by users.id ASC" do
      expect(subject).to eq([@student_membership1.user_id, @student_membership2.user_id])
    end

    it "should only return an array of ids" do
      expect(subject.collect(&:class)).to eq([Integer, Integer])
    end

    context "user is a student not in the course" do
      it "doesn't include the student's id" do
        expect(subject).not_to include(@student_membership3.user_id)
      end
    end

    context "user is a student in the course" do
      it "includes the student's id" do
        expect(subject).to include(@student_membership1.user_id)
        expect(subject).to include(@student_membership2.user_id)
      end
    end

    context "user is a professor in the course" do
      it "doesn't include the student's id" do
        expect(subject).not_to include(@staff_membership.user_id)
      end
    end
  end
end
