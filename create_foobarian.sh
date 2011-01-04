rvm use 1.8.7
rvm gemset create foobarian
rvm gemset use foobarian
gem install rails
yes yes | rails new foobarian -JOT -m templater.rb
