require 'net/http'
require_relative '../errors/template_not_found_error'
require_relative '../errors/template_loading_error'

module Betterdoc
  module Website
    module Templating
      module Loaders
        class NetworkTemplateLoader

          attr_accessor :http_auth_username
          attr_accessor :http_auth_password

          def initialize(url)
            @url = url
          end

          def load_template

            http_headers = {}
            http_headers['Authorization'] = "Basic #{strict_encode64("#{@http_auth_username}:#{@http_auth_password}")}" if @http_auth_username&.length&.positive?

            http_response = HTTParty.get(@url, headers: http_headers)
            raise Betterdoc::Website::Templating::Errors::TemplateNotFoundError, "Cannot find template at URL: #{@url}" if http_response.code == 404
            raise Betterdoc::Website::Templating::Errors::TemplateLoadingError, "Cannot load template from URL '#{@url}' (HTTP error #{http_response.code})" unless http_response.code == 200

            http_response.body
          end

        end
      end
    end
  end
end
