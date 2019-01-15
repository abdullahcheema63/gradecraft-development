module EventLogger
  module Exceptions
    class DocumentSizeExceededError < StandardError
      attr_reader :event_attrs

      def initialize(msg, event_attrs)
        @event_attrs = event_attrs
        super("#{msg}; attributes: #{@event_attrs}")
      end
    end
  end
end
