class BreadcrumbTrail < Croutons::BreadcrumbTrail

  def analytics_staff
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Staff Analytics", analytics_staff_path)
  end

  def analytics_students
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Student Analytics", analytics_students_path)
  end

  def announcements_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Announcements", announcements_path)
  end

  def announcements_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Announcements", announcements_path)
    breadcrumb("New Announcement", new_announcement_path)
  end

  def announcements_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Announcements", announcements_path)
    breadcrumb(objects[:announcement].title, announcement_path(objects[:announcement]))
  end

  def assignments_importers_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb('Import #{ term_for :assignments }', assignments_importers_path)
  end

  def assignments_settings
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb("Settings", settings_assignments_path)
  end

  def assignments_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
  end

  def assignments_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
  end

  def assignments_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb("Editing " + objects[:assignment].name, assignment_path(objects[:assignment]))
  end

  def assignments_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb('New #{ term_for :assignment }')
  end

  def assignment_type_weights_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb("Edit My Choices", assignment_type_weights_path)
  end

  def assignment_types_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignment Type Analytics", assignment_types_path)
  end

  def assignment_types_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb("New Assignment Type")
  end

  def assignment_types_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignment Types", assignment_types_path)
    breadcrumb("Editing " + objects[:assignment_type].name)
  end
  
  def assignments_groups_grade
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    
  end

  def badges_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :badges}', badges_path)
  end

  def badges_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :badges}', badges_path)
    breadcrumb("Editing " + objects[:badge].name, badge_path(objects[:badge]))
  end

  def badges_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :badges}', badges_path)
    breadcrumb(objects[:badge].name, badge_path(objects[:badge]))
  end

  def badges_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :badges}', badges_path)
    breadcrumb('New #{term_for :badge}', new_badge_path)
  end

  def challenges_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
  end

  def challenges_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb("Editing " + objects[:challenge].name, assignment_path(objects[:challenge]))
  end

  def challenges_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
  end

  def challenges_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb("New Challenge", new_challenge_path)
  end

  def challenge_grades_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
    breadcrumb('Editing #{ term_for :challenge } Grade')
  end

  def challenge_grades_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
    breadcrumb(objects[:challenge_grade].team.name + "'s Challenge Grade")
  end

  def challenges_challenge_grades_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
    breadcrumb('New #{ term_for :challenge } Grade', new_challenge_challenge_grade_path(objects[:challenge]))
  end

  def challenges_challenge_grades_mass_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :challenges }', challenges_path)
    breadcrumb(objects[:challenge].name, challenge_path(objects[:challenge]))
  end

  def courses_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Courses", courses_path)
  end

  def courses_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Courses", courses_path)
    breadcrumb("New Course", course_new_path)
  end

  def courses_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Basic Settings")
  end

  def courses_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb(objects[:course].name, course_path(objects[:course]))
  end

  def courses_player_settings
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Player Settings", player_settings_path)
  end

  def courses_multiplier_settings
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Multiplier Settings", multiplier_settings_path)
  end

  def courses_student_onboarding_setup
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Student Onboarding Setup", student_onboarding_setup_path)
  end

  def courses_course_details
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Course Details", course_details_path)
  end

  def courses_custom_terms
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Custom Terms", custom_terms_path)
  end

  def earned_badges_edit
    breadcrumb("Dashboard", dashboard_path)
<<<<<<< df1c20c6f678ecf04031ea28e3d872a9bbeb5ecb
    breadcrumb("Badges", badges_path)
=======
    breadcrumb('#{ term_for :badges }', badges_path)
>>>>>>> Import users breadcrumbs
    breadcrumb("Editing Awarded " + objects[:earned_badge].name)
  end

  def earned_badges_mass_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Badges", badges_path)
    breadcrumb("Quick Award " + objects[:badge].name)
  end

  def earned_badges_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Badges", badges_path)
    breadcrumb("Award " + objects[:badge].name)
  end

  def earned_badges_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Badges", badges_path)
    breadcrumb(objects[:earned_badge].student.name + "'s " + objects[:earned_badge].name + " Badge")
  end

  def groups_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Groups", groups_path)
  end

  def groups_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Groups", groups_path)
    breadcrumb(objects[:group].name + " Group")
  end

  def groups_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Groups", groups_path)
    breadcrumb("New Group")
  end

  def groups_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Groups", groups_path)
    breadcrumb("Editing " + objects[:group].name + " Group")
  end

  def info_dashboard
    breadcrumb("Dashboard", dashboard_path)
  end

  def info_earned_badges
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Awarded Badges")
  end

  def info_predictor
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Predictor Preview", predictor_path)
  end

  def info_grading_status
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Grading Status", grading_status_path)
  end

  def info_per_assign
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Assignment Analytics", per_assign_path)
  end

  def info_top_10
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Top 10/Bottom 10", top_10_path)
  end

  def downloads_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Course Data Exports", downloads_path)
  end

  def events_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
  end

  def events_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
    breadcrumb(objects[:event].name, event_path(objects[:event]))
  end

  def events_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
    breadcrumb("Editing " + objects[:event].name)
  end

  def events_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Calendar Events", events_path)
    breadcrumb("New Event", new_event_path)
  end

  def grade_scheme_elements_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Grading Scheme", grade_scheme_elements_path)
  end

  def grade_scheme_elements_mass_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Editing Grading Scheme")
  end

  def grades_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)
    breadcrumb('#{ @grade.assignment.name }', assignment_path(objects[:grade].assignment))
    breadcrumb("Editing Grade")
  end

  def grades_importers_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_csv
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_assignments
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_courses
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_grades
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_grades_import_results
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def grades_importers_import_results
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{term_for :assignments}', assignments_path)

  end

  def rubrics_design
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :assignments }', assignments_path)
    breadcrumb(objects[:assignment].name, assignment_path(objects[:assignment]))
    breadcrumb("Design Rubric")
  end

  def staff_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Staff", staff_index_path)
  end

  def staff_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Staff", staff_index_path)
    breadcrumb(objects[:staff_member].name)
  end

  def students_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :students }')
  end

  def students_flagged
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Students", students_path)
    breadcrumb("Flagged Students", flagged_students_path)
  end

  def students_leaderboard
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Leaderboard", leaderboard_path)
  end

  def students_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :students }', students_path)
  end
  
  def submissions_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb(objects[:submission].assignment.name, assignment_path(objects[:submission].assignment))
  end
  
  def teams_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :teams }', teams_path)
  end

  def teams_show
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :teams }', teams_path)
    breadcrumb(objects[:team].name)
  end

  def teams_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :teams }', teams_path)
    breadcrumb("Editing " + objects[:team].name)
  end

  def teams_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb('#{ term_for :teams }', teams_path)
    breadcrumb('New #{ term_for :team }')
  end

  def users_edit
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Users", users_path)
    breadcrumb("Editing " + objects[:user].name)
  end

  def users_import
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Users", users_path)
    breadcrumb("Import Users")
  end
  
  def users_import_results
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Users", users_path)
    breadcrumb("Imported Users")
  end

  def users_index
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Users", users_path)
  end

  def users_new
    breadcrumb("Dashboard", dashboard_path)
    breadcrumb("Users", users_path)
    breadcrumb("New User")
  end
end
