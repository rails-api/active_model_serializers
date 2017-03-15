require 'active_model/serializable/utils'

module ActiveModel
  module Serializable
    def self.included(base)
      base.extend Utils
    end

    def as_json(options={})
      instrument('!serialize') do
        if root = options.fetch(:root, json_key)
          hash = { root => serializable_object(options) }
          hash.merge!(serializable_data)
          hash
        else
          serializable_object(options)
        end
      end
    end

    def serializable_object_with_notification(options={})
      instrument('!serialize') do
        serializable_object(options)
      end
    end

    def serializable_data
      embedded_in_root_associations.tap do |hash|
        if respond_to?(:meta) && meta
          hash[meta_key] = meta
        end
      end
    end

    def namespace
      if module_name = get_namespace
        Serializer.serializers_cache.fetch_or_store(module_name) do
          Utils._const_get(module_name)
        end
      end
    end

    def embedded_in_root_associations
      {}
    end

    private

    def get_namespace
      modules = self.class.name.split('::')
      modules[0..-2].join('::') if modules.size > 1
    end

    def instrument(action, &block)
      payload = instrumentation_keys.inject({ serializer: self.class.name }) do |payload, key|
        payload[:payload] = self.instance_variable_get(:"@#{key}")
        payload
      end
      ActiveSupport::Notifications.instrument("#{action}.active_model_serializers", payload, &block)
    end

    def instrumentation_keys
      [:object, :scope, :root, :meta_key, :meta, :wrap_in_array, :only, :except, :key_format]
    end
  end
end
