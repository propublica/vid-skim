# The static content rooted in the current working directory
# Dir.pwd =&gt; http://0.0.0.0:3000/
#
run Rack::Directory.new("template/html")