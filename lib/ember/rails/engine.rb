require 'ember/handlebars/template'
require 'active_model_serializers'
require 'es6_module_transpiler/rails'
require 'sprockets/railtie'

module Ember
  module Rails
    class Engine < ::Rails::Engine
      config.handlebars = ActiveSupport::OrderedOptions.new

      config.handlebars.precompile = true
      config.handlebars.templates_root = "templates"
      config.handlebars.templates_path_separator = '/'
      config.handlebars.output_type = :global

      config.before_initialize do |app|
        Sprockets::Engines #force autoloading
        Sprockets.register_engine '.handlebars', Ember::Handlebars::Template
        Sprockets.register_engine '.hbs', Ember::Handlebars::Template
        Sprockets.register_engine '.hjs', Ember::Handlebars::Template
      end

      config.es6 = ActiveSupport::OrderedOptions.new

      config.es6.module_prefix = 'my-app'
      config.es6.module_dir = %w(
        models controllers views routes components helpers mixins serializers adapters
        initializers
        router store
      )

      config.after_initialize do |app|
        if config.es6.module_prefix
          Array(config.es6.module_dir).each do |dir|
            path_pattern = Regexp.new("^#{app.root.join('app', 'assets', 'javascripts', dir)}")

            ES6ModuleTranspiler.add_prefix_pattern path_pattern, config.es6.module_prefix
          end
        end
      end
    end
  end
end
