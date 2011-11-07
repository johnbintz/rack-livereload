module Rack
  class LiveReload
    LIVERELOAD_JS_PATH = '/__rack/livereload.js'

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == LIVERELOAD_JS_PATH
        deliver_file(::File.expand_path('../../../js/livereload.js', __FILE__))
      else
        status, headers, body = @app.call(env)

        case headers['Content-Type']
        when %r{text/html}
          body.each do |line|
            if line['</head>']
              src = LIVERELOAD_JS_PATH.dup
              src << "?host=#{env['HTTP_HOST'].gsub(%r{:.*}, '')}" if env['HTTP_HOST']

              line.gsub!('</head>', %{<script type="text/javascript" src="#{src}"></script></head>})
              headers["X-Rack-LiveReload"] = '1'

              break
            end
          end

          headers['Content-Length'] = body.join.length.to_s
        end

        [ status, headers, body ]
      end
    end

    private
    def deliver_file(file)
      [ 200, { 'Content-Type' => 'text/javascript', 'Content-Length' => ::File.size(file).to_s }, [ ::File.read(file) ] ]
    end
  end
end

