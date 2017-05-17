source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "dotenv-rails", groups: [:development, :test]
gem "rails", "~> 5.0.2"
gem "mysql2", ">= 0.3.18", "< 0.5"
gem "puma", "~> 3.0"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.2"
gem "jquery-rails"
gem "jbuilder", "~> 2.5"
gem "devise"
gem "bootstrap-sass", "~> 3.2.0"
gem "faker"
gem "kaminari"
gem "mini_magick"
gem "carrierwave"
gem "ckeditor"
gem "paperclip"
gem "config"
gem "ratyrate"
gem "omniauth"
gem "omniauth-twitter"
gem "omniauth-facebook"
gem "twitter"
gem "omniauth-google-oauth2"
gem "pry"
gem 'sidekiq'
gem 'sinatra', require: false
gem "figaro"
gem "listen", "~> 3.0.5"

group :development, :test do
  gem "byebug", platform: :mri
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :production do
  gem "pg"
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
