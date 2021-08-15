# frozen_string_literal: true

module Tweet
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

    private

    def template_path(method)
      self.class.template_path(method)
    end
  end
end
