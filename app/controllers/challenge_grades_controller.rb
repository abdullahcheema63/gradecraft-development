class ChallengeGradesController < ApplicationController

  before_action :ensure_staff?, except: [:show]
  before_action :find_challenge_grade
  before_action :find_challenge
  before_action :use_current_course

  # GET /challenge_grades/:id
  def show
    @team = @challenge_grade.team
  end

  # GET /challenge_grades/:id/edit
  def edit
    @team = @challenge_grade.team
  end

  # POST /challenges_grades/:id
  def update
    @team = @challenge_grade.team
    if @challenge_grade.update_attributes(challenge_grade_params)
      @challenge_grade.update(instructor_modified: true)
      if @challenge_grade.student_visible?
        ChallengeGradeUpdaterJob.perform_async(@challenge_grade.id)
      end

      redirect_to challenge_path(@challenge),
        notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully updated"
    else
      render action: "edit"
    end
  end

  # DELETE /challenge_grades/:id
  # May be worth it to pull this into a service
  def destroy
    @team = @challenge_grade.team

    @challenge_grade.destroy
    @team.challenge_grade_score
    @team.students.each do |student|
      ScoreRecalculatorJob.perform_async(student.id, current_course.id)
    end
    @team.average_score

    redirect_to challenge_path(@challenge),
      notice: "#{@team.name}'s grade for #{@challenge.name} has been successfully deleted."
  end

  private

  def challenge_grade_params
    params.require(:challenge_grade).permit(
      :adjustment_points, :adjustment_points_feedback, :challenge_id, :complete,
      :feedback, :final_points, :instructor_modified, :name, :raw_points,
      :status, :student_visible, :team_id
    )
  end

  def find_challenge
    find_challenge_grade
    @challenge ||= @challenge_grade.challenge
  end

  def find_challenge_grade
    @challenge_grade ||= current_course.challenge_grades.find(params[:id])
  end
end
