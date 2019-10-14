class LearningObjectiveOutcomesExporterJob
  include Sidekiq::Worker

  def perform(user_id, course_id, filename=nil)
    user = User.find(user_id)
    course = Course.includes(learning_objectives: [cumulative_outcomes: :observed_outcomes]).find(course_id)

    fetch_csv_data(course)
    notify_learning_objectives_outcomes_export(user, course, filename)
  end

  private

  attr_accessor :csv_data

  def fetch_csv_data(course)
    @csv_data = LearningObjectivesOutcomesExporter.new(course).learning_objective_outcomes
  end

  def notify_learning_objectives_outcomes_export(user, course, filename)
    ExportsMailer
      .learning_objectives_outcomes_exporter(course, user, filename, @csv_data)
      .deliver_now
  end
end
