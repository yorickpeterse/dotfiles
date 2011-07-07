DB = Sequel.connect(
  # The adapter to use. When using MySQL it's best to use the mysql2 gem as it's a lot
  # faster than the mysql gem.
  :adapter  => 'mysql2',

  # The hostname where the database is located
  :host     => 'localhost',

  # The username to use for connecting to the database
  :username => '',

  # The password to use for connecting to the database
  :password => '',

  # The name of the database to use
  :database => '',

  # Whether or not the connection should be verified
  :test     => true,

  # The encoding type
  :encoding => 'utf8',

  # The logger used for logging queries and such
  :logger   => Ramaze::Logger::RotatingInformer.new(
    __DIR__("../log/database/dev"), '%d-%m-%Y.log'
  )
)

# IMPORTANT, when running MySQL the engine should be set to InnoDB in order for the 
# foreign keys to work properly
if DB.database.adapter_scheme.to_s.include?('mysql')
  Sequel::MySQL.default_engine = 'InnoDB'
end
