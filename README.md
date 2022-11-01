# 4152_SaaS_project

## Team members
Zifan Chen,		zc2628 

Qiao Huang,		qh2234 

Shengqi Cao,	sc5124 

Yuerong Zhang,  yz4143 


## Environment

OS: MAC 10.14 or Ubuntu 22.04

Ruby: 2.6.6

Branch for iter1: proj_iter1

## Instruction to run
```
bundle install --without production
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:test:prepare
rails server 
# Open a regular browser window to localhost:3000/
```

## Instruction to test
```
# Install Chrome for cucumber tests (https://www.google.com/chrome/)
bundle exec rake cucumber
bundle exec rake spec
```
## Instruction to deploy
```
heroku create trapplar --stack heroku-20
git push heroku main
# Add postgresql DB on heroku and set Config Vars: [DB_NAME, DB_USERNAME, DB_PASSWORD, DB_PORT, DB_URL]
heroku run bundle exec rake db:migrate --app trapplar
heroku run bundle exec rake db:seed --app trapplar
```

## Links
### Github
```
https://github.com/Oliverpapa/4152_SaaS_project
```
### Heroku
```
https://trapplar.herokuapp.com/
```
