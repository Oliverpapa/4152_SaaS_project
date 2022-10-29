# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

attractions = [{:name => 'Empire State Building', :rating => 4.7, :address => '20 W 34th St., New York, NY 10001', :city => 'New York', :state => 'NY', :latitude => 40.7484396, :longitude => -73.9944193, :recommended_time => 60, :open_time=> "09:00:00", :close_time=> "22:00:00"},
		  	{:name => 'The Met', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -74.0950799, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "21:00:00"},
		  	{:name => 'MoMA ', :rating => 4.6, :address => '11 W 53rd St, New York, NY 10019', :city => 'New York', :state => 'NY', :latitude => 40.7484714, :longitude => -73.9944193, :recommended_time => 180, :open_time=> "10:30:00", :close_time=> "17:30:00"},
		  	{:name => 'Statue of Liberty', :rating => 4.7, :address => 'Statue of Liberty, New York, NY 10004', :city => 'New York', :state => 'NY', :latitude => 40.6917572, :longitude => -74.0429902, :recommended_time => 180, :open_time=> "08:30:00", :close_time=> "16:00:00"},
		  	{:name => 'Columbia University', :rating => 4.7, :address => 'Columbia University, New York, NY 10027', :city => 'New York', :state => 'NY', :latitude => 40.8075395, :longitude => -73.9670574, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"},
		  	{:name => 'The Metropolitan Museum of Art', :rating => 4.8, :address => '1000 5th Ave, New York, NY 10028', :city => 'New York', :state => 'NY', :latitude => 40.7794366, :longitude => -73.9654327, :recommended_time => 120, :open_time=> "10:00:00", :close_time=> "17:00:00"},
			{:name => 'Times Square', :rating => 4.7, :address => 'Manhattan, NY 10036', :city => 'New York', :state => 'NY', :latitude => 40.7576753, :longitude => -73.9866887, :recommended_time => 60, :open_time=> "00:00:00", :close_time=> "00:00:00"},
			{:name => 'Rockefeller Center', :rating => 4.7, :address => '45 Rockefeller Plaza, New York, NY 10111', :city => 'New York', :state => 'NY', :latitude => 40.7587402, :longitude => -73.9808623, :recommended_time => 120, :open_time=> "00:00:00", :close_time=> "00:00:00"},
			{:name => 'Kaaterskill Falls, Viewing Platform', :rating => 4.8, :address => 'Laurel House Rd, Palenville, NY 12463', :city => 'Palenville', :state => 'NY', :latitude => 42.6135313, :longitude => -74.3227508, :recommended_time => 180, :open_time=> "08:00:00", :close_time=> "18:00:00"},
			{:name => 'Howe Caverns', :rating => 4.6, :address => '255 Discovery Dr, Howes Cave, NY 12092', :city => 'Howes Cave', :state => 'NY', :latitude => 42.6632755, :longitude => -74.4488459, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "15:00:00"},
			{:name => 'Lake George Mystery Spot', :rating => 4.7, :address => '1 Beach Rd, Lake George, NY 12845', :city => 'Lake George', :state => 'NY', :latitude => 43.4088805, :longitude => -73.7685816, :recommended_time => 180, :open_time=> "00:00:00", :close_time=> "00:00:00"},
			]


			

attractions.each do |attraction|
  Attraction.create!(attraction)
end