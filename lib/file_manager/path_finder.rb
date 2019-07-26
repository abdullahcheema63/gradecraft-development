require "fileutils"

module FileManager
  module PathFinder

    def self.included(base)
      base.class_eval do
        # rebuild the object key for the new filename if the filename has
        # changed for the resource, but only if the target resources is a
        # descendant of ActiveRecord::Base
        #
        if defined?(ActiveRecord) && base.ancestors.include?(ActiveRecord::Base)

         # let's save the name of the export on create so we don't have to do
         # it later. also this needs to be done before we rebuild the export
         # filename as otherwise the object key rebuild won't trigger
         #
         before_save :cache_export_filename, unless: :export_filename

         # let's build and save this on create even though we don't have the
         # created_at timestamp from the creation itself, this prevents us from
         # needing to save the resource twice just to get the creation timestamp
         #
         before_save :rebuild_file_path, if: :export_filename_changed?

        end
      end
    end

    def upload_file(file_path)
      puts("made it into resource#upload_file")
      return false unless s3_object_key
      puts("made it into resource#upload_file after return false")
      FileUtils.cp(file_path, s3_object_key)
    end

    def s3_object_exists?
      return false unless s3_object_key
      s3_object_summary.exists?
    end

    def presigned_s3_url
      return unless s3_object_key
      s3_manager.bucket.object(s3_object_key)
        .presigned_url(:get, expires_in: 604800).to_s
    end

    def rebuild_file_path
      self.s3_object_key = build_file_path export_filename
    end

    def build_file_path(object_filename)
      key_pieces = [ s3_object_key_prefix, object_filename ]
      key_pieces.join "/"
    end

    def cache_export_filename
      self[:export_filename] = url_safe_filename
    end
  end
end
