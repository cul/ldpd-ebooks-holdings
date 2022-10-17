require 'sqlite3'
require 'json'
require 'sinatra'

class HoldingsApi < Sinatra::Base
	configure do
		db_dir = File.expand_path("../db", __FILE__)
		FileUtils.mkdir_p(db_dir)
		set :datastore_path, File.join(db_dir, "#{ENV['RACK_ENV'] || 'development'}.sqlite3")
	end

	def tinycdb_datastore
		LibCDB::CDB.open(settings.datastore_path)
	end

	def sqlite_datastore
		SQLiteDatastore.new settings.datastore_path
	end

	def datastore
		@datastore ||= sqlite_datastore
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
	class SQLiteDatastore
		attr_reader :db
		def initialize(db_path)
			@db = SQLite3::Database.new db_path
		end

		def [](bib_id)
			bib_doc = nil
			db.execute( "SELECT bib_id, provider, url FROM ebook_links WHERE bib_id = (?)", [bib_id]) do |row|
				bib_doc ||= {id: row[0], holdings: {}}
				bib_doc[:holdings][row[1]] = [row[2]]
			end
			JSON.generate(bib_doc[:holdings]) if bib_doc
		end
	end
end
