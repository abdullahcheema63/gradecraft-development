class S3ResourceTest
  include S3Manager::Resource
  attr_accessor :local_file_path

  def initialize(options={})
    @local_file_path = options[:local_file_path]
  end

  def export_filename
    "some-other-filename"
  end
end
