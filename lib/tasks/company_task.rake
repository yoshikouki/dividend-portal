# frozen_string_literal: true

namespace :company do
  desc "Update to the latest data"
  task update_to_latest: :environment do
    Company.update_all_with_api
  end
end
