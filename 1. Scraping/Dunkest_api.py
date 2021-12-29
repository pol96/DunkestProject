from webdriver_manager.chrome import ChromeDriverManager

import selenium
from selenium import webdriver
from selenium.webdriver.support.ui import Select, WebDriverWait

from bs4 import BeautifulSoup as bs

import pandas as pd
from time import sleep
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 
import numpy as np

class dunkest():
    URL = 'https://nba.dunkest.com/it/home'
    teams = ['Atlanta Hawks','Boston Celtics','Brooklyn Nets','Charlotte Hornets','Chicago Bulls','Cleveland Cavaliers',
                 'Dallas Mavericks','Denver Nuggets','Detroit Pistons','Golden State Warriors','Houston Rockets','Indiana Pacers',
                 'Los Angeles Clippers','Los Angeles Lakers','Memphis Grizzlies','Miami Heat','Milwaukee Bucks','Minnesota Timberwolves',
                 'New Orleans Pelicans','New York Knicks','Oklahoma City Thunder','Orlando Magic','Philadelphia 76ers','Phoenix Suns',
                 'Portland Trail Blazers','Sacramento Kings','San Antonio Spurs','Toronto Raptors','Utah Jazz','Washington Wizards']

    def __init__ (self, pwd, email, verbose = False, win_hide = False):
        self.pwd = pwd
        self.email = email
        self.verbose = verbose
        self.win_hide = win_hide
    
    def driver_init(self):
        # create the initial window
        if self.win_hide:
            chrome_options = webdriver.ChromeOptions()
            chrome_options.add_argument('headless')
            driver = webdriver.Chrome(ChromeDriverManager().install(), chrome_options=chrome_options)
        else:
            driver = webdriver.Chrome(ChromeDriverManager().install())
        driver.maximize_window()
        # go to the home page
        driver.get(self.URL)
        sleep(4)
        driver.find_element_by_xpath('//*[@class = "iubenda-cs-opt-group-consent"]').click()
        sleep(1)
        driver.find_element_by_xpath('//*[@class ="dun-btn dun-btn--brand-03 dun-btn--login"]').click()
        sleep(1)
        # enter the email
        driver.find_element_by_xpath('//*[@name ="email"]').send_keys(self.email)
        driver.find_element_by_xpath('//*[@class ="dun-btn"]').click()  
        sleep(1)
        # enter the password
        driver.find_element_by_xpath('//*[@name ="password"]').send_keys(self.pwd)
        driver.find_element_by_xpath('/html/body/app-root/div/app-layout-dashboard/app-header/app-login/app-modal/div[1]/div/div/div/div[2]/div[2]/div[2]/button[2]').click()  
        sleep(4)

        # get into player stat page 
        window_before = driver.window_handles[0]
        self.driver = driver
        self.window_before = window_before
    
    def driver_quit(self):
        return(self.driver.quit())
    
    def credits_scraping(self, weeks = [str(i) for i in range(1,7)]):
        '''
        Extract per each selected Dunkest Week the relative scraped data (N.B. Retrieves Cr differences)
        Variables:
            - email
            - pwd
            - weeks: [str(i) for i in range(1,7)] as default
            - verbose: False as default
        '''
        df = pd.DataFrame()  
        final = pd.DataFrame()
        myurl = "'https://www.dunkest.com/it/nba/statistiche/giocatori/tabellone/regular-season/2021-2022?season_id=7&mode=dunkest&stats_type=avg&weeks[]=6&rounds[]=1&rounds[]=2&rounds[]=3&teams[]=1&teams[]=2&teams[]=3&teams[]=4&teams[]=5&teams[]=6&teams[]=7&teams[]=8&teams[]=9&teams[]=10&teams[]=11&teams[]=12&teams[]=13&teams[]=14&teams[]=15&teams[]=16&teams[]=17&teams[]=18&teams[]=19&teams[]=20&teams[]=21&teams[]=22&teams[]=23&teams[]=24&teams[]=25&teams[]=26&teams[]=27&teams[]=28&teams[]=29&teams[]=30&positions[]=1&positions[]=2&positions[]=3&player_search=&min_cr=4&max_cr=30&sort_by=pdk&sort_order=desc'"
        if self.verbose:
            print(myurl)
        myurlAction = 'window.open('+myurl+')'

        self.driver.execute_script(myurlAction)
        window_after = self.driver.window_handles[1]
        self.driver.switch_to_window(window_after)
        sleep(60)
        for week in weeks:
            if self.verbose:
                print(week, end = '')
            select = Select(self.driver.find_element_by_xpath('//*[@id="weeksSelect"]'))
            options = select.options
            for i in range(0, len(options)):
                select.deselect_by_visible_text(options[i].text)
            sleep(.66)
            select.select_by_visible_text(week)
            sleep(5)
            df = pd.DataFrame()
            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            last_page = int(self.driver.find_element_by_xpath('//*[@class = "paginationjs-page paginationjs-last J-paginationjs-page"]').text)
            counter = 0
            while counter < last_page:
                try:
                    tab = self.driver.find_element_by_xpath('/html/body/main/div[2]/table')
                    source = tab.get_attribute('innerHTML')
                    soup = bs(source,'lxml')
                    data = []
                    table_body = soup.find('tbody')

                    rows = table_body.find_all('tr')

                    for row in rows:
                        cols = row.find_all('td')
                        cols = [ele.text.strip() for ele in cols]
                        data.append([ele for ele in cols if ele]) # Get rid of empty values

                    f = pd.DataFrame.from_records(data)
                    df = df.append(f, ignore_index = True)
                    self.driver.find_element_by_xpath('//*[@class = "paginationjs-next J-paginationjs-next"]').click()
                    counter +=1
                except:
                    break
            df['Week'] = week
            final = final.append(df)
            if self.verbose:
                print(f'final: {final.shape} - df: {df.shape}')
        final.columns = ['Player','Role','Team','PDK','CR','PLUS','GP','MIN','ST','PTS','REB','AST','STL','BLK','BA','FGM','FGA','FGperc','P3M','P3A','P3perc','FTM','FTA','FTperc','OREB','DREB','TOV','PF','PlusMinus','Week']
        self.driver.close()
        self.driver.switch_to_window(self.window_before)
        return(final)

    def dunkest_scraping(self, id_players = range(1,10), filter_season = 'Regular Season 21/22'):
        '''
        Recall from Dunkest website all specific statistics game-by-game per player (selected all)
        Variables:
            - email 
            - password 
            - start_id_player (to filter out some players. it will run till exhaustion of ids): range(1,10) as Default
            - filter_season (selected season): 'Regular Season 20/21' as Default
        '''
        df = pd.DataFrame()
        not_stored = []
        for i in id_players:
            myurl = "'https://www.dunkest.com/it/giocatore/" +str(i) + "/nikola-jokic?iframe=yes'"
            myurlAction = 'window.open('+myurl+')'
            self.driver.execute_script(myurlAction)
            window_after = self.driver.window_handles[1]
            self.driver.switch_to_window(window_after)
            try:
                select = Select(self.driver.find_element_by_xpath('//*[@id="seasonSelect"]'))
                select.select_by_visible_text(filter_season)
                sleep(.66)
                self.driver.find_element_by_xpath('/html/body/main/div[2]/div/ul/li[2]/span').click()
                sleep(.66)
                tab = self.driver.find_element_by_xpath('//*[@id="gamesTable"]')
                source = tab.get_attribute('innerHTML')
                soup = bs(source,'lxml')
                data = []
                table_body = soup.find('tbody')

                rows = table_body.find_all('tr')

                for row in rows:
                    cols = row.find_all('td')
                    cols = [ele.text.strip() for ele in cols]
                    data.append([ele for ele in cols if ele]) # Get rid of empty values

                final = pd.DataFrame.from_records(data)
                final['Player'] = self.driver.find_element_by_xpath('//*[@class = "player-info__firstname"]').text + ' ' +  self.driver.find_element_by_xpath('//*[@class = "player-info__lastname"]').text
                final['Team'] = self.driver.find_element_by_xpath('//*[@class = "player-info__team"]').text
                final['Credits'] = self.driver.find_element_by_xpath('//*[@class = "player-stats__value"]').text 
                final.columns = ['Data','vs','PDK','MIN','ST','PTS','REB','AST','STL','BLK','BA','FGM','FGA','FG%','3PM','3PA','3P%','FTM','FTA','FT%','OREB','DREB','TOV','PF','+/-','Player','Team','Credits']
                df = df.append(final, ignore_index = True)
                self.driver.close()
                self.driver.switch_to_window(self.window_before)
            except:
                ns = self.driver.find_element_by_xpath('//*[@class = "player-info__firstname"]').text + ' ' +  self.driver.find_element_by_xpath('//*[@class = "player-info__lastname"]').text                
                not_stored.append(ns)
                self.driver.close()
                self.driver.switch_to_window(self.window_before)
                pass
            if self.verbose:
                print(f'no data for: {not_stored}')
        return(df)
    
    def dun_calendar_scraping(self):
        myurl = "'https://nba.dunkest.com/it/calendario-fantabasket-nba'"
        myurlAction = 'window.open('+myurl+')'

        self.driver.execute_script(myurlAction)
        window_after = self.driver.window_handles[1]
        self.driver.switch_to_window(window_after)
        calendar = pd.DataFrame()
        self.driver.find_element_by_xpath('//*[@class ="dun-sel__selected ng-star-inserted"]').click()
        tab = self.driver.find_element_by_xpath('//*[@class = "dun-sel__sub-list"]')
        source = tab.get_attribute('innerHTML')
        soup = bs(source,'lxml')
        ls = soup.text.split('\n')
        ls = [l for l in ls if 'Giornata' in l]
        select = self.driver.find_element_by_xpath('/html/body/app-root/div/app-layout-pages/app-schedule/div/div[1]/div[1]/app-single-select/div/div/ul/ul/li['+ls[len(ls)-1].replace('Giornata ','')+']')
        select.click()
        sleep(35)
        while True:
            try:
                txt = self.driver.find_element_by_xpath('//*[@class = "dun-article"]').text.split('\n')
                if 'Squadre a riposo' in txt:
                    idx= txt.index('Squadre a riposo')
                else:
                    idx = len(txt)        
                txt2 = [x for x in txt[:idx] if ('Giornata' in x)]
                txt3 = [x for x in txt[:idx] if (x in self.teams) or ('/' in x)]
                ls = list()
                for i in range(0,int(len(txt3)/3)):
                    ls.append(txt3[3*i:3+3*i])
                Dun_Calendar = pd.DataFrame(ls, columns = ['Home','Visitor','Date'])
                Dun_Calendar['DUN'] = txt2[0]
                calendar = calendar.append(Dun_Calendar)
                self.driver.find_element_by_xpath('//*[@class="dun-btn-icn__wrap"]').click()
            except:
                break
        self.driver.close()
        self.driver.switch_to_window(self.window_before)
        return(calendar)