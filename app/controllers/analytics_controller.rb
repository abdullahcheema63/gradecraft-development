class AnalyticsController < ApplicationController
  before_action :ensure_staff?
  before_action :use_current_course, only: [:students, :staff]

  def students
    @nonpredictors = @course.nonpredictors
  end

  def staff
  end

  private

end
