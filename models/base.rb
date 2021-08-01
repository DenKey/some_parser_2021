require 'active_record'
require "activerecord-import/base"

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "./some_parser.db"
)

ActiveRecord::Import.require_adapter('sqlite3')
