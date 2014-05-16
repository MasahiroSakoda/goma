begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Goma'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end




Bundler::GemHelper.install_tasks

require 'rake/testtask'
require 'single_test/tasks'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Rebuild test app's resources"
task "rebuild_test_app" do
  migration = 'migrate' == ARGV.last ? '' : ' --no-migration'
  cd "test/rails_app"
  sh "bundle exec rails d goma:scaffold User#{migration}"
  sh "bundle exec rails g goma:scaffold User#{migration}"
  if migration.empty?
    sh "RAILS_ENV=test bundle exec rake db:drop"
    sh "RAILS_ENV=test bundle exec rake db:create"
    sh "RAILS_ENV=test bundle exec rake db:migrate"
  end
  sh "rm -rf test/*"
  cd "../.."
end

task default: :test
