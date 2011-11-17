require 'sinatra'
$: << 'lib'

require 'rack/livereload'

use Rack::Logger
use Rack::LiveReload

get '/' do
  File.read('index.html')
end

run Sinatra::Application

