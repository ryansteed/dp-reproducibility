import re
import pdb
import csv
import numpy as np
import os

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

def N(h):
	iden = 'E'+h.split(' ')[0]
	return iden


Equiv={}
d=1
for year in range(2007,2017):
	for month in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
		Equiv[(year,month)]=d
		d=d+1

Categorie=['moins_de_1an', '35_39ans', '60_64ans', 'blanc', '5_9ans', 'genre_inconnu', 'race_tous', 'race_inconnu', '10_14ans', '70_74ans', '40_44ans', '45_49ans', 'age_inconnu', 'race_pas_renseigne', '20_24ans', 'indigene', 'age_tous', '1_4ans', '75_79ans', 'genre_tous', '15_19ans', '55_59ans', '50_54ans', 'metisse', '65_69ans', 'femme', '80ans_plus', 'asiatique', 'noir', '25_29ans', 'homme', '30_34ans']


ListHospital=[]
for type_ag in ['agression','agression_arme_feu','agression_couteau']:
	FichierAll=os.listdir(path+'/source/SIM/'+type_ag+'/TEX')
	for fichier in FichierAll:
		with open(path+'/source/SIM/'+type_ag+'/TEX/'+fichier,'r',encoding='utf8') as output:
			contenu=output.read()

		patternTotal='<TD align="left"> TOTAL\n'
		pattern = '<TD ALIGN=LEFT>(.{1,60})\n'
		MM=[]
		for m in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
			if 'cabmeio">'+m in contenu:
				MM.append(m)
		for i in range(0,len(MM)):
			patternTotal=patternTotal+'<TD>(.{1,7})'
			pattern=pattern+'<TD>(.{1,7})'
		patternTotal=patternTotal+'<TD>(.{1,7})\n'
		pattern=pattern+'<TD>(.{1,7})\n'
		resultTotal = re.findall(patternTotal,contenu)
		result=re.findall(pattern,contenu)
		if len(resultTotal)!=0:
			for r in result:
				hop = r[0]
				if hop not in ListHospital:
					ListHospital.append(hop)
					
for type_ag in ['agression','agression_arme_feu','agression_couteau']:
	Base={}
	for hop in ListHospital:
		Base[hop]={}
		for year in range(2007,2017):
			Base[hop][year]={}
			for month in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
				Base[hop][year][month]={}
				for categorie in Categorie:
					Base[hop][year][month][categorie]=0

	FichierAll=os.listdir(path+'/source/SIM/'+type_ag+'/TEX')
	for fichier in FichierAll:
		with open(path+'/source/SIM/'+type_ag+'/TEX/'+fichier,'r',encoding='utf8') as output:
			contenu=output.read()
		
		# get category - month - year 
		fichier = fichier.replace('.tex','')
		Fichier = fichier.split('_')
		l = len(Fichier)
		year = Fichier[l-2]
		year = '20'+year
		year = int(year)
		categorie = '_'.join(Fichier[0:l-2])

		# get total number of occurences
		MM=[]
		for m in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
			if 'cabmeio">'+m in contenu:
				MM.append(m)
		
		patternTotal='<TD align="left"> TOTAL\n'
		pattern = '<TD ALIGN=LEFT>(.{1,60})\n'
		for i in range(0,len(MM)):
			patternTotal=patternTotal+'<TD>(.{1,7})'
			pattern=pattern+'<TD>(.{1,7})'
		patternTotal=patternTotal+'<TD>(.{1,7})\n'
		pattern=pattern+'<TD>(.{1,7})\n'
		resultTotal = re.findall(patternTotal,contenu)
		result=re.findall(pattern,contenu)
		if len(resultTotal)==0:
			if '<H2>Nenhum registro selecionado</H2>' in contenu or ".df Arquivo não encontrado!" in contenu:
				pass
			else:
				print('problem contenu 0')
				pdb.set_trace()
			
		else:
			if len(resultTotal[0])!=len(MM)+1:
				print('problem contenu 1')

			patternMOIS='TH CLASS="cabmeio">(.{1,20})\n'
			RM=re.findall(patternMOIS,contenu)
			if len(RM)!=len(MM):
				print('problem RM 0')
			
			for r in result:
				if len(RM)+2!=len(r):
					print('problem RM 1')
					pdb.set_trace()
			RMbis=['']+RM
			for r in result:
				hop = r[0]
				Val=[]
				for month in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
					if month in RMbis:
						pos = RMbis.index(month)
						val = r[pos]
						if val == '-':
							val = 0
						else:
							val = int(val)
						if Base[hop][year][month][categorie]!=0:
							print(hop,'problem base')
							pdb.set_trace()		
						Base[hop][year][month][categorie]=val			

						Val.append(val)
				val_total=r[-1]
				
				if val_total=='-':
					val_total=0
				else:
					val_total=int(val_total)

				if np.array(Val).sum()!=val_total:
					print('problem val_total')
					pdb.set_trace()




	VAR = ['race_tous','blanc','noir','asiatique','metisse','indigene','race_pas_renseigne','race_inconnu'
	,'genre_tous','homme','femme','genre_inconnu'
	,"age_tous","moins_de_1an","1_4ans","5_9ans","10_14ans","15_19ans","20_24ans","25_29ans","30_34ans","35_39ans","40_44ans","45_49ans","50_54ans","55_59ans","60_64ans","65_69ans","70_74ans","75_79ans","80ans_plus","age_inconnu"]


	Row=[['hopital','annee','mois','date']+VAR]
	for hop in Base.keys():
		iden_hop=N(hop)
		for year in range(2007,2016):
			for month in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho', 'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro']:
				row=[iden_hop,year,month,Equiv[(year,month)]]
				for categorie in VAR:
					row.append(Base[hop][year][month][categorie])
				Row.append(row)


		for year in range(2016,2017):
			for month in ['Janeiro', 'Fevereiro','Marco','Abril','Maio', 'Junho']:
				row=[iden_hop,year,month,Equiv[(year,month)]]
				for categorie in VAR:
					row.append(Base[hop][year][month][categorie])
				Row.append(row)
						
	with open(path+'/preprocessed/hospital/'+type_ag+".csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter= ',' ,lineterminator= '\n' )
		for row in Row:
			data.writerow(row)



