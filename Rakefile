require "bundler/gem_tasks"

desc 'Update livereload.js'
task :update_livereload_js do
  require 'httparty'

  File.open('js/livereload.js', 'wb') { |fh|
    fh.print HTTParty.get('https://raw.github.com/livereload/livereload-js/master/dist/livereload.js').body
  }
end

