describe LearningObjectivesOutcomesExporter, focus: true do
  let(:course) { create :course }
  subject { LearningObjectivesOutcomesExporter.new }

  describe "#export" do
    let(:learning_objectives) { create_list :learning_objective, 3, course: course }
    let(:proficient_learning_objective_level) { create :learning_objective_level, objective: learning_objectives.first }

    it "generates an empty CSV if there are no students or learning objectives" do
      csv = subject.learning_objectives_outcomes course
      expect(csv).to eq "First Name,Last Name,Email,Username,Team\n"
    end

    it "generates an empty CSV if there are no students" do
      learning_objectives
      csv = subject.learning_objectives_outcomes course
      expect(csv).to eq "First Name,Last Name,Email,Username,Team,#{learning_objectives.first.name},#{learning_objectives.second.name},#{learning_objectives.third.name}\n"
    end

    it "generates an gradebook CSV if there are students and assignments present" do
      student = create :user, courses: [course], role: :student, last_name: "Aad"
      another_student = create :user, courses: [course], role: :student, last_name: "Zep"

      @proficient_cumulative_outcome = create :learning_objective_cumulative_outcome, learning_objective: learning_objectives.first, user: student
      @proficient_observed_outcome = create :learning_objective_observed_outcome, objective_level_id: proficient_learning_objective_level.id, learning_objective_cumulative_outcomes_id: @proficient_cumulative_outcome.id
      create :learning_objective_cumulative_outcome, learning_objective: learning_objectives.second, user: student
      create :learning_objective_cumulative_outcome, learning_objective: learning_objectives.third, user: student

      csv = CSV.new(subject.learning_objectives_outcomes(course)).read

      expect(csv.length).to eq 3
      expect(csv[1]).to eq [student.first_name, student.last_name, student.email,
        student.username, student.team_for_course(course), "1", "0", "0"]
      expect(csv[2]).to eq [another_student.first_name, another_student.last_name,
        another_student.email, another_student.username, another_student.team_for_course(course), "0", "0", "0"]
    end
  end
end
