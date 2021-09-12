# frozen_string_literal: true

Dir[Rails.root.join("db", "seeds", "*.rb")].each { |f| require f }

Company::DividendAristocrat.setup
