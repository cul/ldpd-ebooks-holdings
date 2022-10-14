require 'libcdb'

class HoldingsApi < Sinatra::Base
	configure do
		db_dir = File.expand_path("../db", __FILE__)
		FileUtils.mkdir_p(db_dir)
		set :datastore_path, File.join(db_dir, "#{ENV['RACK_ENV'] || 'development'}.cdb")
	end

	def datastore
		@datastore ||= LibCDB::CDB.open(settings.datastore_path)
	end

	get '/holdings/:bib_id.json', provides: 'json' do
		datastore[params[:bib_id]] || JSON.generate({ id: params[:bib_id], holdings: {} })
	end
end
