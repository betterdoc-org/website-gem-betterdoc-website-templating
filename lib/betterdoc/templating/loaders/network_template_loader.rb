require 'net/http'
require_relative '../errors/template_not_found_error'
require_relative '../errors/template_loading_error'

module Betterdoc
  module Templating
    module Loaders
      class NetworkTemplateLoader

        def initialize(url)
          @url = url
        end

        def load_template
          response = Net::HTTP.get_response(URI(@url))
          raise Betterdoc::Templating::Errors::TemplateNotFoundError, "Cannot find template at URL: #{@url}" if response.code.to_i == 404
          raise Betterdoc::Templating::Errors::TemplateLoadingError, "Cannot load template from URL '#{@url}' (HTTP error #{response.code})" unless response.code.to_i == 200

          response.body
        end

      end
    end
  end
end
