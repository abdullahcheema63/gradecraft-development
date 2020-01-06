class Ahoy::Message < ApplicationRecord
  self.table_name = "ahoy_messages"

  belongs_to :visit
  belongs_to :user, optional: true
end
