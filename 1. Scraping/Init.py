import sys
import os
import yaml
from datetime import date
from datetime import datetime
module_path = os.path.abspath(os.path.join('..'))
if module_path not in sys.path:
    sys.path.append(module_path+"\\py")
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
from time import sleep
import pandas as pd
import shutil

from BasketRef_api import NBA
from Dunkest_api import dunkest
from Salary_api import salaries

with open(module_path+"\\py\\credentials.yml", "r") as stream:
    try:
        credentials_dict = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

# giornata dunkest
cal = pd.read_csv(r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\Dun_calendar.csv',sep = ';')
d = '0'+str(date.today().day) if date.today().day <10 else str(date.today().day)
m = '0'+str(date.today().month) if date.today().day <10 else str(date.today().month)

day = d+'/'+m
dun_giornata = int(cal[cal['Date'] == day]['DUN'].unique()[0].replace('Giornata ',''))

#season
if (date(date.today().year,9,30)<date.today()<date(date.today().year,12,31)):
    season = date.today().year+1
else:
    season = date.today().year

def dunkest_package(mail = credentials_dict['user'], password = credentials_dict['pwd'],players = False,giornata = 2):
    cal,pl,cr = pd.DataFrame(),pd.DataFrame(),pd.DataFrame()
    credits = dunkest(email = mail,pwd = password)
    
    credits.driver_init()    
    if f'{str(date.today().month)}/{str(date.today().day)}' == '10/10':
        cal = credits.dun_calendar_scraping()   
        cal.to_csv(r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\Dun_calendar.csv',sep = ';', index = False)
    if  ((date(date.today().year,9,30)<date.today()<date(date.today().year +1,6,30)) or \
        (date(date.today().year -1,9,30)<date.today()<date(date.today().year ,6,30))):
        cr = credits.credits_scraping(weeks = [str(i) for i in range(1,giornata)])
    
    if players:
        pl = credits.dunkest_scraping(id_players = range(1,1050))
    credits.driver_quit()
    return(cr, cal, pl)
def nba_package(year = 2022):
    
    players, stats = pd.DataFrame(),pd.DataFrame()
    info = NBA(year)
    
    if  ((date(date.today().year,9,30)<date.today()<date(date.today().year +1,6,30)) or \
        (date(date.today().year -1,9,30)<date.today()<date(date.today().year ,6,30))):
        players = info.active_players()
        stats = info.nba_stats(players)
        
    if f'{str(date.today().month)}/{str(date.today().day)}' == '10/10':
        info.year_calendar()
    return(players, stats)
def downloads(season, dun_giornata):
    print(f'Stagione: {season}, Giornata dunkest: {dun_giornata}')
    print('NBA Download ....', end = ' ')
    npl,nstats = nba_package(year = season)
    print('Done', end = '\n++++++++++++++++++++++++++++++\n')
    print('Dunkest Download ....', end = ' ')
    dcr, dcal, dpl = dunkest_package(giornata = dun_giornata)
    print('Done', end = '\n++++++++++++++++++++++++++++++\n')
    print('Salaries Download ....', end = ' ')
    sal = salaries(tot_years = [season-1])
    print('Done', end = '\n++++++++++++++++++++++++++++++\n')
    
    dwnld = [[npl,nstats,dcr,dcal,dpl,sal],
        ['NBA_Active_Players.csv',
         'NBA_Players_Stats.csv',
         'Dun_Credits.csv',
         'Dun_Calendar.csv',
         'Dun_Players.csv',
         'contracts.csv']]
    for i in range(0,len(dwnld[1])):
        if dwnld[0][i].shape[0]>0:
            dwnld[0][i].to_csv(r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\\'+dwnld[1][i],sep=';',index=False)
        else:
            pr = dwnld[1][i].replace('.csv','')
            print(f'No Data Available for {pr}')
    print('\nProcess Terminated.')

print(f'Process Start at: {datetime.now()}')
sleep(.66)
sleep(1)
bck_path = r'C:\Users\ptico\Google Drive\DUNKEST Project\weekly_backup'
shutil.make_archive(bck_path + '\\bck_'+date.today().strftime('%Y_%m_%d'), 'zip', r'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads')
print(f'new Backup Folder uploaded in {bck_path}')
sleep(.66)
downloads(season = season,dun_giornata = dun_giornata)