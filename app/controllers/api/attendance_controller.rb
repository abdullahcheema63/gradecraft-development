class API::AttendanceController < ApplicationController
  before_action :ensure_staff?
  before_action :find_event, only: [:update, :destroy]

  # GET /api/attendance
  def index
    @assignments = current_course
      .assignments
      .ordered
      .with_attendance_type
  end

  # POST /api/attendance
  def create
    @attendance_event = current_course.assignments.new \
      assignment_params.merge(assignment_type_id: AssignmentType.attendance_type_for(current_course).id)

    if save_attendance_event
      render "api/attendance/show", status: 201
    else
      render json: {
        message: "Failed to create attendance event",
        errors: @attendance_event.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/attendance/:id
  def update
    if @attendance_event.update_attributes assignment_params
      render "api/attendance/show", status: 200
    else
      render json: {
        message: "Failed to update attendance event",
        errors: @attendance_event.errors.messages,
        success: false
      }, status: 400
    end
  end

  # DELETE /api/attendance/:id
  def destroy
    @attendance_event.destroy

    if @attendance_event.destroyed?
      render json: { message: "Successfully deleted #{@attendance_event.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@attendance_event.name}", success: false },
        status: 500
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit :id, :name, :description,
      :open_at, :due_at, :full_points, :pass_fail, :media, :position
  end

  def find_event
    @attendance_event = current_course.assignments.find params[:id]
  end

  # If position was provided via the params, disable acts_as_list gem
  # so that it doesn't override; otherwise, leave it on and it will
  # automatically assign a position
  def save_attendance_event
    if assignment_params[:position].nil?
      @attendance_event.save
    else
      Assignment.acts_as_list_no_update do
        @attendance_event.save
      end
    end
  end
end
