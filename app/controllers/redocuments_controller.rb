class RedocumentsController < ApplicationController
    def download
        puts Rails.root
        puts "#{Rails.root}#{request.original_fullpath}"
        send_file "#{Rails.root}#{request.original_fullpath}", :x_sendfile=>true
    end
  end
  