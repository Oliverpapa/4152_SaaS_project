import requests
from lxml import etree
import re
import csv
from time import sleep


def time_processing(time):
    if time == '':
        return ''
    # divide time and format
    newTime = time.split(" ")
    print(newTime)
    num = re.findall(r"\d+\.?\d*", newTime[0])
    # pick up the minimum time as the real recommend time
    num = num[0]
    op = newTime[1]
    if op == 'day':
        return float(num) * 60 * 24
    elif op == 'days':
        return float(num) * 60 * 24
    elif op == 'hours':
        return float(num) * 60
    elif op == 'hour':
        return float(num) * 60
    elif op == 'minutes':
        return int(num)


def get_html(headers, url):
    sleep(2)
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.text

        # parsing the data
        html = etree.HTML(data)
        return html
    else:
        print('error')


def get_attributes(url_list, headers):
    html_list = []
    for url in url_list:
        html = get_html(headers, url)
        html_list.append(html)

    attribute_list = []
    for html in html_list:
        attribute_name = html.xpath(
            '//h1[@class="basicName"]/text()')
        recommend_time = html.xpath(
            # bad way but dont know other way except last()-1
            '//div[@class="basic-info border-gap"]/div[last()-1]/div/span[2]/text()')
        # rating = html.xpath(
        #     '//span[@class="gl-poi-detail-rating"]/span[1]/text()')
        print("name", attribute_name, "time", recommend_time)
        real_name = '' if attribute_name == [] else attribute_name[0]
        real_time = '' if recommend_time == [] else recommend_time[0]
        # real_rating = '' if rating == [] else rating[0]
        minute_type_time = time_processing(real_time)
        # the attr_name and time are both list,pick them up
        attribute_list.append([real_name, str(minute_type_time)])

    print(attribute_list)
    return attribute_list


def main():
    # 1. send the request
    headers = {
        "User-Agent": "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
    }
    # basic_url = 'https://www.trip.com/travel-guide/attraction/new-york-248/tourist-attractions/'
    # basic_url = 'https://us.trip.com/travel-guide/attraction/california-21636/tourist-attractions/'
    # basic_url = 'https://www.trip.com/travel-guide/attraction/los-angeles-120518/tourist-attractions/'
    basic_url = 'https://us.trip.com/travel-guide/attraction/tacoma-41634/tourist-attractions/'

    # initialize the csv
    csv_header = ['name', 'recommend_time']
    with open('Tacoma_information.csv', 'w', encoding='utf-8', newline='') as fp:
        # write
        writer = csv.writer(fp)
        # set the header of csv
        writer.writerow(csv_header)

    for i in range(1, 2):
        url = basic_url+str(i)+".html/"

        html = get_html(headers, url)
        # get url of each attribute
        url_list = html.xpath(
            '//ul[@class="poi-list-card"]/li/a/@href')

        print(url_list)
        # get attributes info
        attribute_info = get_attributes(url_list, headers)
        with open('Tacoma_information.csv', 'a', encoding='utf-8', newline='') as fp:
            # write
            writer = csv.writer(fp)
        # write the data into csv
            writer.writerows(attribute_info)


if __name__ == "__main__":
    main()
