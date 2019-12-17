require_relative 'errors/configuration_error'
require_relative 'errors/template_not_found_error'
require_relative 'loaders/local_template_loader'
require_relative 'loaders/network_template_loader'

module Betterdoc
  module Website
    module Templating
      class Engine

        attr_accessor :template_location
        attr_accessor :template_auth_username
        attr_accessor :template_auth_password
        attr_accessor :content
        attr_accessor :content_placeholder
        attr_accessor :title
        attr_accessor :title_placeholder
        attr_accessor :additional_head_content
        attr_accessor :additional_body_content

        # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
        def resolve_content
          template_location = @template_location || ENV['TEMPLATING_TEMPLATE_LOCATION']
          content_placeholder = @content_placeholder || ENV['TEMPLATING_CONTENT_PLACEHOLDER'] || 'INCLUDE_CONTENT_HERE'
          title_placeholder = @title_placeholder || ENV['TEMPLATING_TITLE_PLACEHOLDER'] || 'INCLUDE_TITLE_HERE'

          raise Betterdoc::Website::Templating::Errors::ConfigurationError, "No template_location specified and no default value found via environment variable" if template_location.nil? || template_location.length <= 0
          raise Betterdoc::Website::Templating::Errors::ConfigurationError, "No content present" if @content.nil? || @content.length <= 0

          template_loader = compute_template_loader(template_location)
          template_content = template_loader.load_template

          resolved_content = replace_in_template_by_placeholder(template_content, content_placeholder, @content)
          resolved_content = replace_in_template_by_placeholder(resolved_content, title_placeholder, @title || ENV['TEMPLATING_TITLE'] || "BetterDoc")
          resolved_content = replace_in_template_by_insert_before(resolved_content, '</head>', @additional_head_content)
          resolved_content = replace_in_template_by_insert_before(resolved_content, '</body>', @additional_body_content)
          resolved_content
        end
        # rubocop:enable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity

        private

        def replace_in_template_by_placeholder(template, placeholder, value)
          if value
            template.gsub(placeholder, value)
          else
            template
          end
        end

        def replace_in_template_by_insert_before(template, needle, value)
          if value
            index_of_needle = template.index(needle)
            if index_of_needle&.positive?
              "#{template[0, index_of_needle]}\n#{value}\n#{template[index_of_needle..-1]}"
            else
              template
            end
          else
            template
          end
        end

        def compute_template_loader(location)
          if location.start_with?('http') || location.start_with?('https')
            template_loader = Betterdoc::Website::Templating::Loaders::NetworkTemplateLoader.new(location)
            template_loader.http_auth_username = @template_auth_username || ENV['TEMPLATING_AUTH_USERNAME']
            template_loader.http_auth_password = @template_auth_password || ENV['TEMPLATING_AUTH_PASSWORD']
            template_loader
          else
            Betterdoc::Website::Templating::Loaders::LocalTemplateLoader.new(location)
          end
        end

      end
    end
  end
end
