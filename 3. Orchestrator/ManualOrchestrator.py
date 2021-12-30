import yaml 

from DBrunner import runner 

module_path = r"C:\Users\ptico\Google Drive\DUNKEST Project\mysqluser.yml"
#Load Credentials
with open(module_path, "r") as stream:
    try:
        db_credentials = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)


DB = runner(host = db_credentials['host'],
           user = db_credentials['usr'],
           pwd = db_credentials['pwd'],
           verbose = True)
scripts = [r"C:\\GitNBA\DunkestProject\2. MySQL\Setup\\NBA_Load_From_CSV.sql",
           r"C:\\GitNBA\DunkestProject\2. MySQL\EDWP\\_database.sql",
           r"C:\GitNBA\DunkestProject\2. MySQL\EDWP\D_TEAMS__EDWP.sql",
           r"C:\GitNBA\DunkestProject\2. MySQL\EDWP\D_CALENDAR__EDWP.sql",
           r"C:\GitNBA\DunkestProject\2. MySQL\EDWP\D_PLAYER__EDWP.sql",
           r"C:\GitNBA\DunkestProject\2. MySQL\EDWP\F_STATS__EDWP.sql"
          ]

for s in scripts:
    DB.load_script(s)
if __name__ == '__main__':
    DB.connect()