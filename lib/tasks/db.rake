namespace :db do
  namespace :test do
    desc "Prepare the test database by copying the migrated development database"
    task setup: :environment do
      dev_db  = Rails.root.join("db/movies.db")
      test_db = Rails.root.join("db/movies-test.db")

      unless File.exist?(dev_db)
        abort "movies.db not found. Download it from Google Drive and place it in db/, then run rails db:migrate."
      end

      FileUtils.cp(dev_db, test_db)
      puts "Test database prepared: copied #{dev_db.basename} → #{test_db.basename}"
    end
  end
end
