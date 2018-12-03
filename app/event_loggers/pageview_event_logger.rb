class PageviewEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue
  include Mongoid::Clients

  # queue to use for login event jobs
  @queue = :pageview_event_logger

  @fatal_exceptions = [Mongo::Error::OperationFailure]

  attr_accessor :page

  # used by enqueuing methods in EventLogger::Enqueue
  def event_type
    "pageview"
  end

  def event_attrs
    application_attrs.merge page: page
  end

  def page
    @page ||= event_session[:request].try(:original_fullpath)
  end

  # params method is defined in ApplicationEventLogger
  def build_page_from_params
    return if params.nil? || !params[:url].present?
    @page = "#{params[:url]}#{params[:tab]}"
  end

  def enqueue_in_and_check_with_fallback(time_until_start)
    raise EventLogger::Exceptions::DocumentSizeExceededError.new(
      "Failed to enqueue pageview event logger job due to exceeded document size; attributes",
      event_attrs
    ) if documents_exceeded_maximum_size?

    enqueue_in_with_fallback(time_until_start)
  end

  private

  # checks all pageview-related collections (aggregates) for the corresponding course document and ensures that not any one
  #   or more has exceeded the 16mb imposed by MongoDB; going to stop it at 15mb just to be safe
  #
  # collections: course_pageviews, course_user_pageviews, course_user_page_pageviews, course_pageview_by_times,
  #   course_page_pageviews, course_role_pageviews, course_role_page_pageviews
  def documents_exceeded_maximum_size?
    client = Mongoid::Clients.default
    document_exceeded_states = Analytics.configuration.event_aggregates[:pageview].map do |aggr|
      collection = aggr.name.pluralize.underscore # e.g. CoursePageview => course_pageviews
      documents = client[collection].find({ course_id: event_attrs[:course_id] })
      !documents.blank? && documents.first.to_bson.length >= 15000000
    end
    document_exceeded_states.any?
  end
end
