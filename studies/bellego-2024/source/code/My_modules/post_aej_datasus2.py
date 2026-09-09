import pdb
import csv
import pandas as pd
import pickle
from geopy.distance import great_circle
import numpy as np
import copy
import os
import json

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'
FileH = os.listdir(path+'/preprocessed/hospital/')
if "Traitement_Numerateur_Hospital.csv" not in  FileH or "Traitement_Denominateur_Hospital.csv" not in FileH:

	df = pd.read_csv(path+'/preprocessed/hospital/agression.csv',sep=',')
	Set_Eta=[]
	for hop in set(df['hopital']):
		if df[df['hopital']==hop]['genre_tous'].sum()>=45:
			Set_Eta.append(hop)
			
	'''
	GPS returns coordinates of hospitals
	'''
	GPS = {'E2270056': [-22.810802053048, -43.1847963639613], 'E2269384': [-22.9277786002331, -43.2519419438532], 'E2273411': [-22.8655598707364, -43.3740212320696], 'E2270609': [-22.9952035793127, -43.364214585851], 'E2280183': [-22.9083019665408, -43.1896778167432], 'E6680704': [-22.8217739807342, -43.3686925959122], 'E2269880': [-22.8665530637303, -43.2488814279567], 'E2270234': [-22.838726265305, -43.2855129064073], 'E2758091': [-22.9127773115291, -43.6876752794019], 'E6995462': [-22.9128737907308, -43.6874982600975], 'E2273438': [-22.913409364818, -43.2037706700728], 'E2270269': [-22.9777155480781, -43.2235461489407], 'E2295407': [-22.9076798276107, -43.5626668231794], 'E2291266': [-22.8306649489465, -43.3278909095302], 'E2298120': [-22.8660578342374, -43.4419326671628], 'E2708345': [-22.86622639315963, -43.248010053143965], 'E2296306': [-22.9008988927292, -43.2782498938545]}

	
	with open(path+'/intermediary/CensusTractMatrix','rb') as output:
		AAA=pickle.load(output)
	'''
	mon_np_pacification returns pacification date of censustracts - 127 if not pacified
	'''
	mon_np_pacification=AAA[4]
	del AAA

	with open(path+'/intermediary/CensusTractEstado_do_Rio.json','r') as output:
		rioJSON = json.load(output)

	def cal_distance(var0):
		var=int(var0/100)
		if var<120:
			return var
		else:
			return -1

	np_pop=np.zeros((len(rioJSON['features']),)) # population in censustract
	mon_np=np.zeros((len(Set_Eta),len(rioJSON['features'])),dtype='int8')	# distance between hospital and censustract
	mon_np=np.where(mon_np==0,-2,mon_np)
	numero_eta=0
	test=0
	while numero_eta<len(Set_Eta):
		etablissement=Set_Eta[numero_eta]
		G0=GPS[etablissement]
		if test==0:
			for feature in rioJSON['features']:
				numero_lotissement = int(feature['properties']['numero'])
				lat = float(feature['properties']['centroid_lat-lon'][0])
				lon = float(feature['properties']['centroid_lat-lon'][1])
				G1=[lat,lon]

				dist = cal_distance(great_circle(G0,G1).meters)
				mon_np[numero_eta][numero_lotissement]=dist

				population = int(feature['properties']['Population'])
				np_pop[numero_lotissement]=population
				if np_pop[numero_lotissement]!=population:
					print('problem np_pop')	
					pdb.set_trace()
					
				test=1
		else:
			for feature in rioJSON['features']:
				numero_lotissement = int(feature['properties']['numero'])
				lat = float(feature['properties']['centroid_lat-lon'][0])
				lon = float(feature['properties']['centroid_lat-lon'][1])
				G1=[lat,lon]

				dist = cal_distance(great_circle(G0,G1).meters)
				mon_np[numero_eta][numero_lotissement]=dist
			

		numero_eta=numero_eta+1

	if mon_np.min()==-2 or np_pop.min()<1:
		print('problem size')
		pdb.set_trace()

	#########################################################################################################################################
	#########################################################################################################################################
	# Create Denominator/Numerator used to compute HospitalP acif in subsection "Victim profiles and murder weapons"
	#########################################################################################################################################
	#########################################################################################################################################

	
	################################ denominator ##################################
	Row=[]
	row0 = ['hopital']
	for dis in range(0,91):
		d0=str(dis*100)
		d1=str((dis+1)*100)
		val = 'Denominateur_'+d0+'-'+d1
		row0.append(val)
	Row.append(row0)

	numero_eta=0
	while numero_eta<len(Set_Eta):
		'''
		mon_np: matrix of distances between each hospital and each censustract 
		mon_np0 keep only the vector for the hospital numero_eta
		'''
		mon_np0=mon_np[numero_eta]
		etablissement=Set_Eta[numero_eta]
		row=[etablissement]

		for dis in range(0,91):
			'''
			np_pos returns position of censustracts that are at distance "dis" from hospital numero_eta
			'''
			np_pos=np.where(mon_np0 == dis)[0] 
			if np_pos.shape[0]==0:
				'''
				no census tract at distance dis
				'''
				pop0=0
				row.append(pop0)
			else:
				'''
				np.take(np_pop,np_pos) takes elements in np_pop according to their position in np_pos
				'''
				pop0=np.take(np_pop,np_pos).sum()
				row.append(pop0)
		
		if len(row)==len(row0):
			Row.append(row)
		else:
			print('len row')

		numero_eta=numero_eta+1


	with open(path+"/preprocessed/hospital/Traitement_Denominateur_Hospital.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter= ',',lineterminator='\n')
		for row in Row:
			data.writerow(row)
	

	################################ numerator ##################################
	Row=[]
	row0 = ['hopital','date']
	for dis in range(0,91):
		d0=str(dis*100)
		d1=str((dis+1)*100)
		val = 'Numerateur_'+d0+'-'+d1
		row0.append(val)
	Row.append(row0)

	numero_eta=0
	while numero_eta<len(Set_Eta):
		'''
		mon_np: matrix of distances between each hospital and each censustract 
		mon_np0 keep only the vector for the hospital numero_eta
		'''
		mon_np0=mon_np[numero_eta]
		etablissement=Set_Eta[numero_eta]
		for date in range(1,115):
			row=[etablissement,date]
			'''
			np_pos_pacifie returns positions of censustract that are pacified at date "date"
			''' 
			np_pos_pacifie=np.where(mon_np_pacification<=date)[0] 
			if np_pos_pacifie.shape[0]==0:
				for dis in range(0,91):
					pop0=0
					row.append(pop0)
			else:
				for dis in range(0,91):
					'''
					np_pos returns position of censustracts that are at distance "dis" from hospital numero_eta
					np_int returns position of censustracts that are at distance "dis" from hospital numero_eta and that are pacified
					'''
					np_pos=np.where(mon_np0 == dis)[0] 
					np_int=np.intersect1d(np_pos,np_pos_pacifie) 
					if np_int.shape[0]==0:
						pop0=0
						row.append(pop0)
					else:
						'''
						np.take(np_pop,np_pos) takes elements in np_pop according to their position in np_int
						'''
						pop0=np.take(np_pop,np_int).sum() 
						row.append(pop0)
			
			if len(row)==len(row0):
				Row.append(row)
			else:
				print('len row')

		numero_eta=numero_eta+1

		
	with open(path+'/preprocessed/hospital/Traitement_Numerateur_Hospital.csv', "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter= ',',lineterminator='\n')
		for row in Row:
			data.writerow(row)


