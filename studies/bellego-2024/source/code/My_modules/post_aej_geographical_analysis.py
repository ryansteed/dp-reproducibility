import pandas as pd
import pdb
import pickle
import numpy as np
import json
import geopandas as gpd
import copy
from shapely.geometry.polygon import Polygon
from shapely.geometry import Point
from geopy.distance import great_circle
import os
import warnings
warnings.filterwarnings("ignore")
'''
line 243 : rio4326['centroid']=rio4326.centroid 
-> returns warning to indicate to use a crs with coordinates in meters,
-> the function calculating the centroid doesn't support ellipsoidal calculations.
-> However, polygons being small, the curvature of the ellipsoid doesn't have much of an impact. 
'''

owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileI = os.listdir(path+'/intermediary/')
if 'CensusTractEstado_do_Rio.json' not in FileI or 'CensusTractMatrix' not in FileI or "CensusTractPopPacified" not in FileI:
	EquivBairro={}
	EquivBairro['Cosme Velho']='cosmevelho'
	EquivBairro['Urca']='urca'
	EquivBairro['Caju']='caju'
	EquivBairro['Gamboa']='gamboa'
	EquivBairro['Saúde']='saude'
	EquivBairro['Cidade Nova']='cidadenova'
	EquivBairro['Estácio']='estacio'
	EquivBairro['Alto da Boa Vista']='altodaboavista'
	EquivBairro['Ramos']='ramos'
	EquivBairro['Olaria']='olaria'
	EquivBairro['Ipanema']='ipanema'
	EquivBairro['Leblon']='leblon'
	EquivBairro['Vidigal']='vidigal'
	EquivBairro['São Conrado']='saoconrado'
	EquivBairro['Honório Gurgel']='honoriogurgel'
	EquivBairro['Manguinhos']='manguinhos'
	EquivBairro['Penha']='penha'
	EquivBairro['Brás de Pina']='brasdepina'
	EquivBairro['São Francisco Xavier']='saofranciscoxavier'
	EquivBairro['Rocha']='rocha'
	EquivBairro['Pilares']='pilares'
	EquivBairro['Vila Kosmos']='vilakosmos'
	EquivBairro['Vila da Penha']='viladapenha'
	EquivBairro['Colégio']='colegio'
	EquivBairro['Quintino Bocaiúva']='quintinobocaiuva'
	EquivBairro['Cavalcanti']='cavalcanti'
	EquivBairro['Engenheiro Leal']='engenheiroleal'
	EquivBairro['Vaz Lobo']='vazlobo'
	EquivBairro['Gardênia Azul']='gardeniaazul'
	EquivBairro['Santíssimo']='santissimo'
	EquivBairro['Santa Cruz']='santacruz'
	EquivBairro['Senador Vasconcelos']='senadorvasconcelos'
	EquivBairro['Cosmos']='cosmos'
	EquivBairro['Jardim Carioca']='jardimcarioca'
	EquivBairro['Jardim Guanabara']='jardimguanabara'
	EquivBairro['Tauá']='taua'
	EquivBairro['Portuguesa']='portuguesa'
	EquivBairro['Freguesia (Ilha do Governador)']='freguesia_ilha'
	EquivBairro['Maré']='mare'
	EquivBairro['Ribeira']='ribeira'
	EquivBairro['Praia da Bandeira']='praiadabandeira'
	EquivBairro['Bancários']='bancarios'
	EquivBairro['Galeão']='galeao'
	EquivBairro['Cidade Universitária']='cidadeuniversitaria'
	EquivBairro['Paquetá']='paqueta'
	EquivBairro['Joá']='joa'
	EquivBairro['Itanhangá']='itanhanga'
	EquivBairro['Grumari']='grumari'
	EquivBairro['Pavuna']='pavuna'
	EquivBairro['Complexo do Alemão']='complexodoalemao'
	EquivBairro['Magalhães Bastos']='magalhaesbastos'
	EquivBairro['Camorim']='camorim'
	EquivBairro['Acari']='acari'
	EquivBairro['Barros Filho']='barrosfilho'
	EquivBairro['Parque Columbia']='parquecolumbia'
	EquivBairro['Guaratiba']='guaratiba'
	EquivBairro['Pedra de Guaratiba']='pedradeguaratiba'
	EquivBairro['Barra de Guaratiba']='barradeguaratiba'
	EquivBairro['Higienópolis']='higienopolis'
	EquivBairro['Del Castilho']='delcastilho'
	EquivBairro['Cordovil']='cordovil'
	EquivBairro['Vigário Geral']='vigariogeral'
	EquivBairro['Vila Militar']='vilamilitar'
	EquivBairro['Campo dos Afonsos']='camposdosafonsos'
	EquivBairro['Parada de Lucas']='paradadelucas'
	EquivBairro['Jardim América']='jardimamerica'
	EquivBairro['Catumbi']='catumbi'
	EquivBairro['Botafogo']='botafogo'
	EquivBairro['Tijuca']='tijuca'
	EquivBairro['Flamengo']='flamengo'
	EquivBairro['Glória']='gloria'
	EquivBairro['Catete']='catete'
	EquivBairro['Copacabana']='copacabana'
	EquivBairro['Rio Comprido']='riocomprido'
	EquivBairro['Santo Cristo']='santocristo'
	EquivBairro['Centro']='centro'
	EquivBairro['Humaitá']='humaita'
	EquivBairro['Lagoa']='lagoa'
	EquivBairro['Jardim Botânico']='jardimbotanico'
	EquivBairro['Gávea']='gavea'
	EquivBairro['Maracanã']='maracana'
	EquivBairro['Laranjeiras']='laranjeiras'
	EquivBairro['Leme']='leme'
	EquivBairro['Benfica']='benfica'
	EquivBairro['Grajaú']='grajau'
	EquivBairro['Cachambi']='cachambi'
	EquivBairro['Vasco da Gama']='vascodagama'
	EquivBairro['Mangueira']='mangueira'
	EquivBairro['São Cristóvão']='saocristovao'
	EquivBairro['Praça da Bandeira']='pracadabandeira'
	EquivBairro['Vila Isabel']='vilaisabel'
	EquivBairro['Andaraí']='andarai'
	EquivBairro['Encantado']='encantado'
	EquivBairro['Irajá']='iraja'
	EquivBairro['Cascadura']='cascadura'
	EquivBairro['Rocha Miranda']='rochamiranda'
	EquivBairro['Bento Ribeiro']='bentoribeiro'
	EquivBairro['Bonsucesso']='bonsucesso'
	EquivBairro['Penha Circular']='penhacircular'
	EquivBairro['Riachuelo']='riachuelo'
	EquivBairro['Jacaré']='jacare'
	EquivBairro['Sampaio']='sampaio'
	EquivBairro['Engenho Novo']='engenhonovo'
	EquivBairro['Lins de Vasconcelos']='linsvanconcelos'
	EquivBairro['Méier']='meier'
	EquivBairro['Todos os Santos']='todosossantos'
	EquivBairro['Engenho de Dentro']='engdentro'
	EquivBairro['Água Santa']='aguasanta'
	EquivBairro['Piedade']='piedade'
	EquivBairro['Abolição']='abolicao'
	EquivBairro['Vicente de Carvalho']='vicentedecarvalho'
	EquivBairro['Madureira']='madureira'
	EquivBairro['Campo Grande']='campogrande'
	EquivBairro['Taquara']='taquara'
	EquivBairro['Jacarepaguá']='jacarepagua'
	EquivBairro['Bangu']='bangu'
	EquivBairro['Senador Camará']='senadorcamara'
	EquivBairro['Vista Alegre']='vistaalegre'
	EquivBairro['Campinho']='campinho'
	EquivBairro['Turiaçu']='turiacu'
	EquivBairro['Oswaldo Cruz']='oswaldocruz'
	EquivBairro['Marechal Hermes']='marechalhermes'
	EquivBairro['Vila Valqueire']='vilavalqueire'
	EquivBairro['Anil']='anil'
	EquivBairro['Sepetiba']='sepetiba'
	EquivBairro['Pechincha']='pechincha'
	EquivBairro['Freguesia (Jacarepaguá)']='freguesia_jacarepagua'
	EquivBairro['Tanque']='tanque'
	EquivBairro['Praça Seca']='pracaseca'
	EquivBairro['Curicica']='curicica'
	EquivBairro['Padre Miguel']='padremiguel'
	EquivBairro['Gericinó']='gericino'
	EquivBairro['Paciência']='paciencia'
	EquivBairro['Barra da Tijuca']='barradatijuca'
	EquivBairro['Inhoaíba']='inhoaiba'
	EquivBairro['Moneró']='monero'
	EquivBairro['Guadalupe']='guadalupe'
	EquivBairro['Parque Anchieta']='parqueanchieta'
	EquivBairro['Santa Teresa']='santatereza'
	EquivBairro['Engenho da Rainha']='engrainha'
	EquivBairro['Tomás Coelho']='tomascoelho'
	EquivBairro['Zumbi']='zumbi'
	EquivBairro['Cacuia']='cacuia'
	EquivBairro['Pitangueiras']='pitangueiras'
	EquivBairro['Cocotá']='cocota'
	EquivBairro['Anchieta']='anchieta'
	EquivBairro['Ricardo de Albuquerque']='ricardodealbuquerque'
	EquivBairro['Recreio dos Bandeirantes']='recreiodosbandeirantes'
	EquivBairro['Vargem Grande']='vargemgrande'
	EquivBairro['Inhaúma']='inhauma'
	EquivBairro['Realengo']='realengo'
	EquivBairro['Vargem Pequena']='vargempequena'
	EquivBairro['Coelho Neto']='coelhoneto'
	EquivBairro['Costa Barros']='costabarros'
	EquivBairro['Maria da Graça']='mariadagraca'
	EquivBairro['Rocinha']='rocinha'
	EquivBairro['Jacarezinho']='jacarezinho'
	EquivBairro['Deodoro']='deodoro'
	EquivBairro['Jardim Sulacap']='jardimsulacap'
	EquivBairro['Cidade de Deus']='cidadededeus'

	def select_place(List1):
		'''
		List1 a list of items
		function returns the item with the most occurences
		'''
		if len(set(List1))==1:
			res = List1[0]
			return res
		else:
			df=pd.DataFrame({'Number': List1})
			df['Occur']=df.groupby('Number')['Number'].transform('size')
			df1=df[df['Occur']==df['Occur'].max()]
			List2 = df1['Number'].tolist()
			List3 = list(set((List2)))
			if List3==['N']:
				res = List3[0]
			elif 'N' in List3:
				List3.remove('N')
				res = List3[0]
			else:
				res = List3[0]
			return res

	


	with open(path+'/intermediary/UPPEstado_do_RioFinal.json','r') as output:
		geo_upp = json.load(output)

	for feature in geo_upp['features']:
		if feature['properties']['UPP']=="DoUPPMangueirinha":
			Poly_DoUPPMangueirinha = Polygon(feature['geometry']['coordinates'][0])
	del geo_upp


	with open(path+'/intermediary/PointCensusTract','rb') as output:
		AAA=pickle.load(output)
		PointCensusTract = AAA[0]
		Coordonnee = AAA[1]
		CoordonneePoint = AAA[2]
		del AAA
		del Coordonnee
		del CoordonneePoint

	with open(path+'/intermediary/Valeur','rb') as output:
		DataPoint=pickle.load(output)


	df_sinop= pd.read_csv(path+'/source/IBGE/sinop/setores2010_sinopse_RJ.csv',sep= '|',encoding='utf8')
	S_sinop=set(df_sinop['Cod_setor'])


	rio=gpd.read_file(path+'/source/IBGE/censitorios/33SEE250GC_SIR.shp' )
	rio4326 = rio.to_crs({"init":"epsg:4326"})
	rioJSON = json.loads(rio4326.to_json())
	rio4326['centroid']=rio4326.centroid

	'''
	delete census tracts without population
	'''
	k=0
	num=0
	FF=[]
	for feature in rioJSON['features']:
		k=k+1
		codigo=feature['properties']['CD_GEOCODI']
		if int(codigo) in S_sinop and df_sinop[df_sinop['Cod_setor']==int(codigo)]['V014'].values[0]!=0:
			pop = df_sinop[df_sinop['Cod_setor']==int(codigo)]['V014'].values[0]
			'''
			3304557 is ID for the city of Rio de Janeiro
			'''
			if feature['properties']['CD_GEOCODM']!="3304557":
				feature0=copy.copy(feature)
				feature0['properties']={}
				feature0['properties']['codigo']=codigo
				feature0['properties']['Bairro']=''
				feature0['properties']['Favela']=''
				feature0['properties']['UPP']='N'
				feature0['properties']['DP']=''
				feature0['properties']['City']='autre'
				feature0['properties']['Population']=str(pop)
				feature0['properties']['numero']=str(num)
				num=num+1			

				'''
				Compute centroid
				'''
				if feature['geometry']['type']=='Polygon':
					lon = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].x
					lat = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].y
					feature0['properties']['centroid_lat-lon']=(str(lat),str(lon))
				elif feature['geometry']['type']== 'MultiPolygon':
					lon = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].x
					lat = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].y
					feature0['properties']['centroid_lat-lon']=(str(lat),str(lon))
				else:
					pdb.set_trace()

				'''
				Check if inside UPP of Mangueirinha
				'''
				pointA=Point(lon,lat)
				if Poly_DoUPPMangueirinha.contains(pointA):
					feature0['properties']['UPP']='DoUPPMangueirinha'

				FF.append(feature0)

			else:
				if codigo not in PointCensusTract.keys():
					'''
					marginal issue: corresponds to small islands - five census tracts with less than 1000 inhabitants 
					'''
					pass

				else:
					B=[]
					F=[]
					U=[]
					D=[]
					V=[]
					for ide in PointCensusTract[codigo]:
						favela = PointCensusTract[codigo][ide]['Favela']
						upp = PointCensusTract[codigo][ide]['UPP']
						dp = PointCensusTract[codigo][ide]['DP']
						ville = PointCensusTract[codigo][ide]['City']

						F.append(favela)
						U.append(upp)
						D.append(dp)
						V.append(ville)


					favela0 = select_place(F)
					upp0 = select_place(U)
					dp0 = select_place(D)
					ville0 = select_place(V)


					feature0=copy.copy(feature)
					feature0['properties']={}
					feature0['properties']['codigo']=codigo
					feature0['properties']['Bairro']=EquivBairro[feature['properties']['NM_BAIRRO']]
					feature0['properties']['Favela']=favela0
					feature0['properties']['UPP']=upp0
					feature0['properties']['DP']=dp0
					feature0['properties']['City']=ville0
					feature0['properties']['Population']=str(pop)
					feature0['properties']['numero']=str(num)
					num=num+1			

					if ville0 != 'RioDeJaneiro':
						print(ville0)
						pdb.set_trace()

					
					'''
					Compute centroid
					'''
					if feature['geometry']['type']=='Polygon':
						lon = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].x
						lat = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].y
						feature0['properties']['centroid_lat-lon']=(str(lat),str(lon))
					elif feature['geometry']['type']== 'MultiPolygon':
						lon = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].x
						lat = rio4326[rio4326['CD_GEOCODI']==codigo]['centroid'].values[0].y
						feature0['properties']['centroid_lat-lon']=(str(lat),str(lon))
					else:
						pdb.set_trace()

					'''
					Check if inside UPP of Mangueirinha
					'''
					pointA=Point(lon,lat)
					if Poly_DoUPPMangueirinha.contains(pointA):
						feature0['properties']['UPP']='DoUppMangueirinha'
						print('impossible !')
						pdb.set_trace()
					
					FF.append(feature0)
			
		
		else:
			'''
			no population or equal to 0
			'''
			pass 
			
	rioJSON['features']=FF
	with open(path+'/intermediary/CensusTractEstado_do_Rio.json','w') as output:
		json.dump(rioJSON,output)
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
	# Creation of matrix with distance between census tracts of the state of rio de janeiro & Adding information such as date of pacification
	#########################################################################################################################################
	#########################################################################################################################################
	def cal_distance(var0):
		''' 
		if var = 0 : between 0 and 100 meters; 
		var = 1 : between 100 and 200 meters;
		... ; 
		var = 119 : between 11900 and 12000 meters; 
		var = -1 : more than 12000 meters
		'''
		var=int(var0/100)
		if var<120:
			return var
		else:
			return -1

	with open(path+'/intermediary/CensusTractEstado_do_Rio.json','r') as output:
		rioJSON = json.load(output)

	Population={}
	Coordonnee={}
	CoordonneePoint={}
	Temp={}
	for feature in rioJSON['features']:
		num = int(feature['properties']['numero'])
		pop = float(feature['properties']['Population'])	
		lat = float(feature['properties']['centroid_lat-lon'][0])
		lon = float(feature['properties']['centroid_lat-lon'][1])
		Population[num]=pop
		Coordonnee[num]=(lon,lat)
		CoordonneePoint[num]=Point(lon,lat)
		Temp[num]=(lat,lon)

	'''
	mon_np matrix of distances between census tracts
	'''
	l0=len(rioJSON['features'])
	mon_np=np.zeros((l0,l0),dtype='int8')	
	mon_np=np.where(mon_np==0,-2,mon_np)

	num0=0
	while num0<l0:
		#print(num0)
		G0 = Temp[num0]
		num1=num0
		while num1<l0:
			if num0==num1:
				dist = 0
			else:
				G1 = Temp[num1]
				dist = cal_distance(great_circle(G0,G1).meters)
			
			mon_np[num0][num1]=dist
			mon_np[num1][num0]=dist

			num1=num1+1

		num0=num0+1

	'''
	Pacified comes from /preprocessed/UPP_Data.csv
	'''
	Pacified={'DoUppSantaMarta': 25, 'DoUppBatan': 27, 'DoUppCdd': 27, 'DoUppChapeuMangueiraEBabilonia': 30, 'DoUppPavaoPavaozinho': 37, 'DoUppTabajaras': 37, 'DoUppProvidencia': 41, 'DoUppBorel': 42, 'DoUppAndarai': 44, 'DoUppFormiga': 43, 'DoUppSalgueiro': 46, 'DoUppTurano': 47, 'DoUppMacacos': 48, 'DoUppSaoJoaoQuietoMatriz': 50, 'DoUppCoroaFalletFogueteiro': 51, 'DoUppEscondidinhoEPrazeres': 51, 'DoUppMangueira': 59, 'DoUppSaoCarlos': 54, 'DoUppVidigal': 62, 'DoUppFazendinha': 65, 'DoUppNovaBrasilia': 65, 'DoUppAdeusBaiana': 65, 'DoUppAlemao': 66, 'DoUppChatuba': 67, 'DoUppFeSereno': 67, 'DoUppParqueProletario': 69, 'DoUppVilaCruzeiro': 69, 'DoUppRocinha': 70, 'DoUppJacarezinho': 74, 'DoUppManguinhos': 74, 'DoUppAraraMandela': 81, 'DoUppBarreiraVascoTuiuti': 76, 'DoUppCaju': 76, 'DoUppCerroCora': 78, 'DoUppCamaristaMeier': 84, 'DoUppLins': 84, 'DoUppVilaKennedy': 90, 'DoUPPMangueirinha': 86}
	DatePacification=[]
	for feature in rioJSON['features']:
		num = int(feature['properties']['numero'])
		upp =feature['properties']['UPP']
		'''
		pacification = 127 if not pacified
		'''
		if upp=='N':
			pacification = 127	
		elif upp in ['DoUppMare_Holanda_Parque Uniao','DoUppMare_PraiadeRamos_RoquetePinto','DoUppMare_Vila do Joao_Pinheiros', 'DoUppMare_BaixadoSapateiro_Timbau']:
			pacification = 127
		else:
			pacification = Pacified[upp]
		DatePacification.append(pacification)

	l0=len(rioJSON['features'])
	mon_np_pacification=np.zeros((l0),dtype='int8')	
	num=0
	while num<l0:
		mon_np_pacification[num]=DatePacification[num]
		num=num+1


	with open(path+'/intermediary/CensusTractMatrix','wb') as output:
		pickle.dump((Population,Coordonnee,CoordonneePoint,mon_np,mon_np_pacification),output)
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
	# compute total Population and pacified population at a given distance of censustracts
	#########################################################################################################################################
	#########################################################################################################################################
	with open(path+'/intermediary/CensusTractMatrix','rb') as output:
		AAA=pickle.load(output)

	Population=AAA[0]
	mon_np=AAA[3]
	mon_np_pacification=AAA[4]

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
	del Population


	np_pop_total=np.zeros((l0,120))
	np_pop_total=np.where(np_pop_total==0,-2,np_pop_total)
	np_pop_total_pacified=np.zeros((l0,120,114))
	np_pop_total_pacified=np.where(np_pop_total_pacified==0,-2,np_pop_total_pacified)
	num=0	

	while num<l0:
		#print(num)
		mon_np0=mon_np[num]
		for dis in range(0,120):
			'''
			np_pos returns position of elements which are at a distance "dis" of the census tract "num"
			'''
			np_pos=np.where(mon_np0 == dis)[0]
			'''
			np.take(np_pop,np_pos) takes elements in np_pop taking into account their position as indicated in np_pos
			'''
			pop0=np.take(np_pop,np_pos).sum()
			np_pop_total[num][dis]=pop0
			for t in range(0,114):
				date=t+1
				'''
				np_pos_pacified returns position of elements which are at a distance "dis" of the census tract "num" & that have pacified before (or at) "date"
				'''
				np_pos_pacified=np.where((mon_np0 == dis)&(mon_np_pacification<=date))[0] 
				pop0=np.take(np_pop,np_pos_pacified).sum()
				np_pop_total_pacified[num][dis][t]=pop0


		num=num+1

	with open(path+'/intermediary/CensusTractPopPacified','wb') as output:
		pickle.dump((np_pop_total,np_pop_total_pacified),output)


