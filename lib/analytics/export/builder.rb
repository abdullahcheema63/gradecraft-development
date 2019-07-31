require "s3fs"

# This is the base class for the ExportBuilder classes that will ultimately
# construct our final export files. By separating this logic out into a
# dedicated class, we can create individiual builder classes that arrange our
# Analytics::Export::Model classes however we'd like but without having to
# rebuild the archiving mechanism for each one.
#
module Analytics
  module Export
    class Builder
      include FileManager::PathFinder

      attr_reader :export_context, :export_classes, :filename, :directory_name,
                  :export_tmpdir, :export_root_dir, :final_export_tmpdir

      def initialize(export_context:, export_classes:, filename: nil, directory_name: nil)
        @export_context = export_context
        @export_classes = export_classes
        @filename = filename || "exported_files.zip"
        @directory_name = directory_name || "exported_files"

        make_directories
      end

      def build_archive!
        generate_csvs
        build_zip_archive
      end

      # make all of the directories that we're going to use for the export
      #
      def make_directories
        #@export_tmpdir = S3fs.mktmpdir
        #@final_export_tmpdir = S3fs.mktmpdir
        @export_tmpdir = FileManager.make_temp_directories
        @final_export_tmpdir = FileManager.make_temp_directories
        FileUtils.mkdir_p export_root_dir
      end

      # iterate over the classes that we've been given and generate them in the
      # root directory of our export. This method is called #generate_csv right
      # now but should be renamed to #generate_file later to give us a more
      # filetype-agnostic approach.
      #
      def generate_csvs
        exporters.each {|exporter| exporter.write_csv export_root_dir }
      end

      def exporters
        @exporters ||= export_classes.collect do |export_class|
          export_class.new context: export_context
        end
      end

      # assemble all of the generated files
      def build_zip_archive
        begin
          # generate the actual zip file here
          Archive::Zip.archive final_export_filepath, export_root_dir
        ensure
          # return the final export path
          return final_export_filepath
        end
      end

      def final_export_filepath
        File.join final_export_tmpdir, filename
      end

      def export_root_dir
        File.join export_tmpdir, directory_name
      end

      def remove_tempdirs
        [export_root_dir, final_export_tmpdir].each do |tmpdir|
          FileUtils.remove_entry_secure tmpdir
        end
      end
    end
  end
end
