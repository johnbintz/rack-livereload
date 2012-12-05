<a href="http://travis-ci.org/johnbintz/rack-livereload"><img src="https://secure.travis-ci.org/johnbintz/rack-livereload.png" /></a>

Hey, you've got [LiveReload](http://www.livereload.com/) in my [Rack](http://rack.rubyforge.org/)!
No need for browser extensions anymore! Just plug it in your middleware stack and go!
Even supports browsers without WebSockets!

Use this with [guard-livereload](http://github.com/guard/guard-livereload) for maximum fun!

## Install

`gem install rack-livereload`

## Using in...

### Rails


In `config/environments/development.rb`:

``` ruby
MyApp::Application.configure do
  config.middleware.insert_after(ActionDispatch::Static, Rack::LiveReload)

  # ...or, change some options...

  config.middleware.insert_before(
    Rack::Lock, Rack::LiveReload,
    :min_delay => 500,
    :max_delay => 10000,
    :port => 56789,
    :host => 'myhost.cool.wow',
    :ignore => [ %r{dont/modify\.html$} ]
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

The necessary `script` tag to bring in a copy of [livereload.js](https://github.com/livereload/livereload-js) is
injected right after the opening `head` tag in any `text/html` pages that come through. The `script` tag is built in
such a way that the `HTTP_HOST` is used as the LiveReload host, so you can connect from external machines (say, to
`mycomputer:3000` instead of `localhost:3000`) and as long as the LiveReload port is accessible from the external machine,
you'll connect and be LiveReloading away!

### Which LiveReload script does it use?

* If you've got a LiveReload watcher running on the same machine as the app that responds
  to `http://localhost:35729/livereload.js`, that gets used, with the hostname being changed when
  injected into the HTML page.
* If you don't, the copy vendored with rack-livereload is used.
* You can force the use of either one (and save on the cost of checking to see if that file
  is available) with the middleware option `:source => :vendored` or `:source => :livereload`.

### How about non-WebSocket-enabled browsers?

For browsers that don't support WebSockets, but do support Flash, [web-socket-js](https://github.com/gimite/web-socket-js)
is loaded. By default, this is done transparently, so you'll get a copy of swfobject.js and web_socket.js loaded even if
your browser doesn't need it. The SWF WebSocket implementor won't be loaded unless your browser has no native
WebSockets support or if you force it in the middleware stack:

``` ruby
use Rack::LiveReload, :force_swf => true
```

If you don't want any of the web-sockets-js code included at all, use the `no_swf` option:

``` ruby
use Rack::LiveReload, :no_swf => true
```

Once more browsers support WebSockets than don't, this option will be reversed and you'll have
to explicitly include the Flash shim.

