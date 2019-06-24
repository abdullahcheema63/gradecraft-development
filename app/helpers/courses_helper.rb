module CoursesHelper
  def current_courses_cache_key(user)
    multi_cache_key :current_user_current_courses, user
  end

  def archived_courses_cache_key(user)
    multi_cache_key :current_user_archived_courses, user
  end

  def available_roles(course)
    roles = [["Student", "student"]]
    if current_user.is_professor?(course) || current_user.is_admin?(course)
      roles << ["GSI", "gsi"]
      roles << ["Professor", "professor"]
      roles << ["Observer", "observer"]
    end
    roles << ["Admin", "admin"] if current_user.is_admin?(course)
    roles
  end

  def bust_course_list_cache(user)
    expire_fragment current_courses_cache_key(user)
    expire_fragment archived_courses_cache_key(user)
  end

  def fix_learning_objectives_and_assignments_links(original_course, copied_course)
    copied_course.learning_objectives.each do |copied_learning_objective|
      original_learning_objective = find_original_learning_objective(original_course, copied_learning_objective)

      puts "Original Learning Objective: #{original_learning_objective.inspect}"

      add_assignment_links_to_learning_objectives(copied_course, original_learning_objective, copied_learning_objective)
    end
  end

  def find_original_learning_objective(original_course, copied_learning_objective)
    return original_course.learning_objectives.find_by(name: copied_learning_objective.name, description: copied_learning_objective.description, count_to_achieve: copied_learning_objective.count_to_achieve, points_to_completion: copied_learning_objective.points_to_completion)
  end

  def has_linked_assignments?(learning_objective)
    return learning_objective.assignments.length > 0
  end

  def add_assignment_links_to_learning_objectives(copied_course, original_learning_objective, copied_learning_objective)
    original_learning_objective.assignments.each do |assignment|
      copied_assignment = copied_course.assignments.find_by(name: assignment.name, \
                                                            description: assignment.description, \
                                                            full_points: assignment.full_points)
      copied_learning_objective.assignments.push(copied_assignment)
    end
  end

  def fix_learning_objectives_category(course)
    course.learning_objectives.each do |learning_objective|
      if learning_objective.category.present?
        learning_objective.category = course.learning_objective_categories.find_by(name: learning_objective.category.name)
      end
    end
  end
end