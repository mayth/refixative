TSC = 'tsc'
SASS = 'bundle exec sass'

task :default => :generate

desc "Generate all files"
task :generate => [:generate_js, :generate_css]

desc "Generate JavaScript files from TypeScript files"
task :generate_js => ['player_score_sorter'].map{|s| "public/script/#{s}.js"}

desc "Generate CSS file from Sass file"
task :generate_css => 'public/style.css'

rule %r{^public/script/.*\.js} => '%{^public/script,assets}X.ts' do |t|
  sh "#{TSC} --out #{t.name} #{t.prerequisites[0]}"
end

file 'public/style.css' => 'assets/style.sass' do |t|
  sh "#{SASS} -t compressed #{t.prerequisites[0]} #{t.name}"
end
