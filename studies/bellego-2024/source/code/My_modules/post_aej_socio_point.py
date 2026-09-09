import csv
import pickle
import json
import os
import pdb

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileP=os.listdir(path+'/preprocessed')
if 'socio_favela_upp.csv' not in FileP:
	with open(path+'/intermediary/PointCensusTract','rb') as output:
		AAA=pickle.load(output)
		PointLotissement = AAA[0]
		Coordonnee = AAA[1]
		CoordonneePoint = AAA[2]
		del AAA

	with open(path+'/intermediary/PrefeituraRio.json') as gd:
		geo_data_Lotissement = json.load(gd) 

	with open(path+'/intermediary/Valeur','rb') as output:
		Valeur = pickle.load(output)


	Row = [['point','upp','favela','population','nbre_15_plus','domicile','rev_par_tete','personne_par_domicile','proportion_Proprietaire_Logement','proportion_Electricite','proportion_Eau_Potable','proportion_analphabete_15_plus']]
	for lot in PointLotissement.keys():
		for nb in PointLotissement[lot].keys():
			if PointLotissement[lot][nb]['City']=='RioDeJaneiro':
				favela = PointLotissement[lot][nb]['Favela']
				upp = PointLotissement[lot][nb]['UPP']
				population = Valeur[nb]['population']
				population15 = Valeur[nb]['nbre_15_plus']
				domicile = Valeur[nb]['domicile']
				if favela!='N':
					favela = 'yes'
				else:
					favela = 'no'

				'''
				DoUppMare_BaixadoSapateiro_Timbau, DoUppMare_PraiadeRamos_RoquetePinto, DoUppMare_Vila do Joao_Pinheiros and DoUppMare_Holanda_Parque Uniao
				UPPs of Mare -> not pacified
				'''				
				if upp in ['N','DoUppMare_BaixadoSapateiro_Timbau','DoUppMare_PraiadeRamos_RoquetePinto','DoUppMare_Vila do Joao_Pinheiros','DoUppMare_Holanda_Parque Uniao']:
					upp ='no'
				else:
					upp ='yes'

				if population==None:
					population=''
				else:
					population=str(population)

				if population15==None:
					population15=''
				else:
					population15=str(population15)

				if domicile==None:
					domicile=''
				else:
					domicile=str(domicile)

				row=[nb,upp,favela,population,population15,domicile]
				for cle in ['rev_par_tete', 'personne_par_domicile','proportion_Proprietaire_Logement','proportion_Electricite','proportion_Eau_Potable','proportion_analphabete_15_plus']:
					var = Valeur[nb][cle]
					if var == None:
						var = ''
					else:
						var = str(var)
					row.append(var)

				Row.append(row)

	with open(path+"/preprocessed/socio_favela_upp.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter=',',lineterminator= '\n')
		for row in Row:
			data.writerow(row)


