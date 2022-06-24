import requests as re
from bs4 import BeautifulSoup as bs
import pandas as pd
import string
import datetime
import time

class NBA():
    stats = ['game_season', 'date_game', 'age', 'team_id', 'game_location', 'opp_id', 'game_result','gs', 'mp', 'fg',
         'fga', 'fg_pct', 'fg3', 'fg3a', 'fg3_pct', 'ft', 'fta', 'ft_pct', 'orb',
         'drb', 'trb', 'ast', 'stl', 'blk', 'tov', 'pf', 'pts', 'game_score', 'plus_minus']
    
    attr = ['year_min','year_max','pos','height','weight','birth_date','colleges']
    
    def __init__ (self, season, verbose = False, path = r'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads//'):
        self.season = season
        self.verbose = verbose
        self.path = path
        
    def full_list_players(self, no_name_letter = 'x'):
        letters = list(string.ascii_lowercase)
        letters.remove(no_name_letter)
        all_players = pd.DataFrame()
        for l in letters:
            full_url = 'https://www.basketball-reference.com/players/'+l
            page = re.get(full_url)
            soup = bs(page.content, 'html.parser')
            #names: identifier: th
            url = []
            pl = []
            x = soup.findAll('th', {'data-stat': 'player'})
            #extract url page
            for q in x[1:]:
                ref = q.find_all('a')
                if ((len(ref)>0) and ('players/' in ref[0]['href'])):
                    url.append(ref[0]['href'])
                    pl.append(ref[0].getText())        
            md = pd.DataFrame({'player':pl,'url':url})

            #attributes: identifier: td
            stats_list = [[td.getText() for td in soup.findAll('td', {'data-stat': col})] for col in self.attr]
            a = pd.DataFrame(stats_list).T
            a.columns = self.attr
            pl = pd.concat([md,a],1)
            all_players = all_players.append(pl)

        all_players['url'] = 'https://www.basketball-reference.com'+all_players['url'].str.replace('.html','')+'/gamelog/'
        return(all_players)

    def active_players(self):
        all_players = self.full_list_players()
        df = all_players[all_players['year_max'] == str(self.season)].reset_index(drop = True)
        return (df) 
    
    def nba_stats(self,db):
        data = pd.DataFrame()
        if self.verbose:
            print(db.shape[0])
        for p in range(0,db.shape[0]):
            start_time = time.time()
            print(f'{p} - {db.iloc[p,1]+str(self.season)} ...', end = ' ')
            try:
                df = pd.DataFrame()
                st_url = db.iloc[p,1]+str(self.season)
                _id = db.iloc[p,0]
                page = re.get(st_url)
                soup = bs(page.content, 'html.parser')
                for tr in soup('tr'):
                    if (len(tr('td'))<8):
                        tr.extract()        
                    elif ((tr('td')[7].text == 'Inactive') or (tr('td')[7].text == 'Did Not Play') or (tr('td')[7].text == 'Did Not Dress') or (tr('td')[7].text == 'Player Suspended')):
                        tr.extract()
                stats_list = [[td.getText() for td in soup.findAll('td', {'data-stat': stat})] for stat in self.stats]
                df = pd.DataFrame(stats_list).T
                df.columns = self.stats
                df['Player'] = _id
                data = data.append(df)
                if self.verbose:
                    print(f'{_id,st_url} Successfully downloaded')
            except:
                raise TypeError(f'404: {st_url} not found')
                pass
            print(f'execution time: {round(time.time()-start_time,2)}')
        return(data)
    
    def year_calendar (self):
        year = self.season -1
        r = re.get('https://data.nba.com/data/10s/v2015/json/mobile_teams/nba/' + str(year) + '/league/00_full_schedule.json')
        json_data = r.json()

        # prepare output files
        fout = open(self.path+"filtered_schedule.csv", "w")
        fout.writelines('GameDate, GameID, Visitor, Home, HomeWin')

        current_dt = datetime.datetime.now() 

        # loop through each month/game and write out stats to file
        for i in range(len(json_data['lscd'])):
            for j in range(len(json_data['lscd'][i]['mscd']['g'])):
                gamedate = json_data['lscd'][i]['mscd']['g'][j]['gdte']
                gamedate_dt = datetime.datetime.strptime(gamedate, "%Y-%m-%d")

                game_id = json_data['lscd'][i]['mscd']['g'][j]['gid']
                visiting_team = json_data['lscd'][i]['mscd']['g'][j]['v']['ta']
                home_team = json_data['lscd'][i]['mscd']['g'][j]['h']['ta']

                fout.write('\n' + gamedate +','+ game_id +','+ visiting_team +','+ home_team)

                # don't access scores for games that haven't been played yet
                if(gamedate_dt < current_dt):  
                    home_team_won = json_data['lscd'][i]['mscd']['g'][j]['h']['s'] > json_data['lscd'][i]['mscd']['g'][j]['v']['s']
                    fout.write(','+ str(home_team_won))
                else:
                    fout.write(','+ '_')
        fout.close()
        r.close()
        print(f'calendar for year {year} exported succesfully')