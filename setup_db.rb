require 'sqlite3'

begin
  db = SQLite3::Database.new "some_parser.db"

  # Each `execute` call runs only one SQL construction, maybe the better way
  # is to create a dump file and loads it.
  db.execute <<-SQL
    create table products (
      id integer primary key, 
      product_code varchar(50) unique,
      product_name varchar(256),
      description text,
      status boolean,
      price float,
      inventory integer,
      available_time datetime
    );
  SQL

  db.execute <<-SQL
    create table categories (
      id integer primary key, 
      category_code varchar(256) unique,
      parent_category_code varchar(256),
      description text
    );
  SQL

  db.execute <<-SQL
    create table product_categories (
      id integer primary key, 
      product_id integer,
      category_id integer,
      foreign key (product_id) 
            references products (id) 
               on delete cascade 
               on update no action,
         foreign key (category_id) 
            references categories (id) 
               on delete cascade 
               on update no action
    );
  SQL

  db.execute <<-SQL
    create table images (
      id integer primary key, 
      image_name varchar(256) unique,
      image_url text,
      description text
    );
  SQL

  db.execute <<-SQL
    create table product_images (
      id integer primary key, 
      product_id integer,
      image_id integer,
      foreign key (product_id) 
            references products (id) 
               on delete cascade 
               on update no action,
      foreign key (image_id) 
            references images (id) 
               on delete cascade 
               on update no action
    );
  SQL

  db.execute <<-SQL
    create table category_images (
      id integer primary key, 
      category_id integer,
      image_id integer,
      foreign key (category_id) 
            references categories (id) 
               on delete cascade 
               on update no action,
      foreign key (image_id) 
            references images (id) 
               on delete cascade 
               on update no action
    );
  SQL
rescue SQLite3::Exception => e
  puts "Something went wrong"
  puts e
ensure
  db.close if db
end