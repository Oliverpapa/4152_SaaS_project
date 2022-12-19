# 4152_SaaS_project

## Team members
Zifan Chen,		zc2628 

Qiao Huang,		qh2234 

Shengqi Cao,	sc5124 

Yuerong Zhang,  yz4143 


## Environment

OS: MAC 10.14 or Ubuntu 22.04

Ruby: 2.6.6

Python: 3.9

Branch for iter1: proj_iter1

Branch for iter2: proj_iter2

Branch for launch: proj_launch

## Instruction to run

### The Application

NOTE: Our application will use cookies. Please allow cookies usage in your browser.
P.S. If strange things happen on customize page, please clear your cookies and rerun.

Step 1: 

Replace the google map API key (in Courseworks submitted README file) to enable google map embedding:
in file app\views\traveling_plans\customize.html.erb (line 4)

Step 2:
```
bundle install --without production
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec rake db:test:prepare
rails server 
# Open a regular browser window to localhost:3000/
```

### The Crawler & Places API Request

Relative scripts and data are stored in crawler folder under root dir

Step 1: gathering data from websites
```
cd crawler
python attractionspider.py
```

Step 2: using API request get attraction information
```
cd place_detail
```
Add your Google Maps API key in the file: api_key.txt
```
pip install python-google-places 
python get_loc_info.py
```
The new generated seeds.rb is the new seed file you could use in /db dir


## Instruction to test
```
# Install Chrome for cucumber tests (https://www.google.com/chrome/)
# Note: In very rare case, cucumber test needs to be reruned to be fully passed 
#       due to the unstable response speed of Selenium::WebDriver.
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
