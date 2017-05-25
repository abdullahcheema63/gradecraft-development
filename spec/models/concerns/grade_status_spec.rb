describe GradeStatus do
  let(:course) { build(:course) }
  let(:assignment) { create(:assignment) }
  let(:grade) { create(:grade, assignment: assignment) }
  let(:challenge_grade) { create(:challenge_grade) }

  describe ".released" do
    it "returns all the grades that are released" do
      released_grade = create :grade, status: "Released"
      create :grade, status: "In Progress"
      expect(Grade.released).to eq [released_grade]
    end
  end

  describe ".student_visible" do
    it "returns all grades that were released or were graded but no release was necessary" do
      graded_grade = create :grade, status: "Graded"
      released_grade = create :grade, status: "Released"
      assignment = create :assignment
      create :grade, assignment: assignment, status: "Graded"

      expect(Grade.student_visible).to include(released_grade, graded_grade)
    end
  end

  describe "student_visible?" do
    it "returns true if the grade is released" do
      grade.status = "Released"
      expect(grade.is_student_visible?).to eq true
    end

    it "returns true if the grade is graded and the assignment does not need release" do
      grade.status = "Graded"
      assignment.release_necessary = false
      expect(grade.is_student_visible?).to eq true
    end

    it "returns false if the grade is not released" do
      grade.status = "Graded"
      expect(grade.is_student_visible?).to eq false
    end

    it "returns false if the grade is not marked as graded" do
      grade.status = nil
      expect(grade.is_student_visible?).to eq false
    end

    it "returns false if the grade is marked as in progress" do
      grade.status = "In Progress"
      expect(grade.is_student_visible?).to eq false
    end
  end

  describe "#is_graded?" do
    it "returns true if the challenge grade is graded" do
      challenge_grade = create(:challenge_grade, status: "Graded")
      expect(challenge_grade.is_graded?).to eq(true)
    end
    it "returns false if the challenge grade is not graded" do
      challenge_grade = create(:challenge_grade, status: nil)
      expect(challenge_grade.is_graded?).to eq(false)
    end
  end

  describe "#is_released?" do
    it "returns true if the challenge grade is released" do
      challenge_grade = create(:challenge_grade, status: "Released")
      expect(challenge_grade.is_released?).to eq(true)
    end

    it "returns false if the challenge grade is not graded" do
      challenge_grade = create(:challenge_grade, status: nil)
      expect(challenge_grade.is_released?).to eq(false)
    end

    it "returns false if the challenge grade is graded but not released" do
      challenge_grade = create(:challenge_grade, status: "Graded")
      expect(challenge_grade.is_released?).to eq(false)
    end
  end

  describe ".not_released" do
    it "returns all grades that are graded but require a release" do
      assignment = create :assignment
      not_released_grade = create :grade, assignment: assignment, status: "Graded"
      create :grade, assignment: assignment, status: "Released"
      create :grade, status: "Graded"

      expect(Grade.not_released).to eq [not_released_grade]
    end
  end

  describe "#update_status_fields" do
    context "when release is not required" do
      it "updates the fields on 'In Progress' grades" do
        grade.status = "In Progress"
        grade.update_status_fields
        expect(grade.complete).to be_falsey
        expect(grade.student_visible).to be_falsey
      end

      it "updates the fields on 'Graded' grades" do
        grade.status = "Graded"
        grade.update_status_fields
        expect(grade.complete).to be_truthy
        expect(grade.student_visible).to be_truthy
      end
    end

    context "when release is necessary" do
      before do
        grade.assignment.update(release_necessary: true)
      end

      it "updates the fields on 'In Progress' grades" do
        grade.status = "In Progress"
        grade.update_status_fields
        expect(grade.complete).to be_falsey
        expect(grade.student_visible).to be_falsey
      end

      it "updates the fields on 'Graded' grades" do
        grade.status = "Graded"
        grade.update_status_fields
        expect(grade.complete).to be_truthy
        expect(grade.student_visible).to be_falsey
      end

      it "updates the fields on 'Released' grades" do
        grade.status = "Released"
        grade.update_status_fields
        expect(grade.complete).to be_truthy
        expect(grade.student_visible).to be_truthy
      end
    end
  end
end
