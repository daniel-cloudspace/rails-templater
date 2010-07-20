module Rails
  module Generators
    module Actions
      
      attr_accessor :template_generators
      
      def initialize_templater
        @template_generators = []
      end
      
      def add_template_generator(name)
        @template_generators ||= []
        @template_generators << name
      end

      def recipe(name)
        File.join File.dirname(__FILE__), 'recipes', "#{name}.rb"
      end
      
      def load_template(file, parent)
        path = File.expand_path file, template_path(parent)
        File.read path
      end      
      
      def template_path(name)
         File.join(File.dirname(__FILE__), 'templates', name)
      end
      
    end
  end
end