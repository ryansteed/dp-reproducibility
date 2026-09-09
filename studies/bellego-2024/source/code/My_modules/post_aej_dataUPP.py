import csv
import pdb
import pickle
import math
import os
import json
import re
import numpy as np
import linecache
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileP = os.listdir(path+'/preprocessed')
if 'UPP_Data.csv' not in FileP:
	with open(path+'/intermediary/PointCensusTract','rb') as output:
		AAA=pickle.load(output)
		PointCensusTract = AAA[0]
		Coordonnee = AAA[1]
		CoordonneePoint = AAA[2]
		del AAA

	with open(path+'/intermediary/Valeur','rb') as output:
		Valeur=pickle.load(output)

	'''
	Calendar date of bope & date of upp inauguration come from ISP. See "UPP: datas de ocupação, instalação e extinção" at http://www.ispdados.rj.gov.br/UPP.html
	Number of police officers in upp comes from http://www.upprj.com/ -> This information is not anymore available, but can be found in the Internet Archive at http://web.archive.org/web/20170814095808/http://www.upprj.com/index.php/informacao/informacao-interna
	Date of bope and date of upp inauguration have been recoded from 1 to 114 with 1=1/2007; 2=2/2007;...; 114=6/2016
	'''
	Date={}
	# [city,name of complexo,calendar date of bope,calendar date of upp inauguration,date of bope from 1 to 114, date of upp inauguration from 1 to 114,number of police officers]
	Date["DoUppSantaMarta"]= ['Rio de Janeiro', '', '19/11/08', '19/12/08', '24', '25', '123']
	Date["DoUppBatan"]= ['Rio de Janeiro', '', '12/07/08', '18/02/09', '19', '27', '107']
	Date["DoUppCdd"]= ['Rio de Janeiro', '', '11/11/08', '16/02/09', '23', '27', '343']
	Date["DoUppChapeuMangueiraEBabilonia"]= ['Rio de Janeiro', '', '11/05/09', '10/06/09', '29', '30', '107']
	Date["DoUppPavaoPavaozinho"]= ['Rio de Janeiro', '', '30/11/09', '23/12/09', '36', '37', '189']
	Date["DoUppTabajaras"]= ['Rio de Janeiro', '', '26/12/09', '14/01/10', '37', '37', '144']
	Date["DoUppProvidencia"]= ['Rio de Janeiro', '', '22/03/10', '26/04/10', '40', '41', '209']
	Date["DoUppBorel"]= ['Rio de Janeiro', '', '28/04/10', '07/06/10', '41', '42', '287']
	Date["DoUppAndarai"]= ['Rio de Janeiro', '', '11/06/10', '28/07/10', '42', '44', '219']
	Date["DoUppFormiga"]= ['Rio de Janeiro', '', '28/04/10', '01/07/10', '41', '43', '111']
	Date["DoUppSalgueiro"]= ['Rio de Janeiro', '', '30/07/10', '17/09/10', '44', '46', '140']
	Date["DoUppTurano"]= ['Rio de Janeiro', '', '10/08/10', '30/10/10', '44', '47', '173']
	Date["DoUppMacacos"]= ['Rio de Janeiro', '', '14/10/10', '30/11/10', '46', '48', '221']
	Date["DoUppSaoJoaoQuietoMatriz"]= ['Rio de Janeiro', '', '06/01/11', '31/01/11', '49', '50', '208']
	Date["DoUppCoroaFalletFogueteiro"]= ['Rio de Janeiro', '', '06/01/11', '25/02/11', '49', '51', '193']
	Date["DoUppEscondidinhoEPrazeres"]= ['Rio de Janeiro', '', '06/01/11', '25/02/11', '49', '51', '182']
	Date["DoUppMangueira"]= ['Rio de Janeiro', '', '19/06/11', '03/11/11', '55', '59', '332']
	Date["DoUppSaoCarlos"]= ['Rio de Janeiro', '', '06/01/11', '17/05/11', '49', '54', '244']
	Date["DoUppVidigal"]= ['Rio de Janeiro', '', '13/12/11', '18/01/12', '60', '62', '246']
	Date["DoUppFazendinha"]= ['Rio de Janeiro', 'Alemao', '28/11/10', '18/04/12', '48', '65', '314']
	Date["DoUppNovaBrasilia"]= ['Rio de Janeiro', 'Alemao', '28/11/10', '18/04/12', '48', '65', '340']
	Date["DoUppAdeusBaiana"]= ['Rio de Janeiro', 'Alemao', '28/11/10', '11/05/12', '48', '65', '245']
	Date["DoUppAlemao"]= ['Rio de Janeiro', 'Alemao', '28/11/10', '30/05/12', '48', '66', '320']
	Date["DoUppChatuba"]= ['Rio de Janeiro', 'Penha', '27/06/12', '27/06/12', '67', '67', '230']
	Date["DoUppFeSereno"]= ['Rio de Janeiro', 'Penha', '27/06/12', '27/06/12', '67', '67', '170']
	Date["DoUppParqueProletario"]= ['Rio de Janeiro', 'Penha', '28/11/10', '28/08/12', '48', '69', '220']
	Date["DoUppVilaCruzeiro"]= ['Rio de Janeiro', 'Penha', '28/11/10', '28/08/12', '48', '69', '300']
	Date["DoUppRocinha"]= ['Rio de Janeiro', '', '13/12/11', '20/09/12', '60', '70', '700']
	Date["DoUppJacarezinho"]= ['Rio de Janeiro', '', '14/10/12', '16/01/13', '70', '74', '543']
	Date["DoUppManguinhos"]= ['Rio de Janeiro', 'Manguinhos', '14/10/12', '16/01/13', '70', '74', '588']
	Date["DoUppAraraMandela"]= ['Rio de Janeiro', 'Manguinhos', '13/10/12', '06/09/13', '70', '81', '273']
	Date["DoUppBarreiraVascoTuiuti"]= ['Rio de Janeiro', '', '03/03/13', '12/04/13', '75', '76', '150']
	Date["DoUppCaju"]= ['Rio de Janeiro', '', '03/03/13', '12/04/13', '75', '76', '350']
	Date["DoUppCerroCora"]= ['Rio de Janeiro', '', '29/04/13', '03/06/13', '77', '78', '232']
	Date["DoUppCamaristaMeier"]= ['Rio de Janeiro', 'Lins', '06/10/13', '02/12/13', '82', '84', '230']
	Date["DoUppLins"]= ['Rio de Janeiro', 'Lins', '06/10/13', '02/12/13', '82', '84', '250']
	Date["DoUppVilaKennedy"]= ['Rio de Janeiro', '', '13/03/14', '23/05/14', '87', '90', '250']
	Date["DoUppMangueirinha"]= ['Duque de Caxias', '', '05/08/13', '07/02/14', '80', '86', '220']
	Date["DoUppMare"]= ['Rio de Janeiro', 'Mare', '30/03/14', 'not pacified', '88', 'not pacified', '']


	'''
	GANG	
	Information comes from several sources: Mapa do Ocupação Territorial Armada no Rio, favelascariocas.blogspot.com, InSight Crime, RioOnWatch, O Globo, Folha de S.Paulo.
	'''
	Gang={}
	Gang["DoUppSantaMarta"]="CV"
	Gang["DoUppBatan"]="contested"
	Gang["DoUppCdd"]="CV"
	Gang["DoUppChapeuMangueiraEBabilonia"]="contested"
	Gang["DoUppPavaoPavaozinho"]="CV"
	Gang["DoUppTabajaras"]="CV"
	Gang["DoUppProvidencia"]="CV"
	Gang["DoUppBorel"]="contested"
	Gang["DoUppAndarai"]="CV"
	Gang["DoUppFormiga"]="CV"
	Gang["DoUppSalgueiro"]="CV"
	Gang["DoUppTurano"]="CV"
	Gang["DoUppMacacos"]="ADA"
	Gang["DoUppSaoJoaoQuietoMatriz"]="CV"
	Gang["DoUppCoroaFalletFogueteiro"]="contested"
	Gang["DoUppEscondidinhoEPrazeres"]="CV"
	Gang["DoUppMangueira"]="CV"
	Gang["DoUppSaoCarlos"]="ADA"
	Gang["DoUppVidigal"]="ADA"
	Gang["DoUppFazendinha"]="CV HQ"
	Gang["DoUppNovaBrasilia"]="CV HQ"
	Gang["DoUppAdeusBaiana"]="CV HQ"
	Gang["DoUppAlemao"]="CV HQ"
	Gang["DoUppChatuba"]="CV HQ"
	Gang["DoUppFeSereno"]="CV HQ"
	Gang["DoUppParqueProletario"]="CV HQ"
	Gang["DoUppVilaCruzeiro"]="CV HQ"
	Gang["DoUppRocinha"]="ADA"
	Gang["DoUppJacarezinho"]="CV"
	Gang["DoUppManguinhos"]="CV"
	Gang["DoUppAraraMandela"]="CV"
	Gang["DoUppBarreiraVascoTuiuti"]="CV"
	Gang["DoUppCaju"]="ADA"
	Gang["DoUppCerroCora"]="CV"
	Gang["DoUppCamaristaMeier"]="CV"
	Gang["DoUppLins"]="CV"
	Gang["DoUppVilaKennedy"]="CV"
	Gang["DoUppMangueirinha"]="CV"
	Gang["DoUppMare"]="contested"
	
	'''
	ZonaSud
	1 if UPP is in Zona Sul of Rio de Janeiro, 0 otherwise
	'''
	ZonaSud = {'DoUppAndarai': 0, 'DoUppSalgueiro': 0, 'DoUppTurano': 0, 'DoUppMacacos': 0, 'DoUppSaoJoaoQuietoMatriz': 0, 'DoUppCoroaFalletFogueteiro': 0, 'DoUppEscondidinhoEPrazeres': 0, 'DoUppSaoCarlos': 0, 'DoUppMangueira': 0, 'DoUppVidigal': 1, 'DoUppSantaMarta': 1, 'DoUppFazendinha': 0, 'DoUppNovaBrasilia': 0, 'DoUppAdeusBaiana': 0, 'DoUppAlemao': 0, 'DoUppFeSereno': 0, 'DoUppChatuba': 0, 'DoUppParqueProletario': 0, 'DoUppVilaCruzeiro': 0, 'DoUppRocinha': 1, 'DoUppManguinhos': 0, 'DoUppCdd': 0, 'DoUppJacarezinho': 0, 'DoUppCaju': 0, 'DoUppBarreiraVascoTuiuti': 0, 'DoUppCerroCora': 0, 'DoUppAraraMandela': 0, 'DoUppLins': 0, 'DoUppCamaristaMeier': 0, 'DoUppMangueirinha': 0, 'DoUppVilaKennedy': 0, 'DoUppBatan': 0, 'DoUppChapeuMangueiraEBabilonia': 1, 'DoUppPavaoPavaozinho': 1, 'DoUppTabajaras': 1, 'DoUppProvidencia': 1, 'DoUppBorel': 0, 'DoUppFormiga': 0, 'DoUppMare': 0}

	'''
	Altitude
	[mean,std,max,min]
	'''
	with open(path+'/intermediary/UPPEstado_do_RioFinal.json','r') as output:
		geo_data_UPP=json.load(output)

	# https://srtm.csi.cgiar.org/srtmdata/
	base=path+'/source/STRM/srtm_28_17.asc'
	myArray0 = np.loadtxt(base, skiprows=6)
	line1 = linecache.getline(base, 1)
	line2 = linecache.getline(base, 2)
	line3 = linecache.getline(base, 3)
	line4 = linecache.getline(base, 4)
	line5 = linecache.getline(base, 5)
	line6 = linecache.getline(base, 6)


	result=re.findall('ncols(.{1,20})\n',line1)
	ncols=int(result[0])

	result=re.findall('nrows(.{1,20})\n',line2)
	nrows=int(result[0])

	result=re.findall('xllcorner(.{1,30})\n',line3)
	xllcorner=float(result[0])

	result=re.findall('yllcorner(.{1,30})\n',line4)
	yllcorner=float(result[0])

	result=re.findall('cellsize(.{1,30})\n',line5)
	cellsize=float(result[0])


	result=re.findall('NODATA_value(.{1,20})\n',line6)
	missing_value=int(result[0])
	if missing_value!=-9999:
		print('problem missing value')


	Dict={}
	Lat=[]
	Lon=[]
	for x in range(0,ncols):
		lon =  round(xllcorner+x*cellsize,3)
		if lon>-43.92 and lon<-42.92:
			for y in range(0,nrows):
				lat =  round(yllcorner+y*cellsize,3)
				if lat>-23.24 and lat<-22.44 :
					Dict[(lat,lon)]=myArray0[(nrows-1)-y][x]
					Lat.append(lat)
					Lon.append(lon)



	def f_get_polygone(F):
		result=[]
		if F['geometry']['type']=='Polygon':
			P=F['geometry']['coordinates'][0]
			lenF=len(F['geometry']['coordinates'])
			Trou={}	
			if lenF>1:
				for n in range(1,lenF):
					Trou[n]=F['geometry']['coordinates'][n]

			result.append((P,Trou))


		elif F['geometry']['type']=='MultiPolygon':
			nombre_polygone=len(F['geometry']['coordinates'])
			for p in range(0,nombre_polygone):
				P=F['geometry']['coordinates'][p][0]
				lenF=len(F['geometry']['coordinates'][p])
				Trou={}
				if lenF>1:
					for n in range(1,lenF):
						Trou[n]=F['geometry']['coordinates'][p][n]

				result.append((P,Trou))

		return result

	BaseF={}
	for coord in Dict.keys():
		lon = coord[1]
		lat = coord[0]
		point= Point(lon,lat)
		for ll in range(0,len(geo_data_UPP['features'])):
			feature_upp =  geo_data_UPP['features'][ll]
			R=f_get_polygone(feature_upp)
			Inside = False
			for P in R:
				f0=Polygon(P[0])
				Trou=[]
				DictTest=P[1]
				for k in DictTest.keys():
					Trou.append(Polygon(DictTest[k]))

				if f0.contains(point):
					if Trou==[]:
						Inside = 'yes'

					else:
						test=0
						for polygone_trou in Trou:
							if polygone_trou.contains(point):
								test=test+1
						if test==0:
							Inside = 'yes'

				if Inside == 'yes':
					break

			if Inside == 'yes':
				nom_upp = feature_upp['properties']['UPP']
				if nom_upp not in BaseF.keys():
					BaseF[nom_upp]=[]
				BaseF[nom_upp].append(Dict[coord])
				break

	Altitude={}	
	for upp in BaseF.keys():
		my_array = np.array(BaseF[upp])
		Altitude[upp]=[round(my_array.mean(),4),round(my_array.std(),4),my_array.max(),my_array.min()]
	Altitude['DoUppMare']=['','','','']
	Altitude['DoUppMangueirinha']=['','','','']
	'''
	We aggregate 'DoUppMare_BaixadoSapateiro_Timbau','DoUppMare_PraiadeRamos_RoquetePinto','DoUppMare_Holanda_Parque Uniao','DoUppMare_Vila do Joao_Pinheiros' as 'DoUppMare'
	Those favelas are in complexo do Mare and have not been pacified
	'''
	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			upp = PointCensusTract[lot][nb]['UPP']
			if upp!='N':
				if upp in ['DoUppMare_BaixadoSapateiro_Timbau','DoUppMare_PraiadeRamos_RoquetePinto','DoUppMare_Holanda_Parque Uniao','DoUppMare_Vila do Joao_Pinheiros']:
					PointCensusTract[lot][nb]['UPP'] = 'DoUppMare'


	'''
	Compute indicators socio-eco for each upp
	'''
	ListUPP = ["DoUppSantaMarta","DoUppBatan","DoUppCdd","DoUppChapeuMangueiraEBabilonia","DoUppPavaoPavaozinho",
			"DoUppTabajaras","DoUppProvidencia","DoUppBorel","DoUppAndarai","DoUppFormiga","DoUppSalgueiro",
			"DoUppTurano","DoUppMacacos","DoUppSaoJoaoQuietoMatriz","DoUppCoroaFalletFogueteiro","DoUppEscondidinhoEPrazeres",
			"DoUppMangueira","DoUppSaoCarlos","DoUppVidigal","DoUppFazendinha","DoUppNovaBrasilia","DoUppAdeusBaiana","DoUppAlemao",
			"DoUppChatuba","DoUppFeSereno","DoUppParqueProletario","DoUppVilaCruzeiro","DoUppRocinha","DoUppJacarezinho","DoUppManguinhos",
			"DoUppAraraMandela","DoUppBarreiraVascoTuiuti","DoUppCaju","DoUppCerroCora","DoUppCamaristaMeier","DoUppLins","DoUppVilaKennedy",
			"DoUppMangueirinha","DoUppMare"]
			
			


	Base={}
	for upp in ListUPP:
		if upp == "DoUppMangueirinha": # outside the city of rio de janeiro
			Base[upp]=Date[upp]+[Gang[upp]]+[ZonaSud[upp]]+Altitude[upp]+['',21415,'','','','','','','','','','','','','','','','','','','','','','']

			
		else:

			A={}
			F=[]
			N=[]
			for lot in PointCensusTract.keys():
				for nb in PointCensusTract[lot].keys():
					if PointCensusTract[lot][nb]['UPP']==upp:
						A[nb]=Valeur[nb]
						if PointCensusTract[lot][nb]['Favela']!='N':
							F.append(nb)
							N.append(PointCensusTract[lot][nb]['Favela'])

			# number of favelas
			nbre_favela = len(set(N))

			# population
			population = 0
			population_favela = 0
			for nb in A.keys():
				if A[nb]['population']!=None:
					population = population + A[nb]['population']
					if nb in F:
						population_favela = population_favela + A[nb]['population']
				

		
			part_population_favela = round((population_favela/population)*100,2)
			population = int(round(population,0))

			# density 
			ddd = 0
			bbb = 0
			for nb in A.keys():
				if A[nb]['densite']!=None and A[nb]['population']!=None:
					ddd = ddd + A[nb]['population']*A[nb]['densite']
					bbb = bbb + A[nb]['population']
					

			
			densite = round(ddd/bbb,2)


			# number of people in household
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['population']!=None:
					n = n + A[nb]['population']
					d = d +A[nb]['domicile']

			pers_par_dom = round(n/d,2)

			# income per capita
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['population']!=None and A[nb]['rev_par_tete']!=None:
					n = n + A[nb]['population']*A[nb]['rev_par_tete']
					d = d +A[nb]['population']

			revenu_tete = round(n/d,2)


			# income household
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['rev_par_dom']!=None:
					n = n + A[nb]['domicile']*A[nb]['rev_par_dom']
					d = d +A[nb]['domicile']

			revenu_dom = round(n/d,2)
			if math.fabs(revenu_dom -(revenu_tete*pers_par_dom))>5:
				print('problem revenu_dom')
				pdb.set_trace()
			else:
				revenu_dom = round(revenu_tete*pers_par_dom,2)
		
			# household with less than minimum salary
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['proportion_domicile_moins_smic']!=None:
					n = n + A[nb]['domicile']*A[nb]['proportion_domicile_moins_smic']
					d = d +A[nb]['domicile']

			proportion_domicile_moins_smic = round(n/d,2)


			# head of the family with less than minimum salary
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['proportion_responsable_domicile_moins_smic']!=None:
					n = n + A[nb]['domicile']*A[nb]['proportion_responsable_domicile_moins_smic']
					d = d +A[nb]['domicile']

			proportion_responsable_moins_smic = round(n/d,2)

			# head of the family with 10 times (or more) minimum salary
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['proportion_responsable_domicile_dix_fois_smic']!=None:
					n = n + A[nb]['domicile']*A[nb]['proportion_responsable_domicile_dix_fois_smic']
					d = d +A[nb]['domicile']

			proportion_responsable_dix_fois_smic = round(n/d,2)


			# owners vs tenant
			n0 = 0
			n1 = 0
			n2 = 0
			n3 = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['proportion_Autre_Propriete_Logement']!=None and A[nb]['proportion_Proprietaire_Logement']!=None and A[nb]['proportion_Locataire_Logement']!=None and A[nb]['proportion_Occupe_Logement']!=None:
					n0 = n0 + A[nb]['proportion_Autre_Propriete_Logement']*A[nb]['domicile']
					n1 = n1 + A[nb]['proportion_Proprietaire_Logement']*A[nb]['domicile']
					n2 = n2 + A[nb]['proportion_Locataire_Logement']*A[nb]['domicile']
					n3 = n3 + A[nb]['proportion_Occupe_Logement']*A[nb]['domicile']
					d = d + A[nb]['domicile']

			logement_autre = round(n0/d,2)
			logement_proprietaire = round(n1/d,2) 
			logement_locataire = round(n2/d,2) 
			logement_occupe = round(n3/d,2)


			# Infrastructure
			n0 = 0
			n1 = 0
			n2 = 0
			n3 = 0
			d = 0
			for nb in A.keys():
				if A[nb]['domicile']!=None and A[nb]['proportion_Electricite']!=None and A[nb]['proportion_Eau_Potable']!=None and A[nb]['proportion_Egout']!=None and A[nb]['proportion_Ordure']!=None:
					n0 = n0 + A[nb]['proportion_Electricite']*A[nb]['domicile']
					n1 = n1 + A[nb]['proportion_Eau_Potable']*A[nb]['domicile']
					n2 = n2 + A[nb]['proportion_Egout']*A[nb]['domicile']
					n3 = n3 + A[nb]['proportion_Ordure']*A[nb]['domicile']
					d = d +A[nb]['domicile']

			electricite = round(n0/d,2)
			eau_potable = round(n1/d,2) 
			egout = round(n2/d,2) 
			ordure = round(n3/d,2)


			# illiterate
			n0 = 0
			n1 = 0
			d0 = 0
			d1 = 0
			for nb in A.keys():
				if A[nb]['proportion_analphabete_15_plus']!=None and A[nb]['nbre_15_plus']!=None and A[nb]['proportion_analphabete_10_14']!=None and A[nb]['nbre_10_14']!=None :
					n0 = n0 + A[nb]['proportion_analphabete_15_plus']*A[nb]['nbre_15_plus']
					n1 = n1 + A[nb]['proportion_analphabete_10_14']*A[nb]['nbre_10_14']
					d0 = d0 +A[nb]['nbre_15_plus']
					d1 = d1 +A[nb]['nbre_10_14']

			proportion_analphabete_15_plus = round(n0/d0,2)
			proportion_analphabete_10_14 = round(n1/d1,2) 


			# proportion people between 15-29 years old
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['nbre_15_29_moins']!=None and A[nb]['population']!=None:
					n = n + A[nb]['nbre_15_29_moins']
					d = d +A[nb]['population']


			proportion_15_29 = round(n/d*100,2)

			# proportion people between 10-29 years old
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['nbre_15_29_moins']!=None and A[nb]['nbre_10_14']!=None and A[nb]['population']!=None:
					n = n + A[nb]['nbre_15_29_moins'] + A[nb]['nbre_10_14']
					d = d +A[nb]['population']

			proportion_10_29 = round(n/d*100,2)

			# proportion people between 5-29 years old
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['nbre_15_29_moins']!=None and A[nb]['nbre_10_14']!=None and A[nb]['nbre_5_9']!=None and A[nb]['population']!=None:
					n = n + A[nb]['nbre_15_29_moins'] + A[nb]['nbre_10_14'] + A[nb]['nbre_5_9']
					d = d +A[nb]['population']

			proportion_5_29 = round(n/d*100,2)

			# proportion people between 0-29 years old
			n = 0
			d = 0
			for nb in A.keys():
				if A[nb]['nbre_15_29_moins']!=None and A[nb]['nbre_10_14']!=None and A[nb]['nbre_5_9']!=None and A[nb]['nbre_0_4']!=None and A[nb]['population']!=None:
					n = n + A[nb]['nbre_15_29_moins'] + A[nb]['nbre_10_14'] + A[nb]['nbre_5_9']+A[nb]['nbre_0_4']
					d = d +A[nb]['population']

			proportion_0_29 = round(n/d*100,2)

			Base[upp]=Date[upp]+[Gang[upp]]+[ZonaSud[upp]]+Altitude[upp]+[nbre_favela,population,densite,part_population_favela,pers_par_dom,revenu_tete,revenu_dom,proportion_domicile_moins_smic,proportion_responsable_moins_smic,proportion_responsable_dix_fois_smic,logement_proprietaire,logement_locataire,logement_occupe,logement_autre,electricite,eau_potable,egout,ordure,proportion_analphabete_15_plus,proportion_analphabete_10_14,proportion_15_29,proportion_10_29,proportion_5_29,proportion_0_29]

	'''
	Save data as dataUPP.csv
	'''
	with open(path+"/preprocessed/UPP_Data.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter=',',lineterminator='\n')
		Variable = ['UPP','City','Complexo','date_Bope', 'date_upp', 'bope', 'pacified', 'effpolice','Gang','ZonaSud',"mean_altitude","std_altitude","max_altitude","min_altitude",'nbre de favela','population',
				'densite','proportion_population_favela','personne_par_domicile','revenu_tete',
				'revenu_domicile','proportion_domicile_moins_smic','proportion_responsable_domicile_moins_smic',
				'proportion_responsable_domicile_dix_fois_smic','proportion_logement_proprietaire','proportion_logement_locataire',
				'proportion_logement_occupe','proportion_logement_autre','proportion_electricite','proportion_eau_potable','proportion_egout',
				'proportion_ordure','proportion_analphabete_15ans_plus','proportion_analphabete_10_14ans',
				'proportion_15_29ans','proportion_10_29ans','proportion_5_29ans','proportion_0_29ans'
				]
				
				


		data.writerow(Variable)
		for upp in ListUPP:
			row = [upp]+Base[upp]
			if len(row)!=len(Variable):
				print('problem')
				pdb.set_trace()
			else:
				data.writerow(row)



