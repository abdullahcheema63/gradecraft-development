require "active_record_spec_helper"

describe User do
  let!(:world) do
    World.create
      .create_course
      .create_student
      .create_assignment
      .create_grade
  end

  describe ".find_by_insensitive_email" do
    it "should return the user no matter what the case the email address is in" do
      expect(User.find_by_insensitive_email(world.student.email.upcase)).to eq world.student
    end
  end

  describe ".find_by_insensitive_username" do
    it "should return the user no matter what the case the username is in" do
      expect(User.find_by_insensitive_username(world.student.username.upcase)).to eq world.student
    end
  end

  describe ".students_auditing" do
    let(:student_being_audited) { create(:user) }
    before do
      create(:course_membership, course: world.course, user: student_being_audited, auditing: true)
    end

    it "returns all the students that are being audited" do
      result = User.students_auditing(world.course)
      expect(result.pluck(:id)).to eq [student_being_audited.id]
    end

    context "with a team" do
      let(:student_in_team) { create :user }
      let(:team) { create :team, course: world.course }
      before do
        create(:course_membership, course: world.course, user: student_in_team, auditing: true)
        team.students << student_in_team
      end

      it "returns only students in the team that are being audited" do
        result = User.students_auditing(world.course, team)
        expect(result.pluck(:id)).to eq [student_in_team.id]
      end
    end
  end

  describe ".students_being_graded" do
    let(:student_not_being_graded) { create(:user) }
    before do
      create(:course_membership, course: world.course, user: student_not_being_graded, auditing: true)
    end

    it "returns all the students that are being graded" do
      result = User.students_being_graded(world.course)
      expect(result.pluck(:id)).to eq [world.student.id]
    end

    context "with a team" do
      let(:student_in_team) { create :user }
      let(:team) { create :team, course: world.course }
      before do
        create(:course_membership, course: world.course, user: student_in_team)
        team.students << student_in_team
      end

      it "returns only students in the team that are being graded" do
        result = User.students_being_graded(world.course, team)
        expect(result.pluck(:id)).to eq [student_in_team.id]
      end
    end
  end

  describe ".students_by_team" do
    let(:team) { world.create_team.team }

    it "returns only students in the team" do
      team.students << world.student
      result = User.students_by_team(world.course, team)
      expect(result.pluck(:id)).to eq [world.student.id]
    end
  end

  describe "#activated?" do
    it "is activated when the activation state is active" do
      user = build :user, activation_state: "active"
      expect(user).to be_activated
    end

    it "is not activated when the activation state is pending" do
      user = build :user, activation_state: "pending"
      expect(user).to_not be_activated
    end
  end

  describe "#self_reported_done?" do
    it "is not self reported if there are no grades" do
      expect(world.student).to_not be_self_reported_done(world.assignment)
    end

    it "is self reported if there is at least one graded grade" do
      world.grade.update_attribute :status, "Graded"
      expect(world.student).to be_self_reported_done(world.assignment)
    end
  end

  describe "#role" do
    it "returns the first role found from the course membership" do
      expect(world.student.role(world.course)).to eq "student"
    end

    it "returns nil if the course membership is not found" do
      expect(world.student.role(Course.new)).to eq nil
    end

    it "returns admin if the user is an admin" do
      world.student.admin = true
      world.student.save
      expect(world.student.role(world.course)).to eq "admin"
    end
  end

  context "validations" do
    it "requires the password confirmation to match" do
      user = User.new password: "test", password_confirmation: "blah"
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include "doesn't match Password"
    end

    it "requires that there is a password confirmation" do
      world.student.password = "test"
      expect(world.student).to_not be_valid
      expect(world.student.errors[:password_confirmation]).to include "can't be blank"
    end
  end

  context "ordering" do
    it "should return users alphabetical by last name" do
      User.destroy_all
      student = create(:user, last_name: 'Zed')
      student2 = create(:user, last_name: 'Alpha')
      expect(User.all).to eq([student2,student])
    end
  end

  context "earn_badges" do
    it "should be able to earn badges" do
      badges = create_list(:badge, 2, course: world.course)
      world.student.earn_badges(badges)
      badges_earned = world.student.earned_badges.collect {|e| e.badge }.sort_by(&:id)
      expect(badges_earned).to eq(badges.sort_by(&:id))
    end
  end

  context "student_visible_earned_badges" do
    it "should know which badges a student has earned" do
      earned_badges = create_list(:earned_badge, 3, course: world.course, student: world.student, student_visible: true)
      expect(world.student.student_visible_earned_badges(world.course)).to eq(earned_badges)
    end

    it "should not select non-visible student badges" do
      earned_badges = create_list(:earned_badge, 3, course: world.course, student: world.student, student_visible: false)
      expect(world.student.student_visible_earned_badges(world.course)).to be_empty
    end

    it "should not return unearned badges as earned badges" do
      unearned_badges = create_list(:badge, 2, course: world.course)
      visible_earned_badges = create_list(:earned_badge, 3, course: world.course, student: world.student)
      unique_earned_badges = world.student.student_visible_earned_badges(world.course)
      expect(unique_earned_badges).not_to include(*unearned_badges)
    end
  end

  context "unique_student_earned_badges" do
    before(:each) do
      create_list(:earned_badge, 3, course: world.course, student: world.student, student_visible: true)
    end

    it "should know which badges are unique to those student earned badges" do
      sorted_badges = world.student.earned_badges.collect(&:badge).sort_by(&:id).flatten
      expect(world.student.unique_student_earned_badges(world.course)).to eq(sorted_badges)
    end

    it "should not return badges associated with student-unearned badges" do
      badges_unearned = create_list(:badge, 2, course: world.course)
      expect(world.student.unique_student_earned_badges(world.course)).not_to include(*badges_unearned)
    end
  end

  context "student_visible_unearned_badges" do
    it "should know which badges a student has yet to earn" do
      badges = create_list(:badge, 2, course: world.course, visible: true)
      expect(world.student.student_visible_unearned_badges(world.course)).to eq(badges)
    end

    it "should not return earned badges as unearned ones" do
      earned_badges = create_list(:earned_badge, 2, course: world.course, student: world.student)
      expect(world.student.student_visible_unearned_badges(world.course)).not_to include(*earned_badges)
    end
  end

  context "instructor is editing the grade for a student's submission" do
    before(:each) do
      @single_badge = world.create_badge(can_earn_multiple_times: false).badge
      @multi_badge = world.create_badge(can_earn_multiple_times: true).badges.last

      another_assignment = world.create_assignment.assignments.last
      @another_grade = world.create_grade(assignment: another_assignment).grades.last
    end

    it "should not see badges that aren't included in the current course" do
      some_other_course = create(:course)
      some_other_assignment = create(:assignment, course: some_other_course)
      some_other_grade = create(:grade, assignment: some_other_assignment, assignment_type: some_other_assignment.assignment_type, course: some_other_course, student: world.student)
      some_other_badge = create(:badge, course: some_other_course)
      expect(world.student.earnable_course_badges_for_grade(world.grade)).not_to include(some_other_badge)
    end

    it "should see badges for the current course" do
      EarnedBadge.destroy_all course_id: world.course[:id]
      expect(world.student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge, @multi_badge)
    end

    it "should show course badges that the student has yet to earn", broken: true do
      EarnedBadge.destroy_all course_id: world.course[:id]
      expect(world.student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge, @multi_badge)
    end

    it "should not show badges that the student has earned for other grades, and can't be earned multiple times" do
      world.student.earn_badge_for_grade(@single_badge, @another_grade) # earn the badge on another grade
      expect(world.student.earnable_course_badges_for_grade(world.grade)).not_to include(@single_badge)
    end

    it "should show badges that the student has earned but CAN be earned multiple times", broken: true do
      world.student.earn_badge_for_grade(@multi_badge, world.grade)
      expect(world.student.earnable_course_badges_for_grade(world.grade)).to include(@multi_badge)
    end

    it "should show badges that the student has earned for the current grade, even if it can't be earned multiple times" do
      world.student.earn_badge_for_grade(@single_badge, world.grade)
      expect(world.student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge)
    end
  end

  context "user earns just one badge" do
    before(:each) do
      world
        .create_course
        .create_assignment(course: world.courses.last)
        .create_grade(assignment: world.assignments.last, course: world.courses.last)
      @current_badge = world.create_badge(course: world.courses.last).badges.last
    end

    it "should create a valid earned badge" do
      expect(world.student.earn_badge(@current_badge).class).to eq(EarnedBadge)
      expect(world.student.earn_badge(@current_badge).valid?).to be true
    end

    it "should not error out when earning one badge" do
      expect { world.student.earn_badge(@current_badge) }.to_not raise_error
    end

    it "should choke on an array of badges" do
      expect { world.student.earn_badge([@current_badge])}.to raise_error(TypeError)
    end
  end

  context "student_invisible_badges" do
    it "should return invisible badges for which the student has earned a badge" do
      invisible_badges = create_list(:badge, 2, course: world.course, visible: false)
      world.student.earn_badges(invisible_badges)
      badges_earned_by_id = world.student.student_invisible_badges(world.course)
      expect(badges_earned_by_id).to eq(invisible_badges)
    end

    it "should not return visible badges for which the student has earned a badge" do
      visible_badges = create_list(:badge, 2, course: world.course, visible: true)
      world.student.earn_badges(visible_badges)
      badges_earned_by_id = world.student.student_invisible_badges(world.course).sort_by(&:id)
      expect(badges_earned_by_id).not_to eq(visible_badges.sort_by(&:id))
    end
  end
end
