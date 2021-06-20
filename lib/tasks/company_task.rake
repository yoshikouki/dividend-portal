namespace :company do
  desc "Update to the latest data"
  task :update_to_latest do
    puts "Start"
    result = Company.update_all_to_latest
    puts "Done"
    puts "inserted: #{result.inserted.count} \nupdated: #{result.updated.count}"
  end
end
