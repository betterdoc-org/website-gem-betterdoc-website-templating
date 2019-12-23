require 'mustache'

module Betterdoc
  module Website
    module Templating
      module Dialects
        class MustacheDialect

          def resolve_content(template, context = {})
            Mustache.render(template, context)
          end

        end
      end
    end
  end
end
