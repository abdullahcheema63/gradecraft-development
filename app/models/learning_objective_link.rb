class LearningObjectiveLink < ApplicationRecord
  include Copyable
  
  belongs_to :learning_objective, foreign_key: :objective_id
  belongs_to :learning_objective_linkable, polymorphic: true
  belongs_to :course

  validates_presence_of :learning_objective

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: { lookups: [:learning_objective, :course] }
    )
  end
end
