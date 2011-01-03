gem 'capybara', '0.3.9', :group => :test
gem 'cucumber-rails', :group => :test
gem 'launchy', :group => :test

stategies <<  lambda do
  generate 'cucumber:install --rspec --capybara --skip-database'

  cukes_factory_girl = <<-END

  require 'factory_girl'
  require 'factory_girl/step_definitions'
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'..','..','spec','factories','*.rb'))].each {|f| require f}

  END

  inject_into_file "features/support/env.rb",
    "\nCapybara.save_and_open_page_path = 'tmp/capybara/'",
    :after => 'Capybara.default_selector = :css'

  inject_into_file "features/support/env.rb", cukes_factory_girl, :after => 'ActionController::Base.allow_rescue = false'

  # Mongoid truncation strategy
  create_file 'features/support/hooks.rb', load_template('features/support/hooks.rb', 'mongoid')

  # Compliment to factory_girl step definitions
  create_file 'features/step_definitions/mongoid_steps.rb', load_template('features/step_definitions/mongoid_steps.rb', 'mongoid')
end
# Delete all unnecessary files
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "public/images/rails.png"

create_file 'README'
create_file 'log/.gitkeep'
create_file 'tmp/.gitkeep'

gsub_file 'config/application.rb', 'require "rails/test_unit/railtie"', '# require "rails/test_unit/railtie"'

get "http://html5shiv.googlecode.com/svn/trunk/html5.js", "public/javascripts/html5.js"

git :init

append_file '.gitignore', load_template('gitignore','git')

gem 'rails3-generators'if template_options[:design] == "compass"
  gem 'compass'

  # TODO: support more than one framework from compass
  compass_sass_dir = "app/stylesheets"
  compass_css_dir = "public/stylesheets/compiled"

  compass_command = "compass init rails . --using blueprint/semantic --css-dir=#{compass_css_dir} --sass-dir=#{compass_sass_dir} "

  stategies << lambda do
    puts "Beginning Compass setup"
    run compass_command
    puts "Compass has been setup"
  end
  
end
gem 'devise'
generate 'devise:install'
generate 'devise user'

gem 'factory_girl_rails', :group => :test

stategies << lambda do
  inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"
endgem 'haml'
gem "haml-rails"

remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', load_template('app/views/layouts/application.html.haml','haml')gem 'jquery-rails'

gsub_file 'config/application.rb', /(config.action_view.javascript_expansions\[:defaults\] = %w\(\))/, '# \1'

stategies << lambda do
  generate 'jquery:install'
endgem 'mongoid', '2.0.0.beta.20'
gem 'bson_ext', '~> 1.1.2'

stategies << lambda do
  generate 'mongoid:config'
  run 'cp config/mongoid.yml config/mongoid.yml.example'
end
gem 'remarkable_activemodel', '>=4.0.0.alpha4', :group => :test
gem 'remarkable_mongoid', :group => :test

stategies << lambda do
  inject_into_file 'spec/spec_helper.rb', "\nrequire 'remarkable/active_model'\nrequire 'remarkable/mongoid'", :after => "require 'rspec/rails'"
end
gem 'rspec-rails', '>= 2.0.1', :group => [:development, :test]

stategies << lambda do
  generate 'rspec:install'
  
  spec_helper_path = 'spec/spec_helper.rb'
    
  gsub_file spec_helper_path, 'config.fixture_path = "#{::Rails.root}/spec/fixtures"', ''
  gsub_file spec_helper_path, /(config.use_transactional_fixtures = true)/, '# \1'
  
  mongoid_rspec_truncation = <<-MONGOID
  
    config.before :each do
      Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    end
    
  MONGOID
    
  inject_into_file spec_helper_path, mongoid_rspec_truncation, :after => "# config.use_transactional_fixtures = true\n"

end
