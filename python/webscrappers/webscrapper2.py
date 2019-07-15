#!/usr/bin/python3

import requests
import sys
from bs4 import BeautifulSoup


# get the data
data = requests.get(sys.argv[1])

# load data into bs4
soup = BeautifulSoup(data.text, 'html.parser')

