require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EmlProcessor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    config.active_job.queue_adapter = :sidekiq
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators do |g|
      # Não gerar arquivos de assets (CSS/JS) para controllers
      g.assets false

      # Não gerar arquivos de helper
      g.helper false

      # Configurações do RSpec
      g.test_framework :rspec,
        view_specs: false,         # <--- Impede a geração de spec/views
        helper_specs: false,       # Impede a geração de spec/helpers
        routing_specs: false,      # Opcional: Desativa specs para routes
        controller_specs: true,   # Opcional: Se você usa apenas Request Specs
        request_specs: false        # Mantém a geração de spec/requests (Controllers como integração)
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
