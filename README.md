# Installation

Run `bundle exec ruby setup_db.rb` in console before start

# Run

## CSV import

Run in bash:
`sidekiq -r ./csv_worker.rb`

In separate terminal window open console
` irb -r ./csv_worker.rb`

Start worker in console
` CsvWorker.perform_async`