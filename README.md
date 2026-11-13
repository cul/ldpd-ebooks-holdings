# ldpd-ebooks-holdings

Sinatra app experiment for an ebook holdings API

1. Install tinycdb library (`brew install tinycdb`)
2. bundle install
3. bundle exec rake db:update DB_PATH=db/development.sqlite3 CSV_PATH=spec/fixtures/test.csv
4. rackup
5. visit http://localhost:9292/holdings/12345.json
