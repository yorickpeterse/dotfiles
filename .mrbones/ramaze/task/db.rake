Sequel.extension(:migration)

namespace :db do
  desc 'Migrates the database to the most recent or the specified version'
  task :migrate, :version do |task, args|
    if !args[:version]
      version = nil
    else
      version = args[:version].to_i
    end

    Sequel::Migrator.run(DB, __DIR__('../migrations'), :target => version)
  end

  desc 'Generates a new migration'
  task :migration, :name do |task, args|
    if !args[:name]
      abort 'You need to specify a name for the migration'
    end

    # Generate the name of the migration
    path = File.join(
      __DIR__('../migrations'),
      "#{Time.new.to_i}_#{args[:name]}.rb"
    )

    if File.exist?(path)
      abort "The migration #{path} already exists"
    end

    template = <<-TEMPLATE
Sequel.migration do

  up do

  end

  down do

  end

end
TEMPLATE

    # Write the migration
    File.open(path, 'w') do |handle|
      begin
        handle.write(template.strip)
        puts "Saved the migration in #{path}"
      rescue => e
        abort "Failed to write the migration: #{e.message}"
      end
    end
  end
end # namespace :db
