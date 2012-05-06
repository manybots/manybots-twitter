require 'rails/generators'
require 'rails/generators/base'


module ManybotsTwitter
  module Generators
    class InstallGenerator < Rails::Generators::Base
      
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true

      desc 'Mounts Manybots Twitter at "/manybots-twitter"'
      def add_manybots_gardener_routes
        route 'mount ManybotsTwitter::Engine => "/manybots-twitter"' if options.routes?
      end
      
      desc "Creates a ManybotsTwitter initializer"
      def copy_initializer
        template "manybots-twitter.rb", "config/initializers/manybots-twitter.rb"
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end
      
    end
  end
end
