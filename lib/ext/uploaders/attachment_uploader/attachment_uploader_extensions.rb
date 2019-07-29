require 'securerandom'

module AttachmentUploaderExtensions
    def to_s
        token = get_file_token
        return "#{self.path}?file_token=#{token}"
    end

    def get_file_token
        tokens = []
        file_token = SecureRandom.hex(30)
        tokens.push(file_token)
        return file_token
    end
end
