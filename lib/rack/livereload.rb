module Rack
  class LiveReload
    LIVERELOAD_JS_PATH = '/__rack/livereload.js'

    attr_reader :app

    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      if env['PATH_INFO'] == LIVERELOAD_JS_PATH
        deliver_file(::File.expand_path('../../../js/livereload.js', __FILE__))
      else
        status, headers, body = @app.call(env)

        case headers['Content-Type']
        when %r{text/html}
          content_length = 0

          body.each do |line|
            if !headers['X-Rack-LiveReload'] && line['</head>']
              src = LIVERELOAD_JS_PATH.dup
              if @options[:host]
                src << "?host=#{@options[:host]}"
              else
                src << "?host=#{env['HTTP_HOST'].gsub(%r{:.*}, '')}" if env['HTTP_HOST']
              end
              src << "&mindelay=#{@options[:min_delay]}" if @options[:min_delay]
              src << "&maxdelay=#{@options[:max_delay]}" if @options[:max_delay]
              src << "&port=#{@options[:port]}" if @options[:port]

              line.gsub!('</head>', %{<script type="text/javascript" src="#{src}"></script></head>})

              headers["X-Rack-LiveReload"] = '1'
            end

            content_length += line.length
          end

          headers['Content-Length'] = content_length.to_s
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

