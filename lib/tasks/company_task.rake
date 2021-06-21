# frozen_string_literal: true

namespace :company do
  desc "Update to the latest data"
  task :update_to_latest do
    puts "Start"

    current_all = Company.all.to_a
    latest_all = Client::Fmp.get_symbols_list
    new_coming = []
    needs_updating = []

    latest_all.each do |raw|
      latest = {
        symbol: raw["symbol"],
        name: raw["name"],
        exchange: raw["exchange"],
      }
      target = current_all.find_index { |cc| cc.symbol == latest[:symbol] }

      # 未知の企業ならインサートする
      if target.nil?
        new_coming << {
          **latest,
          created_at: Time.current,
          updated_at: Time.current,
        }
        next
      end

      current = current_all.slice!(target)
      # 情報を比較して差異があれば更新
      next unless current.diff?(latest, %i[name exchange])

      needs_updating << {
        **current.attributes.symbolize_keys,
        **latest,
      }
    end

    Company.insert_all!(new_coming) if new_coming.count.positive?
    Company.upsert_all(needs_updating) if needs_updating.count.positive?

    puts "Done"
    puts "inserted: #{new_coming.count} \nupdated: #{needs_updating.count}"
  end
end
