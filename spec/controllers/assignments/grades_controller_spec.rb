require "rails_spec_helper"

describe Assignments::GradesController do
  before(:all) do
    @course = create(:course_accepting_groups)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @student.courses << @course
  end
  before(:each) do
    @grade = create :grade, student: @student, assignment: @assignment,
      course: @course
  end
  after(:each) { @grade.delete }

  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end
    before (:each) { login_user(@professor) }

    describe "GET download" do
      it "returns sample csv data" do
        get :download, assignment_id: @assignment, format: :csv
        expect(response.body).to \
          include("First Name,Last Name,Email,Score,Feedback")
      end
    end

    describe "GET edit_status" do
      it "assigns params" do
        get :edit_status, { assignment_id: @assignment.id, grade_ids: [@grade.id] }
        expect(assigns(:title)).to eq("#{@assignment.name} Grade Statuses")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:grades)).to eq([@grade])
        expect(response).to render_template(:edit_status)
      end
    end

    describe "PUT update_status" do
      it "updates the grade status for grades" do
        put :update_status, { assignment_id: @assignment.id, grade_ids: [@grade.id], grade: { status: "Graded" }}
        expect(@grade.reload.status).to eq("Graded")
      end

      it "redirects to session if present"  do
        session[:return_to] = login_path
        put :update_status, { assignment_id: @assignment.id, grade_ids: [@grade.id], grade: { status: "Graded" }}
        expect(response).to redirect_to(login_path)
      end
    end

    describe "GET export" do
      it "returns sample csv data" do
        submission = create(:submission, grade: @grade, student: @student,
                            assignment: @assignment)
        get :export, assignment_id: @assignment, format: :csv
        expect(response.body).to \
          include("First Name,Last Name,Email,Score,Feedback,Raw Score,Statement")
      end
    end

    describe "GET import" do
      it "displays the import page" do
        get :import, { assignment_id: @assignment.id}
        expect(assigns(:title)).to eq("Import Grades for #{@assignment.name}")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(response).to render_template(:import)
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "grades.csv", "text/csv" }

      it "renders the results from the import" do
        @student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy")
        second_student.courses << @course
        post :upload, assignment_id: @assignment.id, file: file
        expect(response).to render_template :import_results
        expect(response.body).to include "2 Grades Imported Successfully"
      end

      it "renders any errors that have occured" do
        post :upload, assignment_id: @assignment.id, file: file
        expect(response.body).to include "3 Grades Not Imported"
        expect(response.body).to include "Student not found in course"
      end

      it "adds error and redirects without a file" do
        post :upload, assignment_id: @assignment.id
        expect(flash[:notice]).to eq("File is missing")
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end

    describe "GET index" do
      it "redirects to the assignments show view if the assigment is not a rubric" do
        allow(@assignment).to receive(:grade_with_rubric?).and_return false
        get :index, assignment_id: @assignment.id
        expect(response).to redirect_to assignment_path(@assignment)
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, assignment_id: @assignment.id
        expect(assigns(:title)).to eq("Quick Grade #{@assignment.name}")
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:assignment_type)).to eq(@assignment.assignment_type)
        expect(assigns(:assignment_score_levels)).to eq(@assignment.assignment_score_levels)
        expect(assigns(:grades)).to eq([@grade])
        expect(assigns(:students)).to eq([@student])
        expect(response).to render_template(:mass_edit)
      end

      it "creates missing grades and orders grades by student name" do
        student_2 = create(:user, last_name: "zzimmer", first_name: "aaron")
        student_3 = create(:user, last_name: "zzimmer", first_name: "zoron")
        [student_2,student_3].each {|s| s.courses << @course }
        expect{ get :mass_edit, assignment_id: @assignment.id }.to \
          change{Grade.count}.by(2)
        expect(assigns(:grades)[1].student).to eq(student_2)
        expect(assigns(:grades)[2].student).to eq(student_3)
      end

      context "with teams" do
        it "assigns params" do
          team = create(:team, course: @course)
          team.students << @student
          get :mass_edit, assignment_id: @assignment.id, team_id: team.id
          expect(assigns(:students)).to eq([@student])
          expect(assigns(:team)).to eq(team)
        end
      end
    end

    describe "PUT mass_update" do
      let(:grades_attributes) do
        { "#{@assignment.reload.grades.index(@grade)}" =>
          { graded_by_id: @professor.id, instructor_modified: true,
            student_id: @grade.student_id, raw_score: 1000, status: "Graded",
            id: @grade.id
          }
        }
      end

      it "updates the grades for the specific assignment" do
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.raw_score).to eq 1000
      end

      it "timestamps the grades" do
        current_time = DateTime.now
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.graded_at).to be > current_time
      end

      it "only sends notifications to the students if the grade changed" do
        @grade.update_attributes({ raw_score: 1000 })
        run_background_jobs_immediately do
          expect { put :mass_update, assignment_id: @assignment.id,
                   assignment: { grades_attributes: grades_attributes } }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end
      end

      it "redirects to assignment path with a team" do
        team = create(:team, course: @course)
        put :mass_update, assignment_id: @assignment.id, team_id: team.id,
          assignment: { grades_attributes: grades_attributes }
        expect(response).to \
          redirect_to(assignment_path(@assignment, team_id: team.id))
      end

      it "redirects on failure" do
        allow_any_instance_of(Assignment).to \
          receive(:update_attributes).and_return false
        put :mass_update, assignment_id: @assignment.id,
          assignment: { grades_attributes: grades_attributes }
        expect(response).to \
          redirect_to(mass_edit_assignment_grades_path(@assignment))
      end
    end

    describe "POST self_log" do
      it "redirects back to the root" do
        expect(post :self_log, assignment_id: @assignment.id ).to \
          redirect_to(:root)
      end
    end
  end

  context "as student" do
    before do
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    describe "POST self_log" do
      context "with a student loggable grade" do
        before(:all) { @assignment.update(student_logged: true) }

        it "creates a maximum score by the student if present" do
          post :self_log, assignment_id: @assignment.id
          grade = @student.grade_for_assignment(@assignment)
          expect(grade.raw_score).to eq @assignment.point_total
        end

        it "reports errors on failure to save" do
          allow_any_instance_of(Grade).to receive(:save).and_return false
          post :self_log, assignment_id: @assignment.id
          grade = @student.grade_for_assignment(@assignment)
          expect(flash[:notice]).to \
            eq("We're sorry, there was an error saving your grade.")
        end

        context "with assignment levels" do
          it "creates a score for the student at the specified level" do
            post :self_log, assignment_id: @assignment.id,
              grade: { raw_score: "10000" }
            grade = @student.grade_for_assignment(@assignment)
            expect(grade.raw_score).to eq 10000
          end
        end
      end

      context "with an assignment not student loggable" do
        before(:all) { @assignment.update(student_logged: false) }

        it "creates should not change the student score" do
          post :self_log, assignment_id: @assignment.id
          grade = @student.grade_for_assignment(@assignment)
          expect(grade.raw_score).to eq nil
        end
      end
    end

    describe "GET download" do
      it "redirects back to the root" do
        expect(get :download, assignment_id: @assignment, format: :csv).to \
          redirect_to(:root)
      end
    end

    describe "GET edit_status" do
      it "redirects back to the root" do
        expect(get :edit_status, assignment_id: @assignment).to \
          redirect_to(:root)
      end
    end

    describe "GET update_status" do
      it "redirects back to the root" do
        expect(put :update_status, assignment_id: @assignment).to \
          redirect_to(:root)
      end
    end

    describe "GET export" do
      it "redirects back to the root" do
        expect(get :export, assignment_id: @assignment, format: :csv).to \
          redirect_to(:root)
      end
    end

    describe "GET import" do
      it "redirects back to the root" do
        expect(get :import, { assignment_id: @assignment }).to \
          redirect_to(:root)
      end
    end

    describe "POST upload" do
      it "redirects back to the root" do
        expect(post :upload, { assignment_id: @assignment }).to \
          redirect_to(:root)
      end
    end

    describe "GET index" do
      it "redirects back to the root" do
        expect(get :index, { assignment_id: @assignment }).to \
          redirect_to(:root)
      end
    end

    describe "GET mass_edit" do
      it "redirects back to the root" do
        expect(get :mass_edit, { assignment_id: @assignment.id  }).to \
          redirect_to(:root)
      end
    end

    describe "PUT mass_update" do
      it "redirects back to the root" do
        expect(get :mass_update, { assignment_id: @assignment.id  }).to \
          redirect_to(:root)
      end
    end
  end
end