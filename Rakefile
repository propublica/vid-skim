require 'spec/rake/spectask'
require 'selenium/rake/tasks'


spec_opts = ['--colour', '--format progress', '--loadby mtime', '--reverse']

desc "Run all specs except selenium"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir['spec/*_spec.rb']
  t.spec_opts = spec_opts
end


Selenium::Rake::RemoteControlStartTask.new do |rc|
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
  rc.background = true
  rc.wait_until_up_and_running = true
  rc.jar_file = "spec/selenium-server.jar"
  rc.additional_args << "-singleWindow > /dev/null"
end

Selenium::Rake::RemoteControlStopTask.new do |rc|
  rc.host = "localhost"
  rc.port = 4444
  rc.timeout_in_seconds = 3 * 60
  rc.wait_until_stopped = true
end

namespace :selenium do
  task :spec do
    begin
      `thin start -R #{Dir.pwd}/spec/selenium_test_server.ru -d -c .`
      Rake::Task[:"selenium:rc:start"].execute []
      Rake::Task[:"selenium:ui"].execute []
    ensure
      Rake::Task[:"selenium:rc:stop"].execute []
      `thin stop -R #{Dir.pwd}/spec/selenium_test_server.ru -c .`
    end
  end
 
  desc "Run ui specs"
  Spec::Rake::SpecTask.new(:ui) do |t|
    t.spec_files = Dir['spec/*_spec_selenium.rb']
    t.spec_opts = spec_opts
  end
end



namespace :gem do
  
  desc 'Build and install vid-skim gem'
  task :install do
    sh "gem build vid-skim.gemspec"
    sh "sudo gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end
  
  desc 'Uninstall the vid-skim gem'
  task :uninstall do
    sh "sudo gem uninstall -x vid-skim"
  end
  
end

task :default => :spec