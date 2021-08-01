# frozen_string_literal: true

namespace :company do
  desc "Update to the latest data"
  task update_to_latest: :environment do
    Company.update_to_least
  end
end
