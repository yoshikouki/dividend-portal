namespace :company do
  desc "Update to the latest data"
  task :update_to_latest do
    Company.update_all_to_latest
  end
end
