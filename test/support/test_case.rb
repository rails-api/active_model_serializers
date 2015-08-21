ActionController::TestCase.class_eval do
  def setup
    @routes = TestHelper::Routes
  end
end
