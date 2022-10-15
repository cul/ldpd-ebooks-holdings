require 'libcdb'
require 'json'
require 'sinatra'

class HoldingsApi < Sinatra::Base
	configure do
		db_dir = File.expand_path("../db", __FILE__)
		FileUtils.mkdir_p(db_dir)
		set :datastore_path, File.join(db_dir, "#{ENV['RACK_ENV'] || 'development'}.cdb")
	end

	def datastore
		@datastore ||= LibCDB::CDB.open(settings.datastore_path)
	end

	def success_headers
		@headers ||= {
			'Access-Control-Allow-Methods' => 'GET, OPTIONS',
			'Access-Control-Allow-Origin' => '*',
			'Content-Type' => 'application/json'
		}.freeze
	end

	get '/' do
		404
	end

	get '/holdings' do
		400
	end

	get '/holdings/:bib_id.json' do
		holdings = {}
		datastore[params[:bib_id]]&.tap { |data| holdings.merge!(JSON.load(data)) }
		# CLIO API expects a simplye key
		holdings['simplye'] ||= [] unless holdings.empty?
		[200, success_headers, JSON.generate({ id: params[:bib_id], holdings: holdings })]
	end
end
