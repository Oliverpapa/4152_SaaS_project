# 4152_SaaS_project
## Team members
Zifan Chen,		zc2628 
Qiao Huang,		qh2234 
Shengqi Cao,	sc5124 
Yuerong Zhang,  yz4143 

rails generate model Attraction name:string address:string city:string state:string latitude:float longitude:float recommended_time:integ rating:float open_time:time close_time:time

## Install
```
bundle install --without production
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:test:prepare
```
