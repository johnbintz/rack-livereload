require 'mocha/api'
require 'webmock/rspec'
require 'rspec/its'

require 'rack-livereload'

RSpec.configure do |c|
  c.expect_with :rspec do |config|
    config.syntax = :should
  end

  c.mock_with :mocha
end

module RSpec::Matchers
  define :use_vendored do
    match do |subject|
      subject.use_vendored?
    end
  end
end
