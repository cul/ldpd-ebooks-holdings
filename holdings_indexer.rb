require_relative 'holdings_api'
require 'csv'
require 'sqlite3'

class HoldingsIndexer
	def self.update(db_path, csv_path = nil)
		db = SQLite3::Database.new db_path
		schema_path = File.expand_path("../config/schema.sql", __FILE__)
		db.execute File.read(schema_path)
		if csv_path
			CSV.open(csv_path, "r", headers: true) do |csv|
				csv.each do |row|
					db.execute <<-SQL
					INSERT OR REPLACE INTO ebook_links(bib_id,provider,url) VALUES('#{row['bib_id']}','#{row['provider']}','#{row['url']}');
					SQL
				end
			end
		end
		LibCDB::CDB.open(HoldingsApi.settings.datastore_path, 'w') do | cdb |
			bib_doc = nil
			db.execute( "SELECT bib_id, provider, url FROM ebook_links ORDER BY bib_id" ) do |row|
				bib_doc = {id: row[0], holdings: {}} if bib_doc.nil?
				if bib_doc[:id] != row[0]
					cdb[bib_doc[:id]] = JSON.generate(bib_doc[:holdings])
					bib_doc = {id: row[0], holdings: {}}
				end
				bib_doc[:holdings][row[1]] = [row[2]]
			end
			if bib_doc
				cdb[bib_doc.delete(:id)] = JSON.generate(bib_doc[:holdings])
			end
		end
	end
end