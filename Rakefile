desc "Run all specs"
task :spec do
  sh "spec #{Dir['spec/models/*.rb'].join(' ')}"
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