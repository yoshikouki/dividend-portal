# frozen_string_literal: true

module Tweet
  class Content
    attr_accessor :header_section, :main_section, :footer_section

    def initialize(header: nil, main: nil, footer: nil)
      @header_section = header
      @main_section = main
      @footer_section = footer
    end

    def content(header: nil, main: nil, footer: nil)
      header ||= @header_section
      main ||= @main_section
      footer ||= @footer_section

      @content = ""
      @content += "#{header}\n" if header
      @content += main if main
      @content += "\n#{footer}" if footer
      @content
    end
    alias render content

    def content=(content)
      @main_section = content
    end
  end
end
