from googleplaces import GooglePlaces, types, lang
import os

cwd = os.getcwd()
print(cwd)

# read api key from file
with open(os.path.join(cwd, 'api_key.txt'), 'r') as f:
    api_key = f.read().strip()
    
YOUR_API_KEY = api_key

google_places = GooglePlaces(YOUR_API_KEY)

def get_loc_info(location, keyword, radius=20000):
    # You may prefer to use the text_search API, instead.
    query_result = google_places.nearby_search(
            location=location, keyword=keyword,
            radius=radius)

    if query_result.has_attributions:
        print(query_result.html_attributions)
        
    loc_info = {}

    for place in query_result.places:
        # Returned places from a query are place summaries.
        print(place.name)
        loc_info['name'] = place.name
        
        print(place.geo_location)
        loc_info['lat'] = float(place.geo_location['lat'])
        loc_info['lng'] = float(place.geo_location['lng'])
        
        # print(place.place_id)
        
        place.get_details()
        # print(place.details.keys())
        # print(place.international_phone_number)
        # loc_info['phone'] = place.international_phone_number
        
        print(place.formatted_address)
        loc_info['address'] = place.formatted_address 
        
        print(place.details.get('opening_hours', "24/7"))
        opening_time = place.details.get('opening_hours', "24/7")
        
        if opening_time != "24/7" and len(opening_time['periods']) > 1:
            loc_info['open_time'] = opening_time['periods'][1]['open']['time'][:-2]+":"+opening_time['periods'][0]['open']['time'][-2:]+":00"
            loc_info['close_time'] = opening_time['periods'][1]['close']['time'][:-2]+":"+opening_time['periods'][0]['close']['time'][-2:]+":00"
        else:
            loc_info['open_time'] = "08:00:00"
            loc_info['close_time'] = "22:00:00"
        
        print(place.rating)
        loc_info['rating'] = place.rating
        
        loc_info['website'] = place.details.get('website', "")
        loc_info['map_url'] = place.details.get('url', "")
        
        break
    return loc_info

# transform loc_info to one line in ruby seed file
# example: {:name => "The Met", :rating => 4.8, :address => "1000 5th Ave, New York, NY 10028", :city => "New York", :state => "NY", 
#           :latitude => 40.7794366, :longitude => -74.0950799, :recommended_time => 180, :open_time=> "10:00:00", :close_time=> "21:00:00"},
def format_convert(loc_info, state, city, recommended_time):
    line = "{"
    line += ':name => "' + loc_info['name'] + '", '
    if loc_info['rating'] == 0 or str(loc_info['rating']) == '':
        loc_info['rating'] = 3.8
    line += ':rating => ' + str(loc_info['rating']) + ", "
    line += ':address => "' + loc_info['address'] + '", '
    if len(loc_info['address'].split(", ")) >= 3:
        line += ':city => "' + loc_info['address'].split(", ")[-3] + '", '
    else:
        line += ':city => "' + city + '", '
    line += ':state => "' + state + '", '
    line += ':latitude => ' + str(loc_info['lat']) + ", "
    line += ':longitude => ' + str(loc_info['lng']) + ", "
    line += ':recommended_time => ' + str(recommended_time) + ", "
    line += ':open_time => "' + loc_info['open_time'] + '", '
    line += ':close_time => "' + loc_info['close_time'] + '", '
    line += ':website => "' + loc_info['website'] + '", '
    line += ':map_url => "' + loc_info['map_url'] + '", '
    # line += ":phone => "' + loc_info['phone'] + '", '
    line += "},"
    return line
    
def get_keyword_and_suggested_time_from_csv_file(state, csv_file):
    result = ''
    with open(csv_file, 'r') as f:
        # ignore the first line and loop through the rest
        f.readline()
        for line in f:
            if line.strip() == "": continue
            keyword, recommended_time, city = line.strip().split(",")
            loc_info = get_loc_info(city + ", " + state + ", USA", keyword)
            if loc_info == {}: continue
            if recommended_time.strip() in ("", "None", "0"):
                recommended_time = 60
            recommended_time = int(float(recommended_time))
            if recommended_time > 720:
                recommended_time = 720
                
            result += format_convert(loc_info, state, city, recommended_time) + '\n'
    return result
    

def main():
    content = "attractions = ["
    ny_attractions = get_keyword_and_suggested_time_from_csv_file('NY', os.path.join(cwd, 'NY_information.csv'))
    ca_attractions = get_keyword_and_suggested_time_from_csv_file('CA', os.path.join(cwd, 'CA_information.csv'))
    wa_attractions = get_keyword_and_suggested_time_from_csv_file('WA', os.path.join(cwd, 'WA_information.csv'))
    content += wa_attractions + ca_attractions + ny_attractions
    content += "]\n" + "\n" + "attractions.each do |attraction|\n" + "  Attraction.create!(attraction)\n" + "end\n"
    # write to file seeds.rb
    with open(os.path.join(cwd, 'seeds.rb'), 'w') as f:
        f.write(content)
    
    
if __name__ == '__main__':
    main()  

