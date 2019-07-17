class RedocumentsController < ApplicationController
    def download
        send_file "#{Rails.root}#{request.original_fullpath}", :x_sendfile=>true
    end
  end
  