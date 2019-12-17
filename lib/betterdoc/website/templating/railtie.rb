# Make sure that all our classes are required
Dir["#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))}/**/*.rb"].each { |f| require(f) }

module Betterdoc
  module Website
    module Templating
      class Railtie < Rails::Railtie

        initializer 'betterdoc.website.templating.initialization' do
          ActiveSupport.on_load(:action_controller) do
            class ActionController::Base
              include Betterdoc::Website::Templating::Controllers::Concerns::AuthenticationConcern
            end
          end
        end

      end
    end
  end
end
