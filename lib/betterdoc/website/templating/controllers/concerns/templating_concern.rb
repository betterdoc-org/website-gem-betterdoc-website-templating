module Betterdoc
  module Website
    module Templating
      module Controllers
        module Concerns
          module AuthenticationConcern
            extend ActiveSupport::Concern

            def render_in_website_template(view, options = {})
              view_options_default = { layout: false }
              view_options = view_options_default.merge(options)
              view_content = render_to_string(view, view_options)

              template_engine = create_website_template_engine
              template_engine.content = view_content
              template_content = template_engine.resolve_content

              render options.merge(body: template_content, layout: false, content_type: 'text/html')
            end

            def create_website_template_engine
              Betterdoc::Website::Templating::Engine.new
            end

          end
        end
      end
    end
  end
end
