require 'sinatra'
$: << 'lib'

require 'rack/livereload'

use Rack::LiveReload

get '/' do
  "<html><head><title>Hi</title></head><body>Hi</body></html>"
end

run Sinatra::Application

