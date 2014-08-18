class TestCase < Minitest::Test
  before_setup do
    @original_configurations = {}

    ActiveModel::Serializer.setup do |config|
      config.each do |k, v|
        @original_configurations[k] = v
      end
    end
  end

  after_teardown do
    ActiveModel::Serializer.setup do |config|
      config.clear
      @original_configurations.each do |k, v|
        config.send("#{k}=", v)
      end
    end
  end
end
