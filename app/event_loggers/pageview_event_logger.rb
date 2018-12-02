class PageviewEventLogger < ApplicationEventLogger
  include EventLogger::Enqueue
  include Mongoid::Clients

  # queue to use for login event jobs
  @queue = :pageview_event_logger

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

  # def enqueue(time_until_start)
  #   raise "Failed to enqueue pageview event logger job due to exceeded document size; attributes: #{event_attrs}" \
  #     if document_exceeded_maximum_size?
  #   enqueue_in_with_fallback(time_until_start)
  # end

  # private

  # def document_exceeded_maximum_size?
  #   client = Mongoid::Clients.default
  #   client[:course_pageviews].find({ course_id: 110 }).first.to_bson.length >= 150000
  # end
end

class DocumentSizeExceededError < StandardError
  attr_reader :details

  def initialize(details, msg="One or more associations were invalid")
    @details = details
    super(msg)
  end
end
