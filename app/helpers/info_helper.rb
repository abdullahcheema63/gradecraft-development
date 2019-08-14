module InfoHelper
  def any_one_assignment_has_two_submissions?(assignment_types)
    assignment_types.each do |assignment_type|
      if assignment_type.assignments.select {|a| a.grades.student_visible.length > 1}.present?
        return true
      end
    end    
    return false
  end
end