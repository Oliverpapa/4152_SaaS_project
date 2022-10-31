# 4152_SaaS_project

## Team members
Zifan Chen,		zc2628 

Qiao Huang,		qh2234 

Shengqi Cao,	sc5124 

Yuerong Zhang,  yz4143 


## Instruction to run
```
cd trapplar/
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
