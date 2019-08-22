class RedocumentsController < ApplicationController
    def download
      file_url = "#{Rails.root}#{request.original_fullpath}"

      if file_is_submission? || !File.exist?(URI.decode(file_url))
        not_found
      end
      send_file URI.decode(file_url), :x_sendfile=>true
    end

    def file_is_submission?
      submission_file_regex = Regexp.new("\/files\/uploads\/.*\/assignments\/.*\/submission_files\/.*\/.*")
      request.original_fullpath =~ submission_file_regex
    end
    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end
  end
