from webdriver_manager.chrome import ChromeDriverManager
from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd

def salaries(tot_years = [2019,2020,2021]):
    for i in tot_years:
        final = pd.DataFrame()
        year1 = i
        years = str(year1) + '-' + str(year1+1)

        base = 'https://hoopshype.com/salaries/players//' 
        if i != tot_years[len(tot_years)-1]:
            URL = base + years
        else:
            URL = base
        # create the initial window
        options = webdriver.ChromeOptions()
        options.add_argument('headless')        
        driver = webdriver.Chrome(ChromeDriverManager().install(),options = options)
        # go to the home page
        driver.get(URL)

        tab = driver.find_element_by_xpath('//*[@class="hh-salaries-ranking"]')
        source = tab.get_attribute('innerHTML')
        soup = bs(source,'lxml')
        data = []
        table_body = soup.find('tbody')

        rows = table_body.find_all('tr')

        for row in rows:
            cols = row.find_all('td')
            cols = [ele.text.strip() for ele in cols]
            data.append([ele for ele in cols if ele]) # Get rid of empty values

        df = pd.DataFrame.from_records(data)
        df = df.loc[:,1:2]
        df.columns = ['player','contract']
        df['year'] = str(year1)
        driver.quit()

        final = final.append(df)
    return(final)
    