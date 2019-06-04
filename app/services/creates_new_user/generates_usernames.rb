module Services
  module Actions
    class GeneratesUsernames
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]

        if user.username.blank?
          user.username = generate_username_from_email(user.email)
        end
        
        if user.internal?
          user.email = email_from_username(user.username) if user.email.blank?
          user.kerberos_uid = user.username
        end
      end

      private

      def self.email_from_username(username)
        "#{username}@umich.edu"
      end

      def self.generate_username_from_email(user_email)
        new_username = user_email.split(/@/).first
        
        username_duplicates = User.where(username: new_username).length
      
        if username_duplicates > 0
          changed_username_duplicates = User.where("username ~* ?", new_username.to_s + '_\d+').length
          new_username += "_#{username_duplicates + changed_username_duplicates}"
        end

        return new_username
      end
    end
  end
end
