Gem::Specification.new do |s|
  s.name      = 'vid-skim'
  s.version   = '0.0.1'         # Keep version in sync with vid-skim.rb
  s.date      = '2009-09-25'

  s.homepage    = "http://propublica.org"
  s.summary     = "Annotate videos with transcripts and editors' notes"
  s.description = <<-EOS
    to be determined...
  EOS
  
  s.authors           = ['Jeff Larson']
  s.email             = 'jeff.larson@propublica.org'
  s.rubyforge_project = 'vid-skim'
  
  s.require_paths     = ['lib']
  s.executables       = ['vidskim']
    
  s.has_rdoc          = true
  s.extra_rdoc_files  = ['README']
  s.rdoc_options      << '--title'    << 'VidSkim' <<
                         '--exclude'  << 'test' <<
                         '--main'     << 'README' <<
                         '--all'
  
  s.add_dependency 'json',          ['>= 1.1.7']
  s.add_dependency 'nokogiri',      ['>= 1.3.3']

  if s.respond_to?(:add_development_dependency)
    s.add_development_dependency 'rspec', ['>= 1.2.8']
  end
  
  s.files = %w(
    template/html/images/next-hover.jpg
    template/html/images/next.jpg
    template/html/images/prev-hover.jpg
    template/html/images/prev.jpg
    template/html/javascripts/vid_skim.js
    template/html/stylesheets/vid_skim.css
    template/videos/example.json
    lib/vid_skim/command.rb
    lib/vid_skim/transcript.rb
    lib/vid_skim/parser.rb
    lib/vid_skim/compiler.rb
    lib/vid_skim/inflector.rb
    lib/vid_skim.rb
    vid-skim.gemspec
    views/template.html.erb
  )
end