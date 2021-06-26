# frozen_string_literal: true

class DividendController < ApplicationController
  def index
  end

  def recent
    @dividends = Dividend.recent
  end

  def today
    @dividends = Dividend.declared_on_today
  end
end
