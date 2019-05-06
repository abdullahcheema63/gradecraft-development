class Event < ApplicationRecord
  include Copyable
  include UploadsMedia

  validates_with OpenBeforeCloseValidator

  belongs_to :course

  scope :with_dates, -> { where("events.due_at IS NOT NULL OR events.open_at IS NOT NULL") }

  scope :this_week, -> { where(due_at: Time.current .. 7.days.from_now)}

  # Check to make sure the event has a name before saving
  validates_presence_of :name

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: { prepend: { name: "Copy of "}}
    )
  end
end
