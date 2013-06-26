TSC = 'tsc'
SASS = 'bundle exec sass'

task :default => :deploy

task :deploy => ['public/script/player_score_sorter.js', 'public/style.css']

file 'public/script/player_score_sorter.js' => 'public/script/player_score_sorter.ts' do |t|
  sh "#{TSC} --out #{t.name} #{t.prerequisites[0]}"
end

file 'public/style.css' => 'views/style.sass' do |t|
  sh "#{SASS} -t compressed #{t.prerequisites[0]} #{t.name}"
end
