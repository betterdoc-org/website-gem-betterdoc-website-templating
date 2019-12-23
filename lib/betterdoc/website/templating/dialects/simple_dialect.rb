require 'betterdoc/website/templating/errors/configuration_error'

module Betterdoc
  module Website
    module Templating
      module Dialects

        class SimpleDialect

          attr_accessor :content_placeholder
          attr_accessor :title_placeholder

          def resolve_content(template, context = {})
            raise Betterdoc::Website::Templating::Errors::ConfigurationError, "No content present" if context[:content].nil? || context[:content].length <= 0

            content_placeholder = @content_placeholder || ENV['TEMPLATING_CONTENT_PLACEHOLDER'] || 'INCLUDE_CONTENT_HERE'
            title_placeholder = @title_placeholder || ENV['TEMPLATING_TITLE_PLACEHOLDER'] || 'INCLUDE_TITLE_HERE'

            resolved_content = replace_in_template_by_placeholder(template, content_placeholder, context[:content])
            resolved_content = replace_in_template_by_placeholder(resolved_content, title_placeholder, context[:title] || ENV['TEMPLATING_TITLE'] || "BetterDoc")
            resolved_content = replace_in_template_by_insert_before(resolved_content, '</head>', context[:additional_head_content])
            resolved_content = replace_in_template_by_insert_before(resolved_content, '</body>', context[:additional_body_content])
            resolved_content
          end

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

        end

      end
    end
  end
end
