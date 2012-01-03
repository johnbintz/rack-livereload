Then /^I should not have any Rack::LiveReload code$/ do
  @response.body.should_not include("rack/livereload.js")
end

