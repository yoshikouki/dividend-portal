# frozen_string_literal: true

namespace :refresh do
  desc "APIから情報を取得して日次の更新を行う"
  task daily: :environment do
    Refresh.daily
  end
end
