ActionController::TestCase.class_eval do
  def setup
    @routes = TestHelper::Routes
  end

  # For Rails5
  # https://github.com/rails/rails/commit/ca83436d1b3b6cedd1eca2259f65661e69b01909#diff-b9bbf56e85d3fe1999f16317f2751e76L17
  def assigns(key = nil)
    assigns = {}.with_indifferent_access
    @controller.view_assigns.each { |k, v| assigns.regular_writer(k, v) }
    key.nil? ? assigns : assigns[key]
  end

  # Rails5: Uncomment for debugging where the warnings come from
  # def non_kwarg_request_warning
  #   super
  #   STDOUT.puts caller[2..3]
  # end
end
