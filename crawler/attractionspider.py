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

        # 2. 解析数据
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

        print("name", attribute_name, "time", recommend_time)
        real_name = '' if attribute_name == [] else attribute_name[0]
        real_time = '' if recommend_time == [] else recommend_time[0]
        minute_type_time = time_processing(real_time)
        # the attr_name and time are both list,pick them up
        attribute_list.append([real_name, str(minute_type_time)])

    print(attribute_list)
    return attribute_list


def main():
    # 1. 发出请求，获取响应数据
    headers = {
        "User-Agent": "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
    }
    # basic_url = 'https://www.trip.com/travel-guide/attraction/new-york-248/tourist-attractions/'
    basic_url = 'https://us.trip.com/travel-guide/attraction/california-21636/tourist-attractions/'

    # 初始化导出文件
    csv_header = ['name', 'recommend_time']
    with open('california_information.csv', 'w', encoding='utf-8', newline='') as fp:
        # 写
        writer = csv.writer(fp)
        # 设置第一行标题头
        writer.writerow(csv_header)

    for i in range(1, 6):
        url = basic_url+str(i)+".html/"

        html = get_html(headers, url)
        # 获取每个景点的url
        url_list = html.xpath(
            '//ul[@class="poi-list-card"]/li/a/@href')

        # # 处理times中的\n和空格
        # # 准备一个列表times1存放处理好的数据
        # times1 = []
        # for t in range(1, len(times), 4):
        #     ti = re.sub(r'\s+', '', times[t])
        #     times1.append(ti)
        #     print(ti)
        # # 3. 存储数据
        # titles = zip(titles, times1)
        # with open('tongcheng.csv', mode='w', newline='', encoding='utf-8') as f:
        #     w_file = csv.writer(f)
        #     w_file.writerows(titles)

        print(url_list)
        # 获取景点信息
        attribute_info = get_attributes(url_list, headers)
        with open('california_information.csv', 'a', encoding='utf-8', newline='') as fp:
            # 写
            writer = csv.writer(fp)
        # 将数据写入
            writer.writerows(attribute_info)


if __name__ == "__main__":
    main()
