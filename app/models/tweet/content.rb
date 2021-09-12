# frozen_string_literal: true

class Tweet
  class Content
    class << self
      def render(**arg)
        ApplicationController.render(render_argument(arg))
      end

      def template_path(method = "test")
        "tweets/#{method}"
      end

      private

      def render_argument(arg = {})
        {
          template: template_path,
        }.merge(arg)
      end
    end

    def render(file_name:, assigns: {})
      ApplicationController.render(
        template: template_path(file_name),
        assigns: assigns,
      )
    end

    private

    def template_path(file_name)
      "tweets/#{file_name}"
    end
  end
end
