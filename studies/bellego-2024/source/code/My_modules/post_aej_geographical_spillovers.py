import pandas as pd
import pdb
import pickle
import numpy as np
import csv
import json
import os


owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'
FilePS = os.listdir(path+'/preprocessed/spillovers')
if 'CrimeDP_without_UPP.csv' not in FilePS or 'pop_dp_no_upp.csv' not in FilePS or "Traitement_Numerateur_Spillovers.csv" not in  FilePS:
	#########################################################################################################################################
	#########################################################################################################################################
	# Compute crime in DP minus crime in UPP
	#########################################################################################################################################
	#########################################################################################################################################
	with open(path+'/intermediary/CensusTractEstado_do_Rio.json','r') as output:
		rioJSON = json.load(output)

	ListCensusTractUPP={}
	ListCensusTractDP={}
	for feature in rioJSON['features']:
		numero = int(feature['properties']['numero'])
		upp = feature['properties']['UPP']
		if upp not in ['N','DoUppMare_Holanda_Parque Uniao','DoUppMare_PraiadeRamos_RoquetePinto','DoUppMare_Vila do Joao_Pinheiros', 'DoUppMare_BaixadoSapateiro_Timbau']:
			if upp not in ListCensusTractUPP.keys():
				ListCensusTractUPP[upp]=[]
			ListCensusTractUPP[upp].append(numero)

		dp = feature['properties']['DP']
		if dp !='':
			if dp not in ListCensusTractDP.keys():
				ListCensusTractDP[dp]=[]
			ListCensusTractDP[dp].append(numero)


	ListCensusTract_in_upp=[]
	for upp in ListCensusTractUPP.keys():
		for num in ListCensusTractUPP[upp]:
			ListCensusTract_in_upp.append(num)

	ListCensusTractDP_NO_in_UPP={}
	ListCensusTractDP_in_UPP={}
	for dp in ListCensusTractDP.keys():
		ListCensusTractDP_NO_in_UPP[dp]=[]
		ListCensusTractDP_in_UPP[dp]=[]
		for num in ListCensusTractDP[dp]:
			if num in ListCensusTract_in_upp:
				ListCensusTractDP_in_UPP[dp].append(num)
			else:
				ListCensusTractDP_NO_in_UPP[dp].append(num)
				
	'''
	---
	'''
	ListCensusTractDP_NO_in_UPP["1 e 4"]=ListCensusTractDP_NO_in_UPP['1']+ListCensusTractDP_NO_in_UPP['4']
	del ListCensusTractDP_NO_in_UPP['1']
	del ListCensusTractDP_NO_in_UPP['4']
				
	ListCensusTractDP_in_UPP["1 e 4"]=ListCensusTractDP_in_UPP['1']+ListCensusTractDP_in_UPP['4']
	del ListCensusTractDP_in_UPP['1']
	del ListCensusTractDP_in_UPP['4']

	ListCensusTractDP["1 e 4"]=ListCensusTractDP['1']+ListCensusTractDP['4']
	del ListCensusTractDP['1']
	del ListCensusTractDP['4']
	'''
	---
	'''
	############# share upp in dp ################
	with open(path+'/intermediary/CensusTractMatrix','rb') as output:
		AAA=pickle.load(output)

	Population=AAA[0]
	mon_np=AAA[3]
	mon_np_pacification=AAA[4] # date of pacification - 127 if not pacified

	l0=mon_np.shape[0]
	np_pop=np.zeros((l0))
	num=0	
	while num<l0:
		pop=Population[num]	
		np_pop[num]=pop
		if np_pop[num]!=Population[num]:
			print('problem')
			pdb.set_trace()
		num=num+1


	ShareUPP_in_DP={}
	for dp in ListCensusTractDP.keys():
		ShareUPP_in_DP[dp]={}
		for upp in ListCensusTractUPP.keys():
			ShareUPP_in_DP[dp][upp]=0

	for upp in ListCensusTractUPP.keys():
		L0=set(ListCensusTractUPP[upp])
		pop_total_upp=np.take(np_pop,ListCensusTractUPP[upp]).sum()
		for dp in ListCensusTractDP.keys():
			S0=set(ListCensusTractDP_in_UPP[dp])						
			Pos = list(S0.intersection(L0))
			pop = np.take(np_pop,Pos).sum()
			proportion = round(pop/pop_total_upp,3)
			ShareUPP_in_DP[dp][upp]=proportion


	crimeUPP = pd.read_csv(path+'/preprocessed/UPP_Crime.csv',sep= ',',encoding='utf8')
	crimeDP = pd.read_csv(path+"/intermediary/DP_Crime.csv",sep= ',',encoding='utf8')
	crimeDP['dp']= crimeDP['dp'].astype(str)
	'''
	---
	merge 1 and 4: dp1 being very small
	'''
	DictMerge={}
	DictMerge['date']=range(1,115)
	MyDP=[]
	for r in range(1,115):
		MyDP.append('1 e 4')
	DictMerge['dp']=MyDP
	for crime in ['homicideintentional', 'bodyinjurydeathfollowed',
	'robberydeathfollowed', 'attemptedmurder', 'bodyinjuryintentional',
       'rape', 'homicidenointentional', 'bodyinjurynointentional',
       'deadbodyfound', 'bonesfound', 'storerobbery', 'homerobbery',
       'carrobbery', 'boatrobbery', 'passerbyrobbery', 'collectiverobbery',
       'bankrobbery', 'atmrobbery', 'mobilephonerobbery',
       'robberywithdrivingtotakeoutinatm', 'cartheft',
       'extortionwithkidnapping', 'extortion',
       'extortionwithmomentarykidnapping', 'fraud', 'drugarrest',
       'carrecovery', 'threat', 'persondisappearance',
       'resistancetodeathofpoliceopponent', 'deathofmilitarypolice',
       'deathofcivilpolice', 'totalrobbery', 'totaltheft',
       'eventsregistration']:
		arr1 = np.array(crimeDP[crimeDP['dp']=='1'][crime].tolist())
		arr4 = np.array(crimeDP[crimeDP['dp']=='4'][crime].tolist())
		arr_new =arr1+arr4
		DictMerge[crime]=arr_new
		
	dfnew = pd.DataFrame(DictMerge)	
	crimeDP=crimeDP.drop(crimeDP[crimeDP['dp'].isin(["1",'4'])].index)
	crimeDP=pd.concat([crimeDP,dfnew], axis=0, ignore_index=True)
	'''
	---
	'''

	Dict={}
	for var in ['dp', 'date', 'homicideintentional', 'bodyinjurydeathfollowed', 'robberydeathfollowed', 'attemptedmurder', 'bodyinjuryintentional', 'rape', 'homicidenointentional', 'bodyinjurynointentional', 'deadbodyfound', 'bonesfound', 'storerobbery', 'homerobbery', 'carrobbery', 'boatrobbery', 'passerbyrobbery', 'collectiverobbery', 'bankrobbery', 'atmrobbery', 'mobilephonerobbery', 'robberywithdrivingtotakeoutinatm', 'cartheft', 'extortionwithkidnapping', 'extortion', 'extortionwithmomentarykidnapping', 'fraud', 'drugarrest', 'carrecovery', 'threat', 'persondisappearance', 'resistancetodeathofpoliceopponent', 'deathofmilitarypolice', 'deathofcivilpolice', 'totalrobbery', 'totaltheft', 'eventsregistration']:
		Dict[var]=[]


	for dp in ShareUPP_in_DP.keys():
		#print(dp)
		for t in range(0,114):
			date=t+1
			Dict['dp'].append(dp)		
			Dict['date'].append(date)	


		crimeDP0 = crimeDP[crimeDP['dp']==dp]
		for var in ['homicideintentional', 'bodyinjurydeathfollowed', 'robberydeathfollowed', 'attemptedmurder', 'bodyinjuryintentional', 'rape', 'homicidenointentional', 'bodyinjurynointentional', 'deadbodyfound', 'bonesfound', 'storerobbery', 'homerobbery', 'carrobbery', 'boatrobbery', 'passerbyrobbery', 'collectiverobbery', 'bankrobbery', 'atmrobbery', 'mobilephonerobbery', 'robberywithdrivingtotakeoutinatm', 'cartheft', 'extortionwithkidnapping', 'extortion', 'extortionwithmomentarykidnapping', 'fraud', 'drugarrest', 'carrecovery', 'threat', 'persondisappearance', 'resistancetodeathofpoliceopponent', 'deathofmilitarypolice', 'deathofcivilpolice', 'totalrobbery', 'totaltheft', 'eventsregistration']:
			A=crimeDP0[var].values
			for upp in ShareUPP_in_DP[dp].keys():
				prop = ShareUPP_in_DP[dp][upp]
				if ShareUPP_in_DP[dp][upp]==0:
					1
				else:
					crimeUPP0=crimeUPP[crimeUPP['upp']==upp]
					B = crimeUPP0[var].values
					A = A - B*prop

			A=np.around(A,3)
			Dict[var]=Dict[var]+A.tolist()
					
	df = pd.DataFrame(Dict)
	df.to_csv(path+'/preprocessed/spillovers/CrimeDP_without_UPP.csv',sep=',',encoding='utf8',index = False)
	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################
	
	#########################################################################################################################################
	#########################################################################################################################################
	# Compute population in DP minus those in UPP
	#########################################################################################################################################
	#########################################################################################################################################				
	with open(path+'/intermediary/CensusTractMatrix','rb') as output:
		AAA=pickle.load(output)

	Population=AAA[0]

	'''
	---
	'''
	DPRio=["6","10","18","19","9","12","13","17","1 e 4","5","7","15 e 11","21","20","22 e 45","23","14","25","24","27","29","40","30","38","26","44","35","32","34","28","36","43","41","33","16 e 42","37","31","39"]
	'''
	---
	'''
	L_dp=[]
	L_pop=[]
	for dp in DPRio:
		population=0
		for num in ListCensusTractDP_NO_in_UPP[dp]:
			population=population+float(Population[num])
			
		#print(dp,population)
		L_dp.append(dp)
		L_pop.append(int(population))





	d1 = {'dp' :pd.Series(L_dp), 'pop':pd.Series(L_pop)}
	df1 = pd.DataFrame(d1)
	df1.to_csv(path+'/preprocessed/spillovers/pop_dp_no_upp.csv',sep=',',encoding='utf8',index = False)

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################
	# Create Denominator/Numerator used to compute DistrictPacif in subsection "spillovers outside pacified favelas"
	#########################################################################################################################################
	#########################################################################################################################################
	with open(path+'/intermediary/CensusTractPopPacified','rb') as output:
		AAA=pickle.load(output)

	np_pop_total=AAA[0]
	np_pop_total_pacified=AAA[1]
	del AAA

	with open(path+'/intermediary/CensusTractMatrix','rb') as output:
		AAA=pickle.load(output)

	Population=AAA[0]
	del AAA

	l0=np_pop_total.shape[0]
	np_pop=np.zeros((l0))
	num=0	
	while num<l0:
		pop=Population[num]	
		np_pop[num]=pop
		if np_pop[num]!=Population[num]:
			print('problem')
			pdb.set_trace()
		num=num+1
	del Population


	DP={}
	for dp in ListCensusTractDP.keys():
		DP[dp]={}
		Mu=np.zeros((l0))
		'''
		ListCensusTractDP_NO_in_UPP[dp] position of elements
		np.take(np_pop,ListCensusTractDP_NO_in_UPP[dp]) takes elements in np_pop taking into account their position indicated in ListCensusTractDP_NO_in_UPP[dp]
		'''
		pop0=np.take(np_pop,ListCensusTractDP_NO_in_UPP[dp]).sum() 
		for num in ListCensusTractDP_NO_in_UPP[dp]:
			Mu[num]=round(np_pop[num]/pop0,3)
		
		for dis in range(0,91):
			np_pop_total0=np_pop_total[:,dis]
			np_val=np_pop_total0*Mu
			val = np_val.sum()
			val=np.around(val,3)
			DP[dp][dis]=val



	DP_pacified={}
	for dp in ListCensusTractDP.keys():
		DP_pacified[dp]={}
		Mu=np.zeros((l0))
		'''
		ListCensusTractDP_NO_in_UPP[dp] position of elements
		np.take(np_pop,ListCensusTractDP_NO_in_UPP[dp]) takes elements in np_pop taking into account their position indicated in ListCensusTractDP_NO_in_UPP[dp]
		'''
		pop0=np.take(np_pop,ListCensusTractDP_NO_in_UPP[dp]).sum()
		for num in ListCensusTractDP_NO_in_UPP[dp]:
			Mu[num]=round(np_pop[num]/pop0,3)

		for t in range(0,114):
			date=t+1
			DP_pacified[dp][date]={}
			for dis in range(0,91):
				np_pop_total_pacified0=np_pop_total_pacified[:,dis,t]
				np_val=np_pop_total_pacified0*Mu
				val = np_val.sum()
				val=np.around(val,3)
				DP_pacified[dp][date][dis]=val


	############################################ Denominator ############################################
	Row=[]
	row = ['dp']
	for dis in range(0,91):
		d0=str(dis*100)
		d1=str((dis+1)*100)
		val = 'Denominateur_'+d0+'-'+d1
		row.append(val)
	Row.append(row)
	
	for dp in DP.keys():
		row=[dp]
		for dis in range(0,91):
			val=DP[dp][dis]
			row.append(val)

		Row.append(row)

	with open(path+"/preprocessed/spillovers/Traitement_Denominateur_Spillovers.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter= ',',lineterminator='\n')
		for row in Row:
			data.writerow(row)



	############################################ Numerator ############################################
	Row=[]
	row = ['dp','date']
	for dis in range(0,91):
		d0=str(dis*100)
		d1=str((dis+1)*100)
		val = 'Numerateur_'+d0+'-'+d1
		row.append(val)
	Row.append(row)


	for dp in DP.keys():
		for t in range(0,114):
			date=t+1
			row=[dp,date]
			for dis in range(0,91):
				val=DP_pacified[dp][date][dis]
				row.append(val)

			Row.append(row)

	with open(path+"/preprocessed/spillovers/Traitement_Numerateur_Spillovers.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter= ',',lineterminator='\n')
		for row in Row:
			data.writerow(row)



