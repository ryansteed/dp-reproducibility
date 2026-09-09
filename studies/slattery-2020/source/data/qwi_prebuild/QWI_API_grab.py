#This code downlaods QWI data using Census API 

from zipfile import ZipFile
import os
import urllib.request
from urllib.request import urlopen
from io import BytesIO
import csv
import json, sys

#Set up directory to which QWI files are drawn.
dirname = '/Users/sk33/Documents/qwi/raw'
#John - dirname = '/Users/johnwieselthier/Desktop/for_steph'
os.chdir(dirname)

#API key can be obtained in QWI website, and is required to draw files. 
# https://api.census.gov/data/key_signup.html

APIkey = "f16583b4f6b7fc3c176691eaf1c706df7982c51b"
#John - APIkey = "55e6a408a703edbb3eb78ed6018aa63c7cc1e473"


#Set up loop variables
NAICS = ['111','112','113','114','115','211','212','213','221','236','237','238','311','312','313','314','315','316','321','322', '323','324','325','326','327','331','332',  '333','334','335','336','337','339','423','424','425','441','442','443','444','445','446','447','448','451','452','453','454','481','482','483','484','485','486','487','488','491','492', '493', '511','512','515', '517', '518', '519', '521','522','523','524','525','531','532', '533', '541','551','561','562','611','621','622','623', '624', '711', '712', '713', '721', '722','811', '812', '813', '814']
FIPS = ['01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53','54','55','56']
#FIPS = ['28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53','54','55','56']

csv.register_dialect('myDialect', delimiter = '|', lineterminator = '\n\n')


#Run loop. Note The code has stopped in the middle a few times, so Steph had to reset the loop. 
for state in FIPS:
    print(state)
    for industry in NAICS:
        print(industry)
        for year in range(1990, 2019):
            print(year)
            api = r"http://api.census.gov/data/timeseries/qwi/se?get=Emp,sEmp,firmsize,Payroll&for=county:*&in=state:"+state+"&year="+str(year)+"&quarter=1,2,3,4&ownercode=A05&sex=0&seasonadj=U&industry="+industry+"&key="+APIkey
            #https://api.census.gov/data/timeseries/qwi/se?get=Emp&for=county:*&in=state:02&year=2012&quarter=1&sex=0&seasonadj=U&industry=11&key=f16583b4f6b7fc3c176691eaf1c706df7982c51b
            f = urlopen(api)
            readf = f.read()
            filename = "fips"+ str(state) + "_ind" + industry + "_" + str(year) + ".txt"
            outf = open(filename, 'wb')
            outf.write(readf)
            outf.close()

            # outf = open(filename, 'w')
            # for row in readf:
            #     outf.write(row)
