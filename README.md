Hey, you've got [LiveReload](http://www.livereload.com/) in my [Rack](http://rack.rubyforge.org/)!
No need for browser extensions anymore! Just plug it in your middleware stack and go!

Use this with [guard-livereload](http://github.com/guard/guard-livereload) for maximum fun!

## Install

`gem install rack-livereload`

## Using in...

### Rails

In `config/environments/development.rb`:

``` ruby
MyApp::Application.configure do
  config.middleware.insert_before(Rack::Lock, Rack::LiveReload)

  # ...or, change some options...

  config.middleware.insert_before(
    Rack::Lock, Rack::LiveReload,
    :min_delay => 500,
    :max_delay => 10000,
    :port => 56789,
    :host => 'myhost.cool.wow'
  )
end
```

### config.ru/Sinatra

``` ruby
require 'rack-livereload'

use Rack::LiveReload
# ...or...
use Rack::LiveReload, :min_delay => 500, ...
```

## How it works

The necessary `script` tag to bring in a vendored copy of [livereload.js](https://github.com/livereload/livereload-js) is
injected right before the closing `head` tag in any `text/html` pages that come through. The `script` tag is built in
such a way that the `HTTP_HOST` is used as the LiveReload host, so you can connect from external machines (say, to
`mycomputer:3000` instead of `localhost:3000`) and as long as the LiveReload port is accessible from the external machine,
you'll connect and be LiveReloading away!

As usual, super-alpha!

