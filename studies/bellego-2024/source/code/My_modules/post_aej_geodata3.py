import pdb
import json
import pickle
import os


# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileI = os.listdir(path+'/intermediary')
if 'Valeur' not in FileI:
	with open(path+'/intermediary/PointCensusTract','rb') as output:
		AAA=pickle.load(output)
		PointCensusTract = AAA[0]
		Coordonnee = AAA[1]
		CoordonneePoint = AAA[2]
		del AAA

	with open(path+'/intermediary/PrefeituraRio.json') as gd:
		geo_data_CensusTract = json.load(gd) 


	DataPoint={}
	for feature_lot in geo_data_CensusTract['features']:
		lot = feature_lot['properties']['id']

		nb_total = len(PointCensusTract[lot].keys())

		pop_total = feature_lot['properties']['population']
		dom_total = feature_lot['properties']['domicile']

		area_total = feature_lot['properties']['area']

		if  feature_lot['properties']['rev_total_lotissement1']==0 or feature_lot['properties']['rev_total_lotissement0']!=feature_lot['properties']['rev_total_lotissement1'] or feature_lot['properties']['rev_total_lotissement0']==0 or feature_lot['properties']['rev_total_lotissement1']==None or feature_lot['properties']['rev_total_lotissement0']==None:
			rev_total = None
		elif feature_lot['properties']['rev_total_lotissement0']!=feature_lot['properties']['rev_total_lotissement1']:
			rev_total = None
		else:
			rev_total = feature_lot['properties']['rev_total_lotissement0']

		a0=feature_lot['properties']['nbre_15_29_moins']
		a1=feature_lot['properties']['nbre_30_64_moins']
		a2=feature_lot['properties']['nbre_65_plus']

		a3=feature_lot['properties']['nbre_10_14']
		a4=feature_lot['properties']['nbre_15_plus']

		a5=feature_lot['properties']['nbre_5_9']
		a6=feature_lot['properties']['nbre_0_4']


		densite = feature_lot['properties']['densite']

		for nb in PointCensusTract[lot].keys():
			DataPoint[nb]={}
			if area_total !=None:
				area = round(area_total/nb_total,5)
			else:
				area = None

			if densite!=None:
				dens = densite
			else:
				dens = None

			if pop_total!=None:
				pop = round(pop_total/nb_total,5)
			else:
				pop = None

			if dom_total!=None:
				dom = round(dom_total/nb_total,5)
			else:
				dom = None

			if rev_total == None:
				rev_par_dom = None
				rev_par_tete = None
			else:
				rev = rev_total/nb_total
				if pop != None and dom != None:
					rev_par_tete = round(rev/pop,5)
					rev_par_dom = round(rev/dom,5)
				else:
					rev_par_tete = None
					rev_par_dom = None

			if a0==None or a1==None or a2==None or a3==None or a4==None or a5==None or a6==None :
				nbre_15_29_moins = None
				nbre_30_64_moins = None
				nbre_65_plus = None
				nbre_10_14 = None
				nbre_15_plus = None
				nbre_5_9 = None
				nbre_0_4 = None

			else:
				try:
					nbre_15_29_moins = round(a0/nb_total,5)
					nbre_30_64_moins = round(a1/nb_total,5)
					nbre_65_plus = round(a2/nb_total,5)
					nbre_10_14 = round(a3/nb_total,5)
					nbre_15_plus = round(a4/nb_total,5)
					nbre_5_9 = round(a5/nb_total,5)
					nbre_0_4 = round(a6/nb_total,5)

			
				except:
					pdb.set_trace()

			DataPoint[nb]['population']=pop
			DataPoint[nb]['domicile']=dom

			DataPoint[nb]['densite']=dens
			DataPoint[nb]['area']=area


			DataPoint[nb]['rev_par_tete']=rev_par_tete
			DataPoint[nb]['rev_par_dom']=rev_par_dom

			DataPoint[nb]['personne_par_domicile']=feature_lot['properties']['personne_par_dom']

			DataPoint[nb]['proportion_domicile_moins_smic']=feature_lot['properties']['proportion_domicile_moins_smic']
			DataPoint[nb]['proportion_responsable_domicile_moins_smic']=feature_lot['properties']['proportion_responsable_moins_smic']
			if feature_lot['properties']['proportion_dix_fois_smic']==None:
				DataPoint[nb]['proportion_responsable_domicile_dix_fois_smic'] = feature_lot['properties']['proportion_dix_fois_smic']
			else:
				DataPoint[nb]['proportion_responsable_domicile_dix_fois_smic'] = round(feature_lot['properties']['proportion_dix_fois_smic']*100,2)

			DataPoint[nb]['proportion_Egout']=feature_lot['properties']['proportion_Egout']
			DataPoint[nb]['proportion_Electricite']=feature_lot['properties']['proportion_Electricite']
			DataPoint[nb]['proportion_Ordure']=feature_lot['properties']['proportion_Ordure']
			DataPoint[nb]['proportion_Eau_Potable']=feature_lot['properties']['proportion_Eau_Potable']


			DataPoint[nb]['proportion_Occupe_Logement']=feature_lot['properties']['proportion_Occupe_Logement']
			DataPoint[nb]['proportion_Autre_Propriete_Logement']=feature_lot['properties']['proportion_Autre_Propriete_Logement']
			DataPoint[nb]['proportion_Locataire_Logement']=feature_lot['properties']['proportion_Locataire_Logement']
			DataPoint[nb]['proportion_Proprietaire_Logement']=feature_lot['properties']['proportion_Proprietaire_Logement']

			DataPoint[nb]['proportion_analphabete_15_plus']=feature_lot['properties']['proportion_alphabete_15_plus']
			DataPoint[nb]['proportion_analphabete_10_14']=feature_lot['properties']['proportion_alphabete_10_14']

			DataPoint[nb]['nbre_15_29_moins']=nbre_15_29_moins
			DataPoint[nb]['nbre_30_64_moins']=nbre_30_64_moins
			DataPoint[nb]['nbre_65_plus']=nbre_65_plus
			DataPoint[nb]['nbre_10_14']=nbre_10_14
			DataPoint[nb]['nbre_5_9']=nbre_5_9
			DataPoint[nb]['nbre_0_4']=nbre_0_4
			DataPoint[nb]['nbre_15_plus']=nbre_15_plus


	
	with open(path+'/intermediary/Valeur','wb') as output:
		pickle.dump(DataPoint,output)

			

