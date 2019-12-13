require_relative '../errors/template_not_found_error'
require_relative '../errors/template_loading_error'

module Betterdoc
  module Templating
    module Loaders
      class LocalTemplateLoader

        def initialize(file)
          @file = file
        end

        def load_template
          raise Betterdoc::Templating::Errors::TemplateNotFoundError, "Cannot find template file at at: #{@file}" unless File.exist?(@file)

          File.read(@file)
        end

      end
    end
  end
end
