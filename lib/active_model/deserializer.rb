module ActiveModel
  class Deserializer
    extend ActiveSupport::Autoload
    autoload :Configuration
    autoload :Adapter
    include Configuration

    def initialize(params)

    end

    def object

    end
  end
end
