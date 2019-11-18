require "showtime"

module Presenters
  module Downloads
    class Base < Showtime::Presenter

      def submissions_exports
        @submissions_exports ||= current_course
          .submissions_exports
          .order("updated_at DESC")
          .includes(:assignment, :course, :team)
      end

      def current_course
        properties[:current_course]
      end

      def current_user
        properties[:current_user]
      end

    end
  end
end
