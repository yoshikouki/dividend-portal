# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show]

  # GET /companies or /companies.json
  def index
    @companies = Company.all
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end
end
