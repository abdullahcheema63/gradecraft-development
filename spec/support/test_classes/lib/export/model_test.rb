require "export"

class ExportModelTest
  include Export::Model
  attr_accessor :local_file_path

  def initialize(options={})
    @local_file_path = options[:local_file_path]
  end
end
