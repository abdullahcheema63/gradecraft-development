require 'fileutils'
require 'nokogiri'

module Services
  module Actions
    class CopyImages
      extend LightService::Action

      expects :course, :current_user, :images_directory
      promises :has_images, :course, :current_user

      executed do |context|
        images_paths = []
        ImagePath = Struct.new(:path, :name)

        context.course.assignments.each do |assignment|
          images_paths += self.named_image_paths(assignment.description, \
                                                 context.course_id, \
                                                 "#{assignment.name} - Description - Image")

          images_paths += self.named_image_paths(assignment.description, \
                                                 context.course_id, \
                                                 "#{assignment.name} - Purpose - Image")
        end

        puts "====================================================="
        puts "Image paths: "

        images_paths.each do |image_path|
          puts image_path.path, image_path.name
        end

        context.has_images = false

        context.has_images = true if images_paths.length > 0

        puts "context_has_images: #{context.has_images}"
        puts "context: #{context}"
        puts "====================================================="

        if context.has_images
          self.copy_images(images_paths, context.images_directory)
        else
          self.remove_images_directory(context.images_directory)
        end
      end

      def self.named_image_paths(assignment_structure_details, course_id, common_name)
        current_images_paths = self.get_image_paths(assignment_structure_details, course_id)
        image_paths_named = []
        images_paths_count = 1
        current_images_paths.each do |current_image_path|
          image_path = ImagePath.new(current_image_path, "#{common_name} #{images_paths_count}")
          image_paths_named.push(image_path)
          images_paths_count += 1
        end

        image_paths_named
      end

      def self.get_image_paths(assignment_structure_details, course_id)
        assignment_structure_details_html = Nokogiri::HTML(assignment_structure_details)
        
        images_paths = []

        assignment_structure_details_html.search('img').each do |inline_image_upload|
          froala_images_url = "/api/download_froala_object/"
          inline_image_file = (inline_image_upload['src'])[froala_images_url.length..-1]
          inline_image_file = "#{Rails.root}/files/uploads/#{course_id}/froala_uploads/#{inline_image_file}"
          images_paths.push(inline_image_file)
        end

        images_paths
      end

      def self.copy_images(images_paths, images_directory)
        images_paths.each do |image_path|
          image_source = image_path.path
          image_destination = [images_directory, image_path.name].join('/')
          FileUtils.cp(image_source, image_destination)
        end
      end

      def self.remove_images_directory(images_directory)
        FileUtils.rm_rf(images_directory)
      end
    end
  end
end
