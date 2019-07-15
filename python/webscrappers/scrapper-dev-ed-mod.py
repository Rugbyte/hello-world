#!/usr/bin/python3
# Made based off of https://www.youtube.com/watch?v=Bg9r_yLk7VY

import requests
from bs4 import BeautifulSoup
import smtplib
import time

url = "https://www.amazon.ca/Sony-Full-Frame-Mirrorless-Interchangeable-Lens-ILCE7M3K/dp/B07B45D8WV/ref=sr_1_4?keywords=sony%2Ba7&qid=1563209892&s=gateway&sr=8-4"

headers = {
    "User-Agent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36'}


def check_price():
    page = requests.get(url, headers=headers)
    soup = BeautifulSoup(page.content, 'html.parser')
    title = soup.find(id="productTitle").get_text()

    # print(soup.prettify())
    print(title.strip())
    price = soup.find(id="priceblock_ourprice").get_text()
    converted_price = float(price[5:].replace(',', ''))

    if (converted_price <= 1800):
        send_mail()
        pass

    print(price.strip())
    # print(str(converted_price) + " " + str(goodprice))
    pass


def send_mail():
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls()
    server.ehlo()

    server.login('email', 'password')

    subject = 'Price is now good to purchase'
    body = 'Check the amazon link {url}'
    msg = f"Subject: {subject}\n\n{body}"

    server.sendmail(
        'from',
        'to',
        msg
    )

    print("Email has been sent")
    server.quit
    pass


while (True):
    check_price()
    time.sleep(60)
    pass
