# frozen_string_literal: true
class PlainModel
  class << self
    attr_accessor :attribute_names, :association_names

    def attributes(*names)
      self.attribute_names |= names.map(&:to_sym)
      # Silence redefinition of methods warnings
      silence_warnings do
        attr_accessor(*names)
      end
    end

    def associations(*names)
      self.association_names |= names.map(&:to_sym)
      # Silence redefinition of methods warnings
      silence_warnings do
        attr_accessor(*names)
      end
    end

    def silence_warnings
      original_verbose = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = original_verbose
    end
  end
  self.attribute_names = []
  self.association_names = []

  def initialize(fields = {})
    fields ||= {} # protect against nil
    fields.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    self.class.attribute_names.each_with_object({}) do |attribute_name, result|
      result[attribute_name] = public_send(attribute_name).freeze
    end.freeze
  end

  def associations
    association_names.each_with_object({}) do |association_name, result|
      result[association_name] = public_send(association_name).freeze
    end.freeze
  end
end

class ParentModel < PlainModel
  attributes :id, :name, :description
  associations :child_models, :child_model
end
class ChildModel < PlainModel
  attributes :id, :name
end
