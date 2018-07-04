namespace :storey do

  namespace :hstore do
    desc "Install hstore into the hstore#{Storey.configuration.suffix} schema"
    task :install => :environment do
      Storey::Hstore.install
    end
  end

  desc "Migrate all schemas including public"
  task migrate: :environment do
    options = {}
    options[:version] = ENV['VERSION']
    Storey::Migrator.migrate_all options
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all schemas."
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    Storey::Migrator.rollback_all(step)
  end

  namespace :migrate do

    desc 'Runs the "up" for a given migration VERSION across all schemas.'
    task :up => 'db:migrate:up' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Storey.schemas.each do |schema|
        puts "Migrating #{schema} schema up"
        Storey::Migrator.run :up, schema, version
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all schemas.'
    task :down => 'db:migrate:down' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Storey.schemas.each do |schema|
        puts "Migrating #{schema} schema down"
        Storey::Migrator.run :down, schema, version
      end
    end

    desc 'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => 'db:migrate:redo' do
      if ENV['VERSION']
        apartment_namespace['migrate:down'].invoke
        apartment_namespace['migrate:up'].invoke
      else
        apartment_namespace['rollback'].invoke
        apartment_namespace['migrate'].invoke
      end
    end

  end

end
