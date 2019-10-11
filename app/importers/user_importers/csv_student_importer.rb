require "csv"
require_relative "../../services/creates_new_user"
require_relative "../../services/creates_course_membership"

class CSVStudentImporter
  attr_reader :successful, :unsuccessful, :course
  attr_accessor :file, :internal_students, :send_welcome

  def initialize(file, course, internal_students=false, send_welcome=false)
    @file = file
    @course = course
    @internal_students = internal_students
    @send_welcome = send_welcome
    @successful = []
    @unsuccessful = []
  end

  def team_exists?(course_id, team_name)
    Team.where("course_id = ? AND lower(name) = ?", course_id, team_name.downcase).any?
  end

  def find_team(course_id, team_name)
    Team.where("course_id = ? AND lower(name) = ?", course_id, team_name.downcase).first
  end

  def find_or_create_teams(course_id, team_name)
    if team_exists?(course_id, team_name)
        team = find_team(course_id, team_name)
    else
        team = Team.new(course_id: course_id, name: team_name)
        team.save!
    end

    team
  end

  def import
    if file
      CSV.foreach(file, headers: true, skip_blanks: true, encoding: "iso-8859-1:utf-8") do |line|
        strip_whitespace line
        row = UserRow.new line

        team = find_or_create_teams(course.id, row.team_name) if row.team_name.present?

        if team.present? && !team.valid?
          append_unsuccessful row, team.errors.full_messages.join(", ")
          next
        end

        result = Services::CreatesOrUpdatesUser.call row.to_h.merge(internal: internal_students), course, send_welcome
        user = result[:user] if result.success?

        unless result.success? && user.valid?
          append_unsuccessful row, "Unable to create or update user"
          next
        end

        if check_user(user, team, course)
          append_unsuccessful row, "Unable to import this user, they have already been added to the course"
          next
        end

        unless Services::CreatesCourseMembership.call(user, course).success?
          append_unsuccessful row, "Unable to add this user to the course"
          next
        end

        team.students << user if team
        successful << user
      end
    end

    self
  end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  def check_user(user, team, course)
    if team.nil?
      return false unless !user.course_memberships.where(course_id: course.id).first.nil?
      return true
    else
      return false unless !user.course_memberships.where(course_id: course.id).first.nil? && !user.team_memberships.where(team_id: team.id).empty?
      return true
    end
  end

  def strip_whitespace(row)
    row.each_with_index { |field, index| row[index].strip! if row[index] }
  end

  class UserRow
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def first_name
      data[0]
    end

    def last_name
      data[1]
    end

    def username
      data[2]
    end

    def email
      data[3]
    end

    def team_name
      data[4]
    end

    def password
      data[5]
    end

    def to_s
      data.to_s
    end

    def to_h
      {
        first_name: first_name,
        last_name: last_name,
        email: email,
        username: username,
        password: password
      }
    end
  end
end
