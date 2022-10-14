# ldpd-ebooks-holdings

Sinatra app experiment for an ebook holdings API

1. bundle install 
2. bundle exec rake db:update DB_PATH=db/development.sqlite3 CSV_PATH=spec/fixtures/test.csv
3. rackup
4. visit http://localhost:9292/holdings/12345.json
