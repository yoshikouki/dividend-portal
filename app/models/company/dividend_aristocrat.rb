# frozen_string_literal: true

class Company
  module DividendAristocrat
    def self.setup
      dividend_aristocrat_tag = Tag.find_or_create_by(name: :dividend_aristocrats, display_name: "配当貴族")
      Company::DividendAristocrat::Constant::ATTRIBUTES.each do |attr|
        company = Company.find_by(symbol: attr[:symbol])
        if company
          company.company_tags.create(tag: dividend_aristocrat_tag)
        else
          dividend_aristocrat_tag.companies.create(attr)
        end
      end
    end
  end
end
