class AddEmailLearningObjectiveAchievedToCourseMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :course_memberships, :email_learning_objective_achieved, :boolean, nil: false, default: true
  end
end
