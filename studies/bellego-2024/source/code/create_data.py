import importlib
import pdb
import os
import datetime
import zipfile

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'
FileD=os.listdir(path)
if 'intermediary' not in FileD:
	os.mkdir(path+'/intermediary')
if 'preprocessed' not in FileD:
	os.mkdir(path+'/preprocessed')
if 'processed' not in FileD:
	os.mkdir(path+'/processed')
if 'hospital' not in os.listdir(path+'/preprocessed/'):
	os.mkdir(path+'/preprocessed/hospital')
if 'spillovers' not in os.listdir(path+'/preprocessed/'):
	os.mkdir(path+'/preprocessed/spillovers')
if 'SIM' not in os.listdir(path+'/source/'):
	with zipfile.ZipFile(path+'/source/SIM.zip', 'r') as zip_ref:
	    zip_ref.extractall(path+'/source/')


Packages=['post_aej_geodata1','post_aej_geodata2','post_aej_geodata3','post_aej_socio_point','post_aej_crimeDP','post_aej_crimeUPP',
	'post_aej_dataUPP','post_aej_geographical_analysis','post_aej_geographical_spillovers','post_aej_datasus1','post_aej_datasus2']	
k=1
print('There are {} modules that take approximately 3.5 hours to run'.format(len(Packages)))
for prog in Packages:
	print('##############################################################')
	depart = datetime.datetime.now()
	print('run package {} - {} to {}'.format(prog,k,len(Packages)))
	importlib.import_module('My_modules.'+prog)
	fin = datetime.datetime.now()
	print(fin-depart)
	
	k=k+1

'''
##############################################################
run package post_aej_geodata1 - 1 to 11
0:00:53.902347
##############################################################
run package post_aej_geodata2 - 2 to 11
0:20:42.734580
##############################################################
run package post_aej_geodata3 - 3 to 11
0:00:08.896947
##############################################################
run package post_aej_socio_point - 4 to 11
0:00:05.305972
##############################################################
run package post_aej_crimeDP - 5 to 11
0:00:01.382278
##############################################################
run package post_aej_crimeUPP - 6 to 11
0:00:00.151934
##############################################################
run package post_aej_dataUPP - 7 to 11
0:10:58.452031
##############################################################
run package post_aej_geographical_analysis - 8 to 11
2:46:14.094915
##############################################################
run package post_aej_geographical_spillovers - 9 to 11
0:07:10.192671
##############################################################
run package post_aej_datasus1 - 10 to 11
0:00:02.123247
##############################################################
run package post_aej_datasus2 - 11 to 11
0:00:14.961888
'''

