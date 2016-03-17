# determines if a `Grade` resource can be viewed within a specific
# user and course context
class GradeProctor
  module Viewable
    include Base

    def viewable?(user=nil, course=nil)
      return false if grade.nil?

      user ||= grade.student
      course ||= grade.course

      grade_for_course?(course) &&
        (user.is_staff?(course) ||
          (grade_for_user?(user) && grade_visible_by_student?))
    end

    private

    def grade_visible_by_student?
      grade.is_released? ||
        (grade.is_graded? && !grade.assignment.release_necessary?)
    end
  end
end
