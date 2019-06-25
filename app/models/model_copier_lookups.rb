class ModelCopierLookups

    # example:
    # {:courses=>{1=>2}, :badges=>{3=>4}}
    attr_reader :lookup_hash
  
    def initialize
      @lookup_hash = {}
    end
  
    # stores the associated id of the copy by class
    # example:
    # original: course (id: 1)
    # coppied: course (id: 2)
    # store adds :courses=>{1=>2} to the lookup hash
    def store(original, copied)
      type = original.class.name.underscore.pluralize.to_sym
      lookup_hash[type] ||= {}
      lookup_hash[type][original.id] = copied.id
    end
  
    def lookup_has_key?(type, id)
      return false unless lookup_hash[type].present?
      return false unless lookup_hash[type][id].present?
      return true
    end
  
    # returns the id of the copy associated with the original id
    # example: lookup(:badges, 3) returns 4
    def lookup(type, id)
      lookup_hash[type][id] if lookup_has_key?(type, id)
    end
  
    def lookup_key_from_value(type, value_id)
        return lookup_hash[type].key(value_id)
    end

    # lookups = [:courses, :badges]
    # returns: {course_id: 1, badge_id: 4}
    def assign_values_to_attributes(lookups, original)
      lookups.inject({}) do |h, class_type|
  
        # :courses => :course_id
        id_key = "#{class_type.to_s.singularize}_id".to_sym
        id_type = "#{class_type.to_s.singularize}_type".to_sym
  
        if original.respond_to?(id_key) && lookup_has_key?(class_type, original.send(id_key))
          h[id_key] = lookup(class_type, original.send(id_key))
  
        # handle polymorphic relationships
        elsif original.respond_to?(id_type) && lookup_has_key?(original.send(id_type).underscore.pluralize.to_sym, original.send(id_key))
          h[id_key] = lookup(original.send(id_type).underscore.pluralize.to_sym, original.send(id_key))
        end
        h
      end
    end
  end
  