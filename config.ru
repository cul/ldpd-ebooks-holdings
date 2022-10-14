require "./config/environment"
require "fileutils"
require_relative "holdings_api"
FileUtils.mkdir_p './db'
run Rack::URLMap.new("/" => HoldingsApi)