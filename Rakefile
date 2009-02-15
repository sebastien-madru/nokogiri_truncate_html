# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'hanna/rdoctask'
require 'garlic/tasks'

plugin_name = "truncate_html"

task :default => :spec

task :cruise => ['garlic:all', 'doc:push'] do
  puts "The build is GOOD"
end

desc "Run the specs for #{plugin_name}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

desc "Generate RCov report for #{plugin_name}"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
  t.rcov_dir    = 'doc/coverage'
  t.rcov_opts   = ['--text-report', '--exclude', "spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
end

namespace :rcov do
  desc "Verify RCov threshold for #{plugin_name}"
  RCov::VerifyTask.new(:verify => "spec:rcov") do |t|
    t.threshold = 100.0
    t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
  end
end

task :doc => 'doc:build'

namespace :doc do
  def sha
    `git log -1 --pretty=format:"%h"`
  end
  
  Rake::RDocTask.new(:build) do |d|
    d.rdoc_dir = 'doc'
    d.main     = 'README.rdoc'
    d.title    = "#{plugin_name} API Docs (#{sha})"
    d.rdoc_files.include('README.rdoc', 'History.txt', 'License.txt', 'Todo.txt', 'lib/**/*.rb')
  end
  
  task :push => 'doc:build' do
#    if sha != `cat`
#      
#    mv 'doc', 'newdoc'
#    on_gh_pages do
#      if doc_changed_sha?('newdoc', 'doc')
#        puts "doc has changed, pushing to gh-pages"
#        `rm -rf doc && mv newdoc doc`
#        `git add doc`
#        `git commit -a -m "Update API docs"`
#        `git push`
#      else
#        puts "doc is unchanged"
#        rm_rf 'newdoc'
#      end
#    end
  end
  
  def doc_changed_sha?(docpath1, docpath2)
    `cat #{docpath1}/index.html | grep "<title>"` != `cat #{docpath2}/index.html | grep "<title>"`
  end
  
  def on_gh_pages(&block)
    `git branch -m gh-pages orig-gh-pages > /dev/null 2>&1`
    `git checkout -b gh-pages origin/gh-pages`
    `git pull`
    yield
  ensure
    `git checkout master`
    `git branch -D gh-pages`
    `git branch -m orig-gh-pages gh-pages > /dev/null 2>&1`
  end
end
