class LearningObjectiveCategory < ApplicationRecord
  include Copyable

  belongs_to :course

  has_many :learning_objectives, foreign_key: :category_id, dependent: :destroy

  validates_presence_of :course, :name

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: { lookups: [:learning_objectives, :course] }
    )
  end
end
