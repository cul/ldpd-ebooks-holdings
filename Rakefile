require_relative 'holdings_indexer'

namespace :db do
	desc "Add CSV data to db"
	task :update do
		db_path = ENV['DB_PATH'] || "db/#{ENV['RACK_ENV'] || :development}.sqlite3"
		csv_path = ENV['CSV_PATH']
		HoldingsIndexer.update(db_path, csv_path)
	end
end