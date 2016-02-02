require_relative './benchmarking_support'
require_relative './app'
include Benchmark::ActiveModelSerializers::TestMethods

class ApiAssertion
  BadRevisionError = Class.new(StandardError)

  def valid?
    caching = get_caching
    STDERR.puts caching[:body].delete('meta')
    non_caching = get_non_caching
    STDERR.puts non_caching[:body].delete('meta')
    assert_responses(caching, non_caching)
  rescue BadRevisionError => e
    msg = e.message
    STDOUT.puts msg.to_json
    exit 1
  end

  def get_status(on_off = 'on'.freeze)
    get("/status/#{on_off}")
  end

  def clear
    get("/clear")
  end

  private

  def get_caching(on_off = 'on'.freeze)
    get("/caching/#{on_off}")
  end

  def get_non_caching(on_off = 'on'.freeze)
    get("/non_caching/#{on_off}")
  end

  def assert_responses(caching, non_caching)
    assert_equal(caching[:code], 200, "Caching response failed: #{caching}")
    assert_equal(caching[:body], expected, "Caching response format failed: \n+ #{caching[:body]}\n- #{expected}")
    assert_equal(caching[:content_type], 'application/json; charset=utf-8', "Caching response content type  failed: \n+ #{caching[:content_type]}\n- application/json")
    assert_equal(non_caching[:code], 200, "Non caching response failed: #{non_caching}")
    assert_equal(non_caching[:body], expected, "Non Caching response format failed: \n+ #{non_caching[:body]}\n- #{expected}")
    assert_equal(non_caching[:content_type], 'application/json; charset=utf-8', "Non caching response content type  failed: \n+ #{non_caching[:content_type]}\n- application/json")
  end

  def get(url)
    response = request(:get, url)
    { code: response.status, body: JSON.load(response.body), content_type: response.content_type }
  end

  def expected
    @expected ||=
      {
        "post" =>  {
          "id" =>  1,
          "title" =>  "New Post",
          "body" =>  "Body",
          "comments" => [
            {
              "id" =>  1,
              "body" =>  "ZOMG A COMMENT"
            }
          ],
          "blog" =>  {
            "id" =>  999,
            "name" =>  "Custom blog"
          },
          "author" =>  {
            "id" =>  1,
            "name" =>  "Joao Moura."
          }
        }
    }
  end

  def assert_equal(expected, actual, message)
    return true if expected == actual
    fail BadRevisionError, message
  end

  def debug(msg = '')
    if block_given? && ENV['DEBUG'] =~ /\Atrue|on|0\z/i
      STDOUT.puts yield
    else
      STDOUT.puts msg
    end
  end
end
assertion = ApiAssertion.new
assertion.valid?

STDERR.puts assertion.get_status
Benchmark.ams("caching on: caching serializers") do
  request(:get, "/caching/on")
end
STDERR.puts assertion.get_status
assertion.clear
Benchmark.ams("caching off: caching serializers") do
  request(:get, "/caching/off")
end
STDERR.puts assertion.get_status
assertion.clear
Benchmark.ams("caching on: non-caching serializers") do
  request(:get, "/caching/on")
end
STDERR.puts assertion.get_status
assertion.clear
Benchmark.ams("caching off: non-caching serializers") do
  request(:get, "/caching/off")
end
STDERR.puts assertion.get_status
