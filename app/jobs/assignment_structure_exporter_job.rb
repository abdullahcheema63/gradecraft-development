require_relative "../services/creates_assignment_structure_export"

class AssignmentStructureExporterJob
  include Sidekiq::Worker
  sidekiq_options retry: 5

  attr_reader :errors

  def perform(user_id, course_id, host_url, csv_file)
    Services::CreatesAssignmentStructureExport.call user_id, course_id, host_url, csv_file 
  end
end
