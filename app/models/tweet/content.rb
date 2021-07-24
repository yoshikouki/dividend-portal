# frozen_string_literal: true

module Tweet
  class Content
    attr_accessor :content, :header_section, :body_section, :footer_section

    def initialize(header_section: "", body_section: "", footer_section: "")
      @header_section = header_section
      @body_section = body_section
      @footer_section = footer_section
    end

    def content(header_section: nil, body_section: nil, footer_section: nil)
      @content = ""
      @content += header_section || @header_section
      @content += body_section || @body_section
      @content += footer_section || @footer_section
      @content
    end

    def content=(content)
      @body_section = content
    end
  end
end
