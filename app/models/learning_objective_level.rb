class LearningObjectiveLevel < ActiveRecord::Base
  enum flagged_value: [ :green, :yellow, :red ]

  belongs_to :objective, class_name: "LearningObjective",
    foreign_key: :objective_id

  validates_presence_of :name, :objective, :flagged_value

  scope :ordered, -> { order :order }
end
