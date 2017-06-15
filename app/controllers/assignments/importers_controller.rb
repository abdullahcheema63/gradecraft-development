require_relative "../../services/imports_lms_assignments"
require_relative "../../importers/assignment_importers/csv_assignment_importer"

# rubocop:disable AndOr
class Assignments::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  ALLOWED_IMPORTER_IDS = %w(csv).freeze
  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action except: [:index, :show, :download, :upload] do |controller|
    controller.redirect_path assignments_importers_path
  end
  before_action :link_canvas_credentials, except: [:index, :show, :download, :upload],
    if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
  before_action :require_authorization, except: [:index, :show, :download, :upload]
  before_action :use_current_course, except: [:refresh_assignment, :update_assignment, :download]
  before_action :ensure_allows_file_imports, only: [:show, :download, :upload]

  # GET /assignments/importers
  def index
  end

  # GET /assignments/importers/:provider_id
  def show
    render params[:provider_id]
  end

  # Download a sample CSV pre-populated with the correct headers
  # GET /assignments/importers/:importer_provider_id/download
  def download
    respond_to do |format|
      format.csv { send_data CSV.generate { |csv| csv << csv_headers },
        filename: "Sample Assignment File - #{ Date.today }.csv" }
    end
  end

  # GET /assignments/importers/:importer_provider_id/upload
  def upload
    provider = params[:importer_provider_id]

    redirect_to({ action: :show, provider_id: provider },
      notice: "File is missing") and return if params[:csv_file].blank?

    redirect_to({ action: :show, provider_id: provider },
      notice: "File format must be CSV") and return if File.extname(params[:csv_file].original_filename) != ".csv"

    @assignment_types = current_course.assignment_types.ordered.select(:name, :id)
    @data = CSVAssignmentImporter.new(params[:csv_file].tempfile).as_assignment_rows

    render "#{provider}_import_review"
  end

  # POST /assignments/importers/:importer_provider_id/import
  def import

  end

  # Entry point for importing assignments from a provider
  # GET /assignments/importers/:importer_provider_id/assignments
  def assignments
    @provider_name = params[:importer_provider_id]
    @assignment_types = current_course.assignment_types.ordered
  end

  # POST /assignments/importers/:importer_provider_id/courses/:id/assignments
  def assignments_import
    @provider_name = params[:importer_provider_id]
    @course_id = params[:id]

    @result = Services::ImportsLMSAssignments.import @provider_name,
      authorization(@provider_name).access_token, @course_id, params[:assignment_ids],
      @course, params[:assignment_type_id]

    if @result.success?
      render :assignments_import_results
    else
      @assignments = syllabus.assignments(@course_id) do
        redirect_to assignment_importers_path,
          alert: "There was an issue trying to retrieve the assignments from #{@provider_name.capitalize}." and return
      end
      @assignment_types = @course.assignment_types.ordered

      render :assignments, alert: @result.message
    end
  end

  # POST /assignments/importers/:importer_provider_id/assignments/:id/refresh
  def refresh_assignment
    provider_name = params[:importer_provider_id]
    assignment = Assignment.find(params[:id])

    result = Services::ImportsLMSAssignments.refresh provider_name,
      authorization(provider_name).access_token, assignment

    if result.success?
      flash[:notice] = "You have successfully updated #{assignment.name} from #{provider_name.capitalize}"
    else
      flash[:alert] = result.message
    end

    redirect_to assignment_path(assignment)
  end

  # POST /assignments/importers/:importer_provider_id/assignments/:id/update
  def update_assignment
    provider_name = params[:importer_provider_id]
    assignment = Assignment.find(params[:id])

    result = Services::ImportsLMSAssignments.update provider_name,
      authorization(provider_name).access_token, assignment

    if result.success?
      flash[:notice] = "You have successfully updated #{assignment.name} on #{provider_name.capitalize}"
    else
      flash[:alert] = result.message
    end

    redirect_to assignment_path(assignment)
  end

  private

  # Ensure that the provided importer provider id allows uploads, downloads and
  # has a show template
  def ensure_allows_file_imports
    redirect_to({ action: :index },
      notice: "Invalid provider id") if !Assignments::ImportersController::ALLOWED_IMPORTER_IDS.include? \
        (params[:provider_id] || params[:importer_provider_id])
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new \
      @provider_name,
      authorization(@provider_name).access_token
  end

  def csv_headers
    ["Assignment Name", "Assignment Type", "Point Total", "Description",
      "Due Date (mm/dd/yyyy hh:mm:ss AM/PM)"].freeze
  end
end
