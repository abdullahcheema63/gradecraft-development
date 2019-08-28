module Analytics
  module Export
    module Buildable
      def build_archive!
        export_builder.build_archive!
      end

      def export_builder
        @export_builder ||= Analytics::Export::Builder.new builder_attrs
      end

      def builder_attrs
        {
          export_context: export_context,
          export_classes: export_classes,
          filename: filename,
          directory_name: directory_name
        }
      end
    end
  end
end
