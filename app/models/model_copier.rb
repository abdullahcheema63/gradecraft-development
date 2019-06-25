class ModelCopier
  attr_reader :original, :copied, :lookup_store

  def initialize(model, lookup_store=nil)
    @original = model
    @lookup_store = lookup_store || ModelCopierLookups.new
    @copied = original.dup
    @original.readonly!
  end

  def copy(options={})
    attributes = options.delete(:attributes) {{}}
    copied.copy_attributes attributes
    handle_options options.delete(:options) {{}}
    # call save so we have an id on the copy to store
    copied.save
    lookup_store.store(original, copied)
    copy_associations options.delete(:associations) {[]}, attributes
    # copy associations that cross-reference other models, and need to
    # be run after all associations have already been copied.
    copy_associations options.delete(:cross_references) {[]}, attributes
    copied.save_copy_logs(lookup_store) if copied.respond_to?(:save_copy_logs)
    copied
  end

  private

  def copy_associations(associations, attributes)
    ModelAssociationCopier.new(original, copied, lookup_store).copy([associations].flatten, attributes)
  end

  def handle_options(options)
    prepend_attributes options.delete(:prepend) {{}}
    run_lookups options.delete(:lookups) {[]}
    run_overrides options.delete(:overrides) {{}}
  end

  def prepend_attributes(attributes)
    attributes.each_pair do |attribute, text|
      copied.send(attribute).prepend text
    end
  end

  def run_overrides(overrides)
    overrides.each { |override| override.call copied }
  end

  # lookups: [:courses, :badges,...]
  def run_lookups(lookups)
    lookup_store.assign_values_to_attributes(lookups, original).each do |k,v|
      copied[k] = v
    end
  end

  class ModelAssociationCopier
    attr_reader :original, :copied, :lookup_store

    def initialize(original, copied, lookup_store)
      @original = original
      @copied = copied
      @lookup_store = lookup_store
    end

    def copy(associations, attributes)
      associations.each { |association| copy_association(association, attributes) }
    end

    def copy_association(association, attributes)
      if association.is_a? Hash
        add_association_with_attributes association, attributes
      else
        add_association association, attributes
      end
    end

    def add_association_with_attributes(association, attributes)
      parsed = AssociationAttributeParser.new(association).parse(copied)
      add_association parsed.association, attributes.merge(parsed.attributes)
    end

    # This will create duplicates of all associated models from the original,
    # and add them to copied. In the process, the belongs_to id on the association
    # will be correctly updated to the copy id.
    # example:
    # If copied and original are Courses, and association == :badges
    # this will create an array of duplicate badges from original and send:
    # copied.badges << [copied_badge_1, copied_badge_2,...]
    # and all copied_badges course_id will be updated to copied.id
    def add_association(association, attributes)
      copied.send(association).send "<<", original.send(association).map { |child| child.copy(attributes, lookup_store) }
    end
  end

  class AssociationAttributeParser
    attr_reader :association
    attr_reader :attributes

    def initialize(association)
      @association = association
    end

    # target is the copied model
    def parse(target)
      split_attributes_from_association
      @association = association.keys.first
      assign_values_to_attributes target
      self
    end

    # association is specified as { association: { attributes }} and this
    # splits out the attributes
    # for example:
    # assignment_types: { course_id: :id } returns: { course_id: :id }
    def split_attributes_from_association
      @attributes = association.values.inject({}) { |hash, element| hash.merge!(element) }
    end

    # target is the copied model, for each attribute hash, the value is
    # called on the copy and replaces the symbol on in the attributes hash
    # example: if target is a course with id of 555
    # before: @attributes[:course_id] = :id
    # after: @attributes[:course_id] = 555
    def assign_values_to_attributes(target)
      attributes.each_pair do |attribute, value|
        attributes[attribute] = target.send(value) if value.is_a? Symbol
      end
    end
  end
end