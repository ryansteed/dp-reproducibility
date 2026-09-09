import pdb
import json
import copy
import numpy as np
import math
import os
import geopandas as gpd
import warnings
warnings.filterwarnings("ignore")
'''
lines 72 & 146 : get an insignifiant warning when using method .to_crs 
'''

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileI=os.listdir(path+'/intermediary')
if 'DPEstado_do_RioFinal.json' not in FileI or 'UPPEstado_do_RioFinal.json' not in FileI or 'PrefeituraRio.json' not in FileI:
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

	######################################################################################################			
	# Create data layer for DP
	# Merge following DP - we have to do this because these are new DPs -> for instance DP42 was created in april 2010
	#15	11
	#22	45
	#65	67
	#71	70
	#126	132
	#143	148
	#16	42
	#123	130
	######################################################################################################
	DPRio=['28', '27', '40', '16 e 42', '33', '22 e 45', '18', '37', '23', '9', '20', '25', '10', '17', '43', '12','13', '39', '29', '35', '19', '24', '6', '1','4','5', '31', '44', '26', '7', '34', '32', '30', '36', '15 e 11', '41', '38', '14', '21']

	Correspondance={}
	Correspondance[15]=11 
	Correspondance[22]=45 
	Correspondance[16]=42 
	Correspondance[65]=67 
	Correspondance[71]=70 
	Correspondance[126]=132 
	Correspondance[143]=148 
	Correspondance[123]=130 

	DPrio=gpd.read_file(path+'/source/ISP/DPshp/Novo_Limite_CISP_WGS.shp')
	DPrio4326 = DPrio.to_crs({"init":"epsg:4326"})
	geo_data_DP = json.loads(DPrio4326.to_json())
	for feature in geo_data_DP['features']:
		Coord = json.loads(str(feature['geometry']['coordinates']).replace(', 0.0]',']'))
		feature['geometry']['coordinates']=Coord

	A={}
	A['type']='FeatureCollection'
	A['features']=[]
	for feature in geo_data_DP['features']:
		dp=feature['properties']['DP']
		featurenew={}
		if dp in (15,22,16,65,71,126,143,123):
			dp2=Correspondance[dp]
			dpnew=str(dp)+' e '+str(dp2)
			featurenew['properties']={}
			featurenew['properties']['DP']=dpnew
			if dpnew in DPRio:
				featurenew['properties']['City']='RioDeJaneiro'
			else:
				featurenew['properties']['City']='Autre'
				

			featurenew['type']=feature['type']

			featurenew['geometry']={}
			featurenew['geometry']['type']='MultiPolygon'
			featurenew['geometry']['coordinates']=[]
			R=f_get_polygone(feature)
			for P in R:
				featurenew['geometry']['coordinates'].append([P[0]])

		
			for feature2 in geo_data_DP['features']:
				if feature2['properties']['DP']==dp2 and dp2 not in ['11',11]: #by removing the hole of dp 15 - don't need to consider dp11 in the merge
					R=f_get_polygone(feature2)
					for P in R:
						featurenew['geometry']['coordinates'].append([P[0]])
						
				
		elif dp not in (11,45,42,67,70,132,148,130):
			featurenew['properties']={}
			featurenew['properties']['DP']=str(dp)

			if str(dp) in DPRio:
				featurenew['properties']['City']='RioDeJaneiro'
			else:
				featurenew['properties']['City']='Autre'


			featurenew['type']=feature['type']
			featurenew['geometry']=feature['geometry']

		if featurenew!={}:
			A['features'].append(featurenew)

	with open(path+'/intermediary/DPEstado_do_RioFinal.json', 'w') as outfile:
	    json.dump(A,outfile)
	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################
	
	###############################################################################################
	# Create data layer for UPP : source RioPrefeitura & ISP
	###############################################################################################
	UPPrio=gpd.read_file(path+'/source/ISP/UPPshp/lm_upp_edit.shp')
	UPPrio4326 = UPPrio.to_crs({"init":"epsg:4326"})
	geo_data_UPP = json.loads(UPPrio4326.to_json())
	for feature in geo_data_UPP['features']:
		Coord = json.loads(str(feature['geometry']['coordinates']).replace(', 0.0]',']'))
		feature['geometry']['coordinates']=Coord

	D={}
	D['UPP Mangueirinha']='DoUPPMangueirinha'
	D['UPP Vila Kennedy']='DoUppVilaKennedy'
	D['UPP Camarista Méier']='DoUppCamaristaMeier'
	D['UPP Lins']='DoUppLins'
	D['UPP Cidade de Deus']='DoUppCdd'
	D['UPP Chatuba']='DoUppChatuba'
	D['UPP Nova Brasília']='DoUppNovaBrasilia'
	D['UPP Parque Proletariado da Penha']='DoUppParqueProletario'
	D['UPP Vila Cruzeiro - Cariri']='DoUppVilaCruzeiro'
	D['UPP Fazendinha']='DoUppFazendinha'
	D['UPP Adeus - Baiana']='DoUppAdeusBaiana'
	D['UPP Alemão - Pedra do Sapo']='DoUppAlemao'
	D['UPP Manguinhos']='DoUppManguinhos'
	D['UPP Jacarezinho']='DoUppJacarezinho'
	D['UPP Macacos']='DoUppMacacos'
	D['UPP São João']='DoUppSaoJoaoQuietoMatriz'
	D['UPP Formiga']='DoUppFormiga'
	D['UPP Borel']='DoUppBorel'
	D['UPP Andaraí']='DoUppAndarai'
	D['UPP Salgueiro']='DoUppSalgueiro'
	D['UPP Turano']='DoUppTurano'
	D['UPP Pavão-Pavãozinho-Cantagalo']='DoUppPavaoPavaozinho'
	D['UPP Providência']='DoUppProvidencia'
	D['UPP Ladeira dos Tabajaras e Morro dos Cabritos']='DoUppTabajaras'
	D['UPP Babilonia - Chapeu Mangueira']='DoUppChapeuMangueiraEBabilonia'
	D['UPP Santa Marta']='DoUppSantaMarta'
	D['UPP Fallet_Fogueteiro-Coroa']='DoUppCoroaFalletFogueteiro'
	D['UPP Cerro Corá']='DoUppCerroCora'
	D['UPP São Carlos - Mineira - Zinco - Querosene']='DoUppSaoCarlos'
	D['UPP Arará - Mandela']='DoUppAraraMandela'
	D['UPP Rocinha']='DoUppRocinha'
	D['UPP Vidigal-Chácara do Céu']='DoUppVidigal'
	D['UPP Mangueira']='DoUppMangueira'
	D['UPP Prazeres-Escondidinho']='DoUppEscondidinhoEPrazeres'
	D['UPP Fé -Sereno']='DoUppFeSereno'
	D['UPP Barreira do Vasco -Tuiuti']='DoUppBarreiraVascoTuiuti'
	D['UPP Batan']='DoUppBatan'
	D['UPP Maré']='DoUppMare'
	D['UPP Parque Alegria -Cajú']='DoUppCaju'

	
	for feature in geo_data_UPP['features']:
		upp=D[feature['properties']['nomeabrev']]
		if upp == 'DoUPPMangueirinha':
			f_mangueirinha=copy.copy(feature)
			f_mangueirinha['properties']={}
			f_mangueirinha['properties']['UPP']=upp


	with open(path+'/source/RioPrefeitura/Limiteupp_arcgis.geojson') as gd:
		geo_data_UPP_arcgis = json.load(gd)

	D_arcgis={}
	D_arcgis['UPP Vila Kennedy']='DoUppVilaKennedy'
	D_arcgis['UPP Camarista Méier']='DoUppCamaristaMeier'
	D_arcgis['UPP Lins']='DoUppLins'
	D_arcgis['UPP Cidade de Deus']='DoUppCdd'
	D_arcgis['UPP Chatuba']='DoUppChatuba'
	D_arcgis['UPP Nova Brasília']='DoUppNovaBrasilia'
	D_arcgis['UPP Vila Proletária da Penha']='DoUppParqueProletario'
	D_arcgis['UPP Vila Cruzeiro']='DoUppVilaCruzeiro'
	D_arcgis['UPP Fazendinha']='DoUppFazendinha'
	D_arcgis['UPP Adeus / Baiana']='DoUppAdeusBaiana'
	D_arcgis['UPP Alemão']='DoUppAlemao'
	D_arcgis['UPP Manguinhos']='DoUppManguinhos'
	D_arcgis['UPP Jacarezinho']='DoUppJacarezinho'
	D_arcgis['UPP Macacos']='DoUppMacacos'
	D_arcgis['UPP São João']='DoUppSaoJoaoQuietoMatriz'
	D_arcgis['UPP Formiga']='DoUppFormiga'
	D_arcgis['UPP Borel']='DoUppBorel'
	D_arcgis['UPP Andaraí']='DoUppAndarai'
	D_arcgis['UPP Salgueiro']='DoUppSalgueiro'
	D_arcgis['UPP Turano']='DoUppTurano'
	D_arcgis['UPP Pavão-Pavãozinho / Cantagalo']='DoUppPavaoPavaozinho'
	D_arcgis['UPP Providência']='DoUppProvidencia'
	D_arcgis['UPP Tabjaras / Cabritos']='DoUppTabajaras'
	D_arcgis['UPP Chapéu Mangueira / Babilônia']='DoUppChapeuMangueiraEBabilonia'
	D_arcgis['UPP Santa Marta']='DoUppSantaMarta'
	D_arcgis['UPP Fallet / Fogueteiro / Coroa']='DoUppCoroaFalletFogueteiro'
	D_arcgis['UPP Cerro-Corá']='DoUppCerroCora'
	D_arcgis['UPP São Carlos']='DoUppSaoCarlos'
	D_arcgis['UPP Manguinhos - Arará / Mandela']='DoUppAraraMandela'
	D_arcgis['UPP Rocinha']='DoUppRocinha'
	D_arcgis['UPP Vidigal / Chácara do Céu']='DoUppVidigal'
	D_arcgis['UPP Mangueira']='DoUppMangueira'
	D_arcgis['UPP Escondidinho / Prazeres']='DoUppEscondidinhoEPrazeres'
	D_arcgis['UPP Fé / Sereno']='DoUppFeSereno'
	D_arcgis['UPP Barreira do Vasco / Tuiuti']='DoUppBarreiraVascoTuiuti'
	D_arcgis['UPP Batan']='DoUppBatan'
	D_arcgis['UPP Caju']='DoUppCaju'
	D_arcgis['UPP Baixa do Sapateiro / Timbau']='DoUppMare_BaixadoSapateiro_Timbau'
	D_arcgis['UPP Praia de Ramos / Roquete Pinto']='DoUppMare_PraiadeRamos_RoquetePinto'
	D_arcgis['UPP Vila do João / Pinheiros']='DoUppMare_Vila do Joao_Pinheiros'
	D_arcgis['UPP Nova Holanda / Parque União']='DoUppMare_Holanda_Parque Uniao'


	'''
	We add UPP_Mangueirinha
	UPP_Mangueirinha does not exist in the arcgis database which is only for the city of Rio de Janeiro and not for the state of Rio de Janeiro
	'''
	for feature in geo_data_UPP_arcgis['features']:
		upp=D_arcgis[feature['properties']['Nome']]
		feature['properties']={}
		feature['properties']['UPP']=upp

	geo_data_UPP_arcgis['features'].append(f_mangueirinha)
	
	with open(path+'/intermediary/UPPEstado_do_RioFinal.json', 'w') as outfile:
	    json.dump(geo_data_UPP_arcgis,outfile)


	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################

	#########################################################################################################################################
	#########################################################################################################################################
	
	##############################################################################################################################################################################################
	# Using data from RioPrefeitura, we create data of the layer of census tracts of the city of Rio de Janeiro
	# For each census tract, we assign values of different socio-economics variables
	##############################################################################################################################################################################################
	with open(path+'/source/RioPrefeitura/Densidade.json') as gd:
		geo_data_densite = json.load(gd)

	PP = 0
	Data={}
	for feature in geo_data_densite['features']:
		id_unique=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.ID_']

		area=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.Area']
		pop=feature['properties']['CDURP.DBO.Dens_demo_.PopulacaoDPP']
		dens=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.Hab_ha']
		dom = feature['properties']['CDURP.DBO.Dens_demo_.DomParticularPerm']
		per_dom = feature['properties']['CDURP.DBO.Dens_demo_.MediaPessoasDPP']

		try:
			int(pop)
			if  int(area*dens)-int(pop) not in [-1,0,1]:
				print('problem 1')
				pdb.set_trace()
		
		except:
			pop='NaN'
			dens='NaN'

		if id_unique in Data.keys():
			print('problem 2')
			pdb.set_trace()
		Data[id_unique]={}
		Data[id_unique]['area']=area
		Data[id_unique]['densite']=dens
		Data[id_unique]['population']=pop
		Data[id_unique]['domicile']=dom
		Data[id_unique]['personne_par_dom']=per_dom

		Data[id_unique]['type']=feature['type']
		Data[id_unique]['geometry']=feature['geometry']


	########################################################	
	with open(path+'/source/RioPrefeitura/Inegalidade.json') as gd:
		geo_data_inegalite = json.load(gd)

	for feature in geo_data_inegalite['features']:
		id_unique=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.ID_']

		area=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.Area']
		dens=feature['properties']['CDURP.DBO.Novos_Setores_Recortados_2010_1.Hab_ha']

		INDIC_MEDBANH_PES=feature['properties']['CDURP.DBO.IDS_SETOR10.INDIC_MEDBANH_PES']# not used
		I_MEDBANH_PES=feature['properties']['CDURP.DBO.IDS_SETOR10.I_MEDBANH_PES'] # not used
		INDIC_RENDARESP_POS_ATE2SM=feature['properties']['CDURP.DBO.IDS_SETOR10.INDIC_RENDARESP_POS_ATE2SM']# not used
		I_RENDARESP_POS_ATE2SM=feature['properties']['CDURP.DBO.IDS_SETOR10.I_RENDARESP_POS_ATE2SM']# not used
		INDIC_RENDARESP_P_MAISDE10SM=feature['properties']['CDURP.DBO.IDS_SETOR10.INDIC_RENDARESP_P_MAISDE10SM']# not used
		I_RENDARESP_P_MAISDE10SM=feature['properties']['CDURP.DBO.IDS_SETOR10.I_RENDARESP_P_MAISDE10SM']# not used
		INDIC_RENDARESP_POS_SM=feature['properties']['CDURP.DBO.IDS_SETOR10.INDIC_RENDARESP_POS_SM']# not used
		I_RENDARESP_POS_SM=feature['properties']['CDURP.DBO.IDS_SETOR10.I_RENDARESP_POS_SM'] # not used
		IDS=feature['properties']['CDURP.DBO.IDS_SETOR10.IDS']# not used


		if id_unique in Data.keys():
			if Data[id_unique]['type']==feature['type'] and Data[id_unique]['geometry']==feature['geometry'] and Data[id_unique]['area']==area and Data[id_unique]['densite']==dens:
				1
			else:
				print('problem 3')
				pdb.set_trace()

		else:
			Data[id_unique]={}
			Data[id_unique]['type']=feature['type']
			Data[id_unique]['geometry']=feature['geometry']
			Data[id_unique]['area']=area
			Data[id_unique]['densite']=dens
			pop=int(round(area*dens,0))
			Data[id_unique]['population']=pop
			Data[id_unique]['domicile']='NAN'
			Data[id_unique]['personne_par_dom']='NAN'
			
		Data[id_unique]['proportion_10_fois_SMIC']=I_RENDARESP_P_MAISDE10SM


	'''
	Few censustract ids are in Densite.json but not in Inegalite.json
	Add missing values
	'''
	k = 'proportion_10_fois_SMIC'
	for id_unique in Data.keys():
		if k not in Data[id_unique].keys():
			Data[id_unique][k]='NAN'
				

	########################################################
	with open(path+'/source/RioPrefeitura/Rendimento_nominal_mensal.json') as gd:
		geo_data_rendimento = json.load(gd)


	for feature in geo_data_rendimento['features']:
		id_unique=feature['properties']['CDURPDBO_2']

		area=feature['properties']['CDURPDBO_5'] # used for verification purposes
		dens=feature['properties']['CDURPDBO_6'] # used for verification purposes
		rendapercapitaDPP=feature['properties']['CDURPDBO_9']
		DomRendaMediaDPP=feature['properties']['CDURPDBO10']

		if id_unique in Data.keys():
			if Data[id_unique]['area']==area and Data[id_unique]['densite']==dens:
				1
			else:
				if Data[id_unique]['area']==area and dens==None:
					1
				else:				
					print('problem 4')
					pdb.set_trace()

			Data[id_unique]['Revenu_par_Tete']=rendapercapitaDPP
			Data[id_unique]['Revenu_moyen_Domicile']=DomRendaMediaDPP


		else:
			'''
			two are missings - marginal issue
			'''
			pass


	########################################################
	with open(path+'/source/RioPrefeitura/Dom_Alugados.geojson') as gd:
		alugado = json.load(gd)

	with open(path+'/source/RioPrefeitura/Dom_Coleta_de_Lixo.geojson') as gd:
		lixo = json.load(gd)


	for feature in lixo['features']:
		id_unique = feature['properties']['BASEGEODBO']
		area=feature['properties']['CDURPDBO_5']# used for verification purposes
		P_AguaADEQUADA=feature['properties']['BASEGEOD_1']
		P_EsgotoADEQUADO=feature['properties']['BASEGEOD_2']
		P_EletDistMede=feature['properties']['BASEGEOD_3']
		P_LixoADEQUADO =feature['properties']['BASEGEOD_4']
		P_Analfa10a14anos =feature['properties']['BASEGEOD_5'] 
		P_Analfa8e9anos =feature['properties']['BASEGEOD_6']
		P_Analfa15ouMais =feature['properties']['BASEGEOD_7']
		Domicile_moins_1_SMIC=feature['properties']['BASEGEOD_8']
		Responsable_moins_1_SMIC=feature['properties']['BASEGEOD10']


		if id_unique in Data.keys():
			if Data[id_unique]['area']==area:
				1
			else:
				print('problem 5')
				pdb.set_trace()

			Data[id_unique]['Eau_Potable']=P_AguaADEQUADA
			Data[id_unique]['Egout']=P_EsgotoADEQUADO
			Data[id_unique]['Electricite']=P_EletDistMede
			Data[id_unique]['Ordure']=P_LixoADEQUADO

			Data[id_unique]['Alphabete_10_14']=P_Analfa10a14anos
			Data[id_unique]['Alphabete_8_9']=P_Analfa8e9anos
			Data[id_unique]['Alphabete_15_plus']=P_Analfa15ouMais


			Data[id_unique]['Domicile_moins_1_SMIC']=Domicile_moins_1_SMIC
			Data[id_unique]['Responsable_moins_1_SMIC']=Responsable_moins_1_SMIC

		else:
			'''
			two are missings - marginal issue
			'''
			pass

	for feature in alugado['features']:
		id_unique = feature['properties']['CDURPDBO_7']
		area=feature['properties']['CDURPDBO_5']# used for verification purposes
		DPP_Proprio=feature['properties']['CDURPDBO14']
		DPP_Alugado=feature['properties']['CDURPDBO15']
		DPP_Cedido=feature['properties']['CDURPDBO16']
		DPP_Outro=feature['properties']['CDURPDBO17']


		if id_unique in Data.keys():
			if Data[id_unique]['area']==area:
				1
			else:
				print('problem 6')
				pdb.set_trace()

			Data[id_unique]['Proprietaire']=DPP_Proprio
			Data[id_unique]['Locataire']=DPP_Alugado
			Data[id_unique]['Cedido']=DPP_Cedido
			Data[id_unique]['Autre']=DPP_Outro

		else:
			'''
			two are missings - marginal issue
			'''
			pass

	########################################################
	with open(path+'/source/RioPrefeitura/Razao_de_Sexo_HomensMulheres.geojson') as gd:
		geo_data_age = json.load(gd)

	EquiA={}
	EquiA["CDURPDBO_9"]="Total_hom" 
	EquiA["CDURPDBO10"]="Hom0a4anos"
	EquiA["CDURPDBO11"]="Hom5a9anos"
	EquiA["CDURPDBO12"]="Hom10a14anos"
	EquiA["CDURPDBO13"]="Hom0a14anos"# not used
	EquiA["CDURPDBO14"]="Hom15a19anos"# not used
	EquiA["CDURPDBO15"]="Hom20a24anos"# not used
	EquiA["CDURPDBO16"]="Hom25a29anos"# not used
	EquiA["CDURPDBO17"]="Hom15a29anos"
	EquiA["CDURPDBO18"]="Hom30a34anos"# not used
	EquiA["CDURPDBO19"]="Hom35a39anos"# not used
	EquiA["CDURPDBO20"]="Hom40a44anos"# not used
	EquiA["CDURPDBO21"]="Hom45a49anos"# not used
	EquiA["CDURPDBO22"]="Hom50a54anos"# not used
	EquiA["CDURPDBO23"]="Hom55a59anos"# not used
	EquiA["CDURPDBO24"]="Hom60a64anos"# not used
	EquiA["CDURPDBO25"]="Hom30a64anos"
	EquiA["CDURPDBO26"]="Hom65a69anos"# not used
	EquiA["CDURPDBO27"]="Hom70a74anos"# not used
	EquiA["CDURPDBO28"]="Hom75a79anos"# not used
	EquiA["CDURPDBO29"]="Hom80a84anos"# not used
	EquiA["CDURPDBO30"]="Hom85a89anos"# not used
	EquiA["CDURPDBO31"]="Hom90a94anos"# not used
	EquiA["CDURPDBO32"]="Hom95a99anos"# not used
	EquiA["CDURPDBO33"]="Hom100anosMais"# not used
	EquiA["CDURPDBO34"]="Hom_65"
	EquiA["CDURPDBO35"]="Total_Mul"
	EquiA["CDURPDBO36"]="Mul0a4anos"
	EquiA["CDURPDBO37"]="Mul5a9anos"
	EquiA["CDURPDBO38"]="Mul10a14anos"
	EquiA["CDURPDBO39"]="Mul0a14anos"# not used
	EquiA["CDURPDBO40"]="Mul15a19anos"# not used
	EquiA["CDURPDBO41"]="Mul20a24anos"# not used
	EquiA["CDURPDBO42"]="Mul25a29anos"# not used
	EquiA["CDURPDBO43"]="Mul15a29anos"# not used
	EquiA["CDURPDBO44"]="Mul30a34anos"# not used
	EquiA["CDURPDBO45"]="Mul35a39anos"# not used
	EquiA["CDURPDBO46"]="Mul40a44anos"# not used
	EquiA["CDURPDBO47"]="Mul45a49anos"# not used
	EquiA["CDURPDBO48"]="Mul50a54anos"# not used
	EquiA["CDURPDBO49"]="Mul55a59anos"# not used
	EquiA["CDURPDBO50"]="Mul60a64anos"# not used
	EquiA["CDURPDBO51"]="Mul30a64anos"
	EquiA["CDURPDBO52"]="Mul65a69anos"# not used
	EquiA["CDURPDBO53"]="Mul70a74anos"# not used
	EquiA["CDURPDBO54"]="Mul75a79anos"# not used
	EquiA["CDURPDBO55"]="Mul80a84anos"# not used
	EquiA["CDURPDBO56"]="Mul85a89anos"# not used
	EquiA["CDURPDBO57"]="Mul90a94anos"# not used
	EquiA["CDURPDBO58"]="Mul95a99anos"# not used
	EquiA["CDURPDBO59"]="Mul100anosMais"# not used
	EquiA["CDURPDBO60"]="Mul_65"


	for feature in geo_data_age['features']:
		id_unique=feature['properties']['CDURPDBO_2']
		area=feature['properties']['CDURPDBO_5'] # used for verification purposes

		if id_unique in Data.keys():
			if Data[id_unique]['area']==area:
				1
			else:				
				print('problem 5')
				pdb.set_trace()
	
			for k in feature['properties']:
				if k in EquiA.keys():
					val = str(feature['properties'][k])
					Data[id_unique][EquiA[k]]=val
		else:
			'''
			two are missings - marginal issue
			'''
			pass

	###############################################################################################
	###############################################################################################
	A={}
	A['type']='FeatureCollection'
	A['features']=[]
	for id_unique in Data.keys():

		featurenew={}

		featurenew['type']=Data[id_unique]['type']
		featurenew['geometry']=Data[id_unique]['geometry']
	

		featurenew['properties']={}
		featurenew['properties']['id']=id_unique

		# area, density, persons by household
		if str(Data[id_unique]['area']) in ['NAN','NaN','nan','None']:
			area = None
		else:
			area = float(Data[id_unique]['area'])
		featurenew['properties']['area']=area


		if str(Data[id_unique]['densite']) in ['NAN','NaN','nan','None']:
			densite = None
		else:
			densite = float(Data[id_unique]['densite'])
		featurenew['properties']['densite']=densite

		if str(Data[id_unique]['personne_par_dom']) in ['NAN','NaN','nan','None']:
			personne_par_dom = None
		else:
			personne_par_dom = float(Data[id_unique]['personne_par_dom'])
		featurenew['properties']['personne_par_dom']=personne_par_dom


		# population , per capita income 
		if str(Data[id_unique]['population']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Revenu_par_Tete']) in ['NAN','NaN','nan','None']:
			pop = None
			rev_pop_total = None
			if str(Data[id_unique]['population']) not in ['NAN','NaN','nan','None']:
				pass # str(Data[id_unique]['population']) equal to '0'
				
		else:
			pop = float(Data[id_unique]['population'])
			rev_par_tete = float(Data[id_unique]['Revenu_par_Tete'])
			rev_pop_total = round(pop * rev_par_tete,2)
			

		featurenew['properties']['population']=pop
		featurenew['properties']['rev_total_lotissement0']=rev_pop_total


		# domicile, average income per household
		if str(Data[id_unique]['domicile']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Revenu_moyen_Domicile']) in ['NAN','NaN','nan','None']:
			dom = None
			rev_dom_total = None
		else:
			dom = float(Data[id_unique]['domicile'])
			rev_moyen_dom = float(Data[id_unique]['Revenu_moyen_Domicile'])
			rev_dom_total = round(rev_moyen_dom*dom,2)

		featurenew['properties']['domicile']=dom
		featurenew['properties']['rev_total_lotissement1']=rev_dom_total

		# age
		if str(Data[id_unique]['population']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Total_Mul']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Total_hom']) in ['NAN','NaN','nan','None']:
			nbre_65_plus = None
			nbre_30_64_moins = None
			nbre_15_29_moins = None

			nbre_15_plus = None

			nbre_10_14 = None
			nbre_5_9 = None
			nbre_0_4 = None

		else:
			pop0 = float(Data[id_unique]['population'])
			pop1 = float(Data[id_unique]['Total_Mul'])+float(Data[id_unique]['Total_hom'])
			if math.fabs((pop0-pop1)/pop1)*100>1 or math.fabs((pop0-pop1)/pop1)>5:
				nbre_65_plus = None
				nbre_30_64_moins = None
				nbre_15_29_moins = None

				nbre_15_plus = None	

				nbre_10_14 = None
				nbre_5_9 = None
				nbre_0_4 = None
				
				
			else:
				nbre_65_plus = float(Data[id_unique]['Hom_65'])+float(Data[id_unique]['Mul_65'])
				nbre_30_64_moins = float(Data[id_unique]['Hom30a64anos'])+float(Data[id_unique]['Mul30a64anos'])
				nbre_15_29_moins = float(Data[id_unique]['Hom15a29anos'])+float(Data[id_unique]['Mul15a29anos'])

				nbre_15_plus = nbre_65_plus  + nbre_30_64_moins + nbre_15_29_moins

				nbre_10_14 = float(Data[id_unique]["Hom10a14anos"])+float(Data[id_unique]["Mul10a14anos"])
				nbre_5_9 = float(Data[id_unique]["Hom5a9anos"])+float(Data[id_unique]["Mul5a9anos"])
				nbre_0_4 = float(Data[id_unique]["Hom0a4anos"])+float(Data[id_unique]["Mul0a4anos"])




		featurenew['properties']['nbre_65_plus']=nbre_65_plus
		featurenew['properties']['nbre_30_64_moins']=nbre_30_64_moins
		featurenew['properties']['nbre_15_29_moins']=nbre_15_29_moins

		featurenew['properties']['nbre_10_14']=nbre_10_14
		featurenew['properties']['nbre_5_9']=nbre_5_9
		featurenew['properties']['nbre_0_4']=nbre_0_4

		featurenew['properties']['nbre_15_plus']=nbre_15_plus




		#  Illiteracy rate
		if str(Data[id_unique]['Alphabete_10_14']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Alphabete_15_plus']) in ['NAN','NaN','nan','None']:
			proportion_alphabete_10_14 = None
			proportion_alphabete_15_plus = None
		else:
			proportion_alphabete_10_14=round(float(Data[id_unique]['Alphabete_10_14']),5)
			proportion_alphabete_15_plus=round(float(Data[id_unique]['Alphabete_15_plus']),5)

		featurenew['properties']['proportion_alphabete_10_14']=proportion_alphabete_10_14
		featurenew['properties']['proportion_alphabete_15_plus']=proportion_alphabete_15_plus


		# Proportion of wages below the minimum wage
		if str(Data[id_unique]['Domicile_moins_1_SMIC']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Responsable_moins_1_SMIC']) in ['NAN','NaN','nan','None']:
			proportion_domicile_moins_smic = None
			proportion_responsable_moins_smic = None
		else:
			proportion_domicile_moins_smic=round(float(Data[id_unique]['Domicile_moins_1_SMIC']),5)
			proportion_responsable_moins_smic=round(float(Data[id_unique]['Responsable_moins_1_SMIC']),5)

		featurenew['properties']['proportion_domicile_moins_smic']=proportion_domicile_moins_smic
		featurenew['properties']['proportion_responsable_moins_smic']=proportion_responsable_moins_smic

		# Proportion 10 times the minimum wage
		if str(Data[id_unique]['proportion_10_fois_SMIC']) in ['NAN','NaN','nan','None']:
			proportion_dix_fois_smic = None
		else:
			proportion_dix_fois_smic = round(float(Data[id_unique]['proportion_10_fois_SMIC']),5)			

		featurenew['properties']['proportion_dix_fois_smic']=proportion_dix_fois_smic

		# infrastructure
		if str(Data[id_unique]['Eau_Potable']) in ['NAN','NaN','nan','None']:
			proportion_Eau_Potable = None
		else:
			proportion_Eau_Potable = round(float(Data[id_unique]['Eau_Potable']),5)


		if str(Data[id_unique]['Egout']) in ['NAN','NaN','nan','None']:
			proportion_Egout = None

		else:
			proportion_Egout=round(float(Data[id_unique]['Egout']),5)

		if str(Data[id_unique]['Electricite']) in ['NAN','NaN','nan','None']:
			proportion_Electricite = None
		else:
			proportion_Electricite = round(float(Data[id_unique]['Electricite']),5)
			
		if str(Data[id_unique]['Ordure']) in ['NAN','NaN','nan','None']:
			proportion_Ordure = None

		else:
			proportion_Ordure = round(float(Data[id_unique]['Ordure']),5)


		featurenew['properties']['proportion_Eau_Potable']=proportion_Eau_Potable
		featurenew['properties']['proportion_Egout']=proportion_Egout
		featurenew['properties']['proportion_Electricite']=proportion_Electricite
		featurenew['properties']['proportion_Ordure']=proportion_Ordure


		# Renter/Owner
		if str(Data[id_unique]['Proprietaire']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Locataire']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Cedido']) in ['NAN','NaN','nan','None'] or str(Data[id_unique]['Autre']) in ['NAN','NaN','nan','None']:

			proportion_Proprietaire_Logement= None
			proportion_Locataire_Logement = None
			proportion_Occupe_Logement = None
			proportion_Autre_Logement  = None

		else:	

			proportion_Proprietaire_Logement= round(float(Data[id_unique]['Proprietaire']),5)
			proportion_Locataire_Logement =  round(float(Data[id_unique]['Locataire']),5)
			proportion_Occupe_Logement =  round(float(Data[id_unique]['Cedido']),5)
			proportion_Autre_Propriete_Logement =  round(float(Data[id_unique]['Autre']),5)
	
		featurenew['properties']['proportion_Proprietaire_Logement']=proportion_Proprietaire_Logement
		featurenew['properties']['proportion_Locataire_Logement']=proportion_Locataire_Logement
		featurenew['properties']['proportion_Occupe_Logement']=proportion_Occupe_Logement
		featurenew['properties']['proportion_Autre_Propriete_Logement']=proportion_Autre_Propriete_Logement



		A['features'].append(featurenew)

	
	with open(path+'/intermediary/PrefeituraRio.json', 'w') as outfile:
		json.dump(A,outfile)





