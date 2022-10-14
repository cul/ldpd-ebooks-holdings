require "./config/environment"
require "fileutils"
FileUtils.mkdir_p './db'
run Rack::URLMap.new("/" => HoldingsApi)