import mysql.connector as c
from mysql.connector import Error

class runner():
    def __init__ (self, host, user, pwd, verbose = False):
        self.host = host
        self.user = user
        self.pwd = pwd
        self.verbose = verbose
        self.script = []
    
    def load_script(self, full_filename):
        ''' SQL script loader, it cleanses out tabs and backspaces'''
        sql = open(full_filename,'r')
        script = sql.read().split(';\n')
        script = [script[i].replace('\t',' ').replace('\n',' ')+';' for i in range(0,len(script)) if len(script[i])>4]
        self.script.append(script)
        return(self.script)
    
    def connect(self, flatten = True):
        ''' Runs each DML query and commits righ after'''
        mydb = c.connect(host = self.host, user = self.user, passwd = self.pwd)
        if mydb.is_connected():
            runner = mydb.cursor()
            if flatten:
                flat_list = [item for sublist in self.script for item in sublist]
            else:
                flat_list = self.script
            counter = 0
            for s in flat_list:
                try:
                    runner.execute(s)
                    mydb.commit()
                    print(f'Command: {counter} succesfully executed')
                except Error as e:
                    print(f'Error: {e}')
                counter+=1
        else:
            print('Could not access to selected DB')