import pdb
import json
import pickle
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
import copy
import numpy as np
import math
import os
import geopandas as gpd
import warnings
warnings.filterwarnings("ignore")
'''
line 640 : get an insignifiant warning when using method .to_crs 
'''

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'
FileI=os.listdir(path+'/intermediary')
if 'PointCensusTract' not in FileI:
	with open(path+'/intermediary/DPEstado_do_RioFinal.json') as gd:
		geo_data_DP = json.load(gd) 

	with open(path+'/intermediary/UPPEstado_do_RioFinal.json') as gd:
		geo_data_UPP = json.load(gd) 


	with open(path+'/intermediary/PrefeituraRio.json') as gd:
		geo_data_CensusTract = json.load(gd) 


	with open(path+'/source/RioPrefeitura/Limite_Favelas_2010.geojson') as gd:
		geo_data_favela = json.load(gd) 


	with open(path+'/source/RioPrefeitura/Bairro.geojson') as gd:
		geo_data_bairro = json.load(gd) 

	######################################################################################################
	'''
	Keep only layers of the city of Rio de Janeiro
	'''
	FeatureRio = []
	for feature in geo_data_DP['features']:
		if feature['properties']['City']=='Autre':
			1
		else:
			FeatureRio.append(feature)
	geo_data_DP_Rio={}
	geo_data_DP_Rio['type']='FeatureCollection'
	geo_data_DP_Rio['features']=FeatureRio
	######################################################################################################
	######################################################################################################
	# Define function f_get_polygone, carre, list_of_point
	######################################################################################################
	######################################################################################################
	def f_get_polygone(F):
		'''
		returns a list with polygons and holes in polygons
		'''
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


	def carre(feature):
		'''
		returns a square that encloses polygon
		'''
		List_Lat=[]
		List_Lon=[]
		R=f_get_polygone(feature)
		for P in R:
			poly = P[0]
			for tu in poly:
				lon = tu[0]
				lat = tu[1]
				List_Lon.append(lon)
				List_Lat.append(lat)
		
		lat_max = np.array(List_Lat).max()
		lat_min = np.array(List_Lat).min()

		lon_max = np.array(List_Lon).max()
		lon_min = np.array(List_Lon).min()

		Carre = [[lon_min,lat_max],[lon_max,lat_max],[lon_max,lat_min],[lon_min,lat_min],[lon_min,lat_max]]
		return (Carre,(lat_max,lat_min,lon_max,lon_min))

	def list_of_point(lat_max,lat_min,lon_max,lon_min):
		'''
		returns a grid of points with a 0.0005 space in the square lat_max,lat_min,lon_max,lon_min
		'''
		saut = round(0.0005,5)
		# left_up_corner
		x_min=lon_min-saut
		y_max=lat_max+saut

		# right_down_corner
		x_max=lon_max+saut
		y_min=lat_min-saut

		Y=[]
		y = y_min
		while y<y_max:
			Y.append(y)
			y = y + saut

		X=[]
		x = x_min
		while x<x_max:
			X.append(x)
			x = x + saut

		return(X,Y) 

	######################################################################################################
	######################################################################################################
	# creation of the object CadrillageFavela which is layer of squares that frame the different favelas of rio 
	'''
	One layer of CadrillageFavela is such as:
	{'type': 'Feature',
	 'properties': {'NumeroFavela': [933, 953, 992, 993, 994, 995], 'Name': 1},
	 'geometry': {'type': 'Polygon',
	  'coordinates': [[[-43.73331131735391, -22.96163949026691],
	    [-43.73331131735391, -22.926945790266913],
	    [-43.654850417353906, -22.926945790266913],
	    [-43.654850417353906, -22.96163949026691],
	    [-43.73331131735391, -22.96163949026691]]]}}

	meaning that in this layer we find the favelas [933, 953, 992, 993, 994, 995]
	'''
	######################################################################################################
	######################################################################################################
	LatMax=[]
	LatMin=[]
	LonMax=[]
	LonMin=[]
	for feature_favela in geo_data_favela['features']:
		A = carre(feature_favela)
		lat_max = A[1][0]
		lat_min = A[1][1] 
		lon_max = A[1][2] 
		lon_min = A[1][3] 

		LatMax.append(lat_max)
		LatMin.append(lat_min)
		LonMax.append(lon_max)
		LonMin.append(lon_min)

	jump_lat = round((max(LatMax)-min(LatMin))/8,7)
	jump_lon = round((max(LonMax)-min(LonMin))/8,7)

	lon = min(LonMin)
	CadrillageFavela={}
	CadrillageFavela['type']='FeatureCollection'
	CadrillageFavela['features']=[]
	i =0
	while lon<max(LonMax):
		lat = min(LatMin)
		while lat<max(LatMax):
			A={}
			A['type']='Feature'
			A['properties']={}
			A['properties']['NumeroFavela']=[]
			A['geometry']={}
			A['geometry']['type']='Polygon'
			A['geometry']['coordinates']=[[[lon,lat],[lon,lat + jump_lat],[lon + jump_lon,lat + jump_lat],[lon + jump_lon,lat],[lon,lat]]]
			CadrillageFavela['features'].append(A)
			i = i + 1

			lat = lat + jump_lat

		lon = lon + jump_lon

	Keep=[]
	Total = []
	name = 0
	for feature_cadrillage in CadrillageFavela['features']:
		R=f_get_polygone(feature_cadrillage)
		A = []
		p0=Polygon(R[0][0])

		ll = 0
		while ll<len(geo_data_favela['features']):
			feature_favela = geo_data_favela['features'][ll]
			if feature_favela['geometry']['type']=='Polygon':
				for tu_l in feature_favela['geometry']['coordinates'][0]:
					point= Point(tu_l[0],tu_l[1])
					if p0.contains(point):
						A.append(ll)
						break
				ll = ll + 1

			else:
				s = len(feature_favela['geometry']['coordinates'])
				test = 'no'
				for i in range(0,s):
					for tu_l in feature_favela['geometry']['coordinates'][i][0]:
						point= Point(tu_l[0],tu_l[1])
						if p0.contains(point):
							A.append(ll)	
							test = 'oui'
							break
					if test == 'oui':
						break

				ll = ll + 1


		if A!=[]:
			feature_cadrillage['properties']['NumeroFavela'] = A
			feature_cadrillage['properties']['Name']=name
			name = name + 1

			Total = Total + A
			Keep.append(feature_cadrillage)

	CadrillageFavela['features'] = Keep

	######################################################################################################
	######################################################################################################
	# Creation of a grid of points of the city of rio de janeiro. 
	# Each point belongs to a census tract and has a 0.0005 degree space within each census tract. 
	# For each point we define to which district, which neighborhood, which favela (if it is the case), which upp (if it is the case) it belongs
	######################################################################################################
	######################################################################################################

	######################################################################################################
	# 1 - creation of a grid of points of the city of rio de janeiro. 
	# Using the layers of census tracts, we create a grid of points with a 0.0005 space in each census tract
	######################################################################################################
	PointCensusTract={}
	Coordonnee={}
	CoordonneePoint={}
	nb = 0
	rr=0
	for feature_lot in geo_data_CensusTract['features']:
		rr = rr + 1
		lot = feature_lot['properties']['id']
		PointCensusTract[lot]={}
		R=f_get_polygone(feature_lot)

		B = carre(feature_lot)
		Carre_lot = B[0]
		lat_max_lot = B[1][0]
		lat_min_lot = B[1][1] 
		lon_max_lot = B[1][2] 
		lon_min_lot = B[1][3]
		BB=list_of_point(lat_max_lot,lat_min_lot,lon_max_lot,lon_min_lot) 

		Lon = BB[0]
		Lat = BB[1]
		for lon in Lon:
			for lat in Lat:
				point= Point(lon,lat)

				inside_CensusTract = False
				for P in R:
					polygone_lot=Polygon(P[0])
					Trou=[]
					Dict=P[1]
					for k in Dict.keys():
						Trou.append(Polygon(Dict[k]))

					if polygone_lot.contains(point):
						if Trou==[]:
							inside_CensusTract = True

						else:
							test=0
							for polygone_trou in Trou:
								if polygone_trou.contains(point):
									test=test+1
							if test==0:
								inside_CensusTract = True

					if inside_CensusTract == True:
						break

				if inside_CensusTract == True:
					PointCensusTract[lot][nb]={}
					Coordonnee[nb]=(lon,lat)
					CoordonneePoint[nb]=point
					nb = nb + 1
				else:
					1

		if PointCensusTract[lot]=={}:
			if feature_lot['geometry']['type'] == 'Polygon':
				polygone_lot = Polygon(feature_lot['geometry']['coordinates'][0])
				centroid_lot = polygone_lot.centroid

				lon = centroid_lot.x
				lat = centroid_lot.y
				point= Point(lon,lat)

				PointCensusTract[lot][nb]={}
				Coordonnee[nb]=(lon,lat)
				CoordonneePoint[nb]=point
				nb = nb + 1

			else:
				s = len(feature_lot['geometry']['coordinates'])
				for i in range(0,s):
					polygone_lot = Polygon(feature_lot['geometry']['coordinates'][i][0])
					centroid_lot = polygone_lot.centroid

					lon = centroid_lot.x
					lat = centroid_lot.y
					point= Point(lon,lat)

					PointCensusTract[lot][nb]={}
					Coordonnee[nb]=(lon,lat)
					CoordonneePoint[nb]=point
					nb = nb + 1

	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			PointCensusTract[lot][nb]['City']='RioDeJaneiro'

	######################################################################################################
	# 2 - For each point, we look for to which UPP (if it does) it belongs
	# if it does not belong to a UPP, will return 'N'	
	######################################################################################################
	ii = 0
	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			point=CoordonneePoint[nb]
			nom_upp = 'N'

			for ll in range(0,len(geo_data_UPP['features'])):
				feature_upp =  geo_data_UPP['features'][ll]
				R=f_get_polygone(feature_upp)
				Inside = False
				for P in R:
					f0=Polygon(P[0])
					Trou=[]
					Dict=P[1]
					for k in Dict.keys():
						Trou.append(Polygon(Dict[k]))

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
					ii = ll
					break									

			PointCensusTract[lot][nb]['UPP']=nom_upp


	######################################################################################################
	# 3 - For each point, we look for to which district (DP) it belongs 
	# if it belongs to a DP which is not in the city of Rio de Janeiro, will return 'N'	
	######################################################################################################
	ii = 0
	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			point=CoordonneePoint[nb]
			nom_dp = 'N'

			for ll in range(0,len(geo_data_DP_Rio['features'])):
				feature_dp =  geo_data_DP_Rio['features'][ll]
				R=f_get_polygone(feature_dp)
				Inside = False
				for P in R:
					f0=Polygon(P[0])
					Trou=[]
					Dict=P[1]
					for k in Dict.keys():
						Trou.append(Polygon(Dict[k]))

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
					nom_dp = feature_dp['properties']['DP']
					ii = ll
					break									

			PointCensusTract[lot][nb]['DP']=nom_dp

	'''
	If a census tract has some points that are in a district of the city of Rio de Janeiro and others that are not
	all the points of the census tract will then be assigned to the district of the city of Rio de Janeiro
	'''
	L=[]
	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			if PointCensusTract[lot][nb]['DP']=='N':
				L.append(lot)

	Asso = {}
	for lot in set(L):
		Asso[lot]=[]
		for nb in PointCensusTract[lot].keys():
			if PointCensusTract[lot][nb]['DP']!='N':
				Asso[lot].append(PointCensusTract[lot][nb]['DP'])

	for lot in set(L):
		if len(set(Asso[lot]))==1:
			for nb in PointCensusTract[lot].keys():
				if PointCensusTract[lot][nb]['DP']=='N':
					PointCensusTract[lot][nb]['DP'] = Asso[lot][0]
		else:
			print('pb set Asso')
			pdb.set_trace()


	######################################################################################################
	# 4 - For each point, we look for to which favela (if it does) it belongs
	# if it does not belong to a favela, will return 'N'	
	######################################################################################################
	ii = 0
	jj = 0
	for lot in PointCensusTract.keys():
		for nb in PointCensusTract[lot].keys():
			point=CoordonneePoint[nb]
			nom_favela = 'N'

			ll_retenu = -1
			for ll in range(0,len(CadrillageFavela['features'])):
				feature_cadrillage =  CadrillageFavela['features'][ll]
				R=f_get_polygone(feature_cadrillage)
				f0=Polygon(R[0][0])
				if f0.contains(point):
					ll_retenu = ll
					ii = ll
					break
			if ll_retenu==-1:
				PointCensusTract[lot][nb]['Favela']=nom_favela

			else:
				LL_favela = CadrillageFavela['features'][ll_retenu]['properties']['NumeroFavela']
				LL_favelaN=[jj]+LL_favela
				for ll_favela in LL_favelaN:
					feature_favela =  geo_data_favela['features'][ll_favela]
					R=f_get_polygone(feature_favela)
					Inside = False
					for P in R:
						f0=Polygon(P[0])
						Trou=[]
						Dict=P[1]
						for k in Dict.keys():
							Trou.append(Polygon(Dict[k]))

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
						nom_favela=feature_favela['properties']['cod_favela']
						jj = ll_favela
						break									

				PointCensusTract[lot][nb]['Favela']=nom_favela



	######################################################################################################
	# 5 - For each point, we look for to which neighborhood it belongs 
	######################################################################################################
	E={}
	E["santateresa"]="santatereza"
	E["vigáriogeral"]="vigariogeral"
	E["tomáscoelho"]="tomascoelho"
	E["praçaseca"]="pracaseca"
	E["sãofranciscoxavier"]="saofranciscoxavier"
	E["honóriogurgel"]="honoriogurgel"
	E["maré"]="mare"
	E["engenhodedentro"]="engdentro"
	E["paciência"]="paciencia"
	E["lapa"]="lapa"
	E["irajá"]="iraja"
	E["sãocristóvão"]="saocristovao"
	E["inhoaíba"]="inhoaiba"
	E["gericinó"]="gericino"
	E["inhaúma"]="inhauma"
	E["maracanã"]="maracana"
	E["senadorcamará"]="senadorcamara"
	E["sãoconrado"]="saoconrado"
	E["freguesia(ilha)"]="freguesia_ilha"
	E["grajaú"]="grajau"
	E["brásdepina"]="brasdepina"
	E["tauá"]="taua"
	E["complexodoalemão"]="complexodoalemao"
	E["andaraí"]="andarai"
	E["jacarepaguá"]="jacarepagua"
	E["gávea"]="gavea"
	E["saúde"]="saude"
	E["santíssimo"]="santissimo"
	E["jardimamérica"]="jardimamerica"
	E["linsdevasconcelos"]="linsvanconcelos"
	E["glória"]="gloria"
	E["méier"]="meier"
	E["freguesia(jacarepaguá)"]="freguesia_jacarepagua"
	E["jardimbotânico"]="jardimbotanico"
	E["águasanta"]="aguasanta"
	E["jacaré"]="jacare"
	E["estácio"]="estacio"
	E["humaitá"]="humaita"
	E["colégio"]="colegio"
	E["galeão"]="galeao"
	E["parquecolúmbia"]="parquecolumbia"
	E["engenhodarainha"]="engrainha"
	E["magalhãesbastos"]="magalhaesbastos"
	E["osvaldocruz"]="oswaldocruz"
	E["quintinobocaiúva"]="quintinobocaiuva"
	E["higienópolis"]="higienopolis"
	E["praçadabandeira"]="pracadabandeira"
	E["vascodagama"]="vascodagama"
	E["moneró"]="monero"
	E["gardêniaazul"]="gardeniaazul"
	E["turiaçú"]="turiacu"
	E["abolição"]="abolicao"
	E["cocotá"]="cocota"
	E["mariadagraça"]="mariadagraca"
	E["itanhangá"]="itanhanga"
	E["bancários"]="bancarios"
	E["cidadeuniversitária"]="cidadeuniversitaria"
	E["campodosafonsos"]="camposdosafonsos"
	E["joá"]="joa"


	
	kk = 0
	for lot in PointCensusTract.keys():
		kk = kk + 1
		for nb in PointCensusTract[lot].keys():
			bairro_found = 'N'

			point = CoordonneePoint[nb]
			for feature in geo_data_bairro['features']:
				name = feature['properties']['Name']
				Inside = False
				R=f_get_polygone(feature)
				for P in R:
					f0=Polygon(P[0])
					Trou=[]
					Dict=P[1]
					for k in Dict.keys():
						Trou.append(Polygon(Dict[k]))

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
					if name in E.keys():
						bairro_found=E[name]
					else:
						bairro_found=name
			
					break

			PointCensusTract[lot][nb]['Bairro']=bairro_found
	



	######################################################################################################
	# We add information for the upp Mangueirinha which is in the state of Rio de Janeiro (not in the city)
	# "300000000000000" in PointCensusTract.keys()
	######################################################################################################
	nb_man = 143989
	lot_man = "300000000000000"

	UPPrio=gpd.read_file(path+'/source/ISP/UPPshp/lm_upp_edit.shp')
	UPPrio4326 = UPPrio.to_crs({"init":"epsg:4326"})
	geo_data_UPP = json.loads(UPPrio4326.to_json())
	for feature in geo_data_UPP['features']:
		Coord = json.loads(str(feature['geometry']['coordinates']).replace(', 0.0]',']'))
		feature['geometry']['coordinates']=Coord
				
	for feature in geo_data_UPP['features']:
		upp=feature['properties']['nomeabrev']
		if upp == 'UPP Mangueirinha':
			f_mangueirinha=copy.copy(feature)

			polygone_lot = Polygon(feature['geometry']['coordinates'][0])
			centroid_lot = polygone_lot.centroid

			lon = centroid_lot.x
			lat = centroid_lot.y
			point= Point(lon,lat)

			if lot_man in PointCensusTract.keys() or nb_man in Coordonnee.keys():
				print('problem mangueirinha')
				pdb.set_trace()

			else:
				PointCensusTract[lot_man]={}
				PointCensusTract[lot_man][nb_man]={}
				PointCensusTract[lot_man][nb_man]['UPP']='DoUppMangueirinha'
				PointCensusTract[lot_man][nb_man]['DP']='59'
				PointCensusTract[lot_man][nb_man]['Favela']='N'
				PointCensusTract[lot_man][nb_man]['City']='Duque de Caxias'

				Coordonnee[nb_man]=(lon,lat)
				CoordonneePoint[nb_man]=point

	f_mangueirinha['properties']={}
	for k in geo_data_CensusTract['features'][0]['properties'].keys():
		f_mangueirinha['properties'][k]=None

	f_mangueirinha['properties']['population']=float(21415)
	f_mangueirinha['properties']['id']=lot_man
	if f_mangueirinha in geo_data_CensusTract['features']:
		print('f_mangueirinha already in')
		pdb.set_trace()

	geo_data_CensusTract['features'].append(f_mangueirinha)
	


	with open(path+'/intermediary/PointCensusTract','wb') as output:
		pickle.dump((PointCensusTract,Coordonnee,CoordonneePoint),output)


	with open(path+'/intermediary/PrefeituraRio.json', 'w') as outfile:
		json.dump(geo_data_CensusTract,outfile)










