require_relative "basics"
require_relative "object_summary"

module S3Manager
  class Manager
    include S3Manager::Basics
    include S3Manager::ObjectSummary
  end
end
