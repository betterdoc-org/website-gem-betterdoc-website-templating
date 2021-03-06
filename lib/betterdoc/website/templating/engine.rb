require 'betterdoc/website/templating/dialects/mustache_dialect'
require 'betterdoc/website/templating/dialects/simple_dialect'
require 'betterdoc/website/templating/errors/configuration_error'
require 'betterdoc/website/templating/errors/template_not_found_error'
require 'betterdoc/website/templating/loaders/local_template_loader'
require 'betterdoc/website/templating/loaders/network_template_loader'

module Betterdoc
  module Website
    module Templating
      class Engine

        attr_accessor :template_location
        attr_accessor :template_auth_username
        attr_accessor :template_auth_password
        attr_accessor :template_dialect

        def resolve_content(context = {})
          template_location = @template_location || ENV['TEMPLATING_TEMPLATE_LOCATION']
          raise Betterdoc::Website::Templating::Errors::ConfigurationError, "No template_location specified and no default value found via environment variable" if template_location.nil? || template_location.length <= 0

          template_content = resolve_template(template_location)
          template_context = resolve_template_context(context)
          template_dialect = resolve_template_dialect(template_location)
          template_dialect.resolve_content(template_content, template_context)
        end

        private

        def resolve_template(template_location)
          resolve_template_loader(template_location).load_template
        end

        def resolve_template_loader(template_location)
          if template_location.start_with?('http') || template_location.start_with?('https')
            template_loader = Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader.new(template_location)
            template_loader.http_auth_username = @template_auth_username || ENV['TEMPLATING_AUTH_USERNAME']
            template_loader.http_auth_password = @template_auth_password || ENV['TEMPLATING_AUTH_PASSWORD']
            template_loader
          else
            Betterdoc::Website::Templating::Loaders::LocalTemplateLoader.new(template_location)
          end
        end

        def resolve_template_context(context)
          {}.merge(context)
        end

        def resolve_template_dialect(template_location)
          @template_dialect || resolve_template_dialect_from_template_location(template_location)
        end

        def resolve_template_dialect_from_template_location(template_location)
          return Betterdoc::Website::Templating::Dialects::MustacheDialect.new if template_location.end_with?('.mustache.html')
          return Betterdoc::Website::Templating::Dialects::MustacheDialect.new if template_location.end_with?('.mustache')

          Betterdoc::Website::Templating::Dialects::SimpleDialect.new
        end

      end
    end
  end
end
