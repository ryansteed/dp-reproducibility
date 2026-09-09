import csv
import json
import folium
import pdb
import os

owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

Equiv={}
Equiv['DoUppSantaMarta']='UPP Santa Marta'
Equiv['DoUppBatan']='UPP Batan'
Equiv['DoUppCdd']='UPP Cidade de Deus'
Equiv['DoUppChapeuMangueiraEBabilonia']='UPP Chapéu Mangueira / Babilônia'
Equiv['DoUppPavaoPavaozinho']='UPP Pavão-Pavãozinho / Cantagalo'
Equiv['DoUppTabajaras']='UPP Tabjaras / Cabritos'
Equiv['DoUppProvidencia']='UPP Providência'
Equiv['DoUppBorel']='UPP Borel'
Equiv['DoUppAndarai']='UPP Andaraí'
Equiv['DoUppFormiga']='UPP Formiga'
Equiv['DoUppSalgueiro']='UPP Salgueiro'
Equiv['DoUppTurano']='UPP Turano'
Equiv['DoUppMacacos']='UPP Macacos'
Equiv['DoUppSaoJoaoQuietoMatriz']='UPP São João'
Equiv['DoUppCoroaFalletFogueteiro']='UPP Fallet / Fogueteiro / Coroa'
Equiv['DoUppEscondidinhoEPrazeres']='UPP Escondidinho / Prazeres'
Equiv['DoUppMangueira']='UPP Mangueira'
Equiv['DoUppSaoCarlos']='UPP São Carlos'
Equiv['DoUppVidigal']='UPP Vidigal / Chácara do Céu'
Equiv['DoUppFazendinha']='UPP Fazendinha'
Equiv['DoUppNovaBrasilia']='UPP Nova Brasília'
Equiv['DoUppAdeusBaiana']='UPP Adeus / Baiana'
Equiv['DoUppAlemao']='UPP Alemão'
Equiv['DoUppChatuba']='UPP Chatuba'
Equiv['DoUppFeSereno']='UPP Fé / Sereno'
Equiv['DoUppParqueProletario']='UPP Vila Proletária da Penha'
Equiv['DoUppVilaCruzeiro']='UPP Vila Cruzeiro'
Equiv['DoUppRocinha']='UPP Rocinha'
Equiv['DoUppJacarezinho']='UPP Jacarezinho'
Equiv['DoUppManguinhos']='UPP Manguinhos'
Equiv['DoUppAraraMandela']='UPP Manguinhos - Arará / Mandela'
Equiv['DoUppBarreiraVascoTuiuti']='UPP Barreira do Vasco / Tuiuti'
Equiv['DoUppCaju']='UPP Caju'
Equiv['DoUppCerroCora']='UPP Cerro-Corá'
Equiv['DoUppCamaristaMeier']='UPP Camarista Méier'
Equiv['DoUppLins']='UPP Lins'
Equiv['DoUppVilaKennedy']='UPP Vila Kennedy'
Equiv['DoUppMangueirinha']=''
Equiv['DoUppMare']=''

'''
FIGURE 2 Location of UPPs, favelas, Olympic Games facilities, main tourist areas, and the international airport
'''

lat=-22.925
lon=-43.4146
macarte = folium.Map(location=[lat,lon], zoom_start=11.5)
folium.TileLayer("stamenterrain").add_to(macarte)


# favela
with open(path+'{}'.format('/source/RioPrefeitura/Limite_Favelas_2010.geojson'),'r') as gd:
	geo_data_favela = json.load(gd)

folium.GeoJson(geo_data_favela,style_function=lambda feature: {'color': 'black','fillColor': 'orange', 'weight' : 0.6, 'fillOpacity' : 1}).add_to(macarte)


# upp
with open(path+'{}'.format('/source/RioPrefeitura/Limiteupp_arcgis.geojson'),'r') as gd:
	geo_data_UPP = json.load(gd)
	
A=[]
for feature in geo_data_UPP['features']:
	if feature['properties']['Nome'] not in ['UPP Baixa do Sapateiro / Timbau','UPP Praia de Ramos / Roquete Pinto','UPP Vila do João / Pinheiros','UPP Nova Holanda / Parque União']:
		A.append(feature)
geo_data_UPP['features']=A
folium.GeoJson(geo_data_UPP,style_function=lambda feature: {'color': 'black','fillColor': 'red', 'weight' : 0.6, 'fillOpacity' : 1}).add_to(macarte)


# site sport 
SiteS=[(-22.858402, -43.409678, 'National Shooting Centre'), (-22.861868, -43.403559, 'Modern Pentathlon Aquatic Centre'), (-22.869513, -43.405931, 'National Equestrian Centre'), (-22.979053, -43.413193, 'Riocentro - Pavilions 2, 3, 4, & 6'), (-22.974497, -43.387971, 'Rio Olympic Park - Maria Lenk Aquatic Centre'), (-22.89323, -43.292636, 'Joao Havelange Olympic Stadium'), (-22.912201, -43.196339, 'Sambodromo'), (-22.914192, -43.229466, 'Maracanazinho Arena'), (-22.912124, -43.230055, 'Maracana Stadium'), (-22.917231, -43.170876, 'Marina da Gloria'), (-22.972245, -43.212238, 'Lagoa Rodrigo de Freitas'), (-22.859469, -43.404064, 'Deodoro Arena'), (-22.841418, -43.415795, 'Rio X Park (Olympic BMX Center)'), (-23.007438, -43.400323, 'Reserva Marapendi Golf Course'), (-22.864795, -43.413352, 'Deodoro Modern Pentathlon Arena'), (-22.919482, -43.172172, 'Flamengo Park'), (-22.96942, -43.180711, 'Copacabana Stadium'), (-22.986156, -43.186292, 'Fort Copacabana')]

for k in SiteS:
	y=k[1] # lat
	x=k[0] # lon
	folium.CircleMarker([x,y],color='purple',fill=True,fill_color='purple',radius=10).add_to(macarte)
	
# aeroport
folium.RegularPolygonMarker([-22.80999,-43.249],color='green',fill_color='green',number_of_sides=6,radius=16,opacity=1,fill_opacity=0.5).add_to(macarte)


# corcovado
folium.RegularPolygonMarker([-22.9525,-43.211],color='blue',fill_color='blue',number_of_sides=3,radius=16,opacity=1,fill_opacity=1,rotation=90).add_to(macarte)

# pain de sucre
folium.RegularPolygonMarker([-22.94972,-43.156],color='blue',fill_color='blue',number_of_sides=3,radius=16,opacity=1,fill_opacity=1,rotation=90).add_to(macarte)

# copacabana
folium.RegularPolygonMarker([-22.9754,-43.185],color='blue',fill_color='blue',number_of_sides=3,radius=16,opacity=1,fill_opacity=1,rotation=90).add_to(macarte)

# ipanema
folium.RegularPolygonMarker([-22.985,-43.205],color='blue',fill_color='blue',number_of_sides=3,radius=16,opacity=1,fill_opacity=1,rotation=90).add_to(macarte)


macarte.save(path.replace('/data','/results')+'/figure2.html')


##################################################################################
##################################################################################
##################################################################################
##################################################################################
##################################################################################
'''
FIGURE B1 Geographic distribution of UPPs over time
'''
Pacification={}
with open(path+'{}'.format('/preprocessed/UPP_Data.csv'), "r") as infile:
	data=csv.reader(infile,delimiter=',')
	for index, row in enumerate(data):
		if index==0:
			1
		else:
			upp = row[0]
			if upp not in ['DoUppMangueirinha','DoUppMare']:

				date=int(row[6])

				if date not in Pacification.keys():
					Pacification[date]=[]
		
				Pacification[date].append(Equiv[upp])


Pacification2={}
for date in range(0,120):
	if date in Pacification.keys():
		A=[]
		for t in range(1,date+1):
			if t in Pacification.keys():
				for u in Pacification[t]:
					if u not in A:
						A.append(u)
		Pacification2[t]=[]
		for a in A:
			Pacification2[t].append(a)
Pacification2[18]=[]

L={}
L[18]='june2008'
L[27]='march2009'
L[44]='august2010'
L[48]='december2010'
L[54]='june2011'
L[67]='july2012'
L[81]='september2013'
L[90]='june2014'				
for date in L.keys():
	macarte = folium.Map(location=[-22.94,-43.42], zoom_start=11.5)
	folium.TileLayer("stamenterrain").add_to(macarte)

	# favela
	with open(path+'{}'.format('/source/RioPrefeitura/Limite_Favelas_2010.geojson'),'r') as gd:
		geo_data_favela = json.load(gd)
	folium.GeoJson(geo_data_favela,style_function=lambda feature: {'color': 'black','fillColor': 'yellow', 'weight' : 0.6, 'fillOpacity' : 1}).add_to(macarte)


	# upp
	with open(path+'{}'.format('/source/RioPrefeitura/Limiteupp_arcgis.geojson'),'r') as gd:
		geo_data_UPP = json.load(gd)
	
	A = []
	for feature in geo_data_UPP['features']:
		upp = feature['properties']['Nome']
		if upp in Pacification2[date]:
			A.append(feature)

	geo_data_UPP['features']=A
	if A!=[]:
		folium.GeoJson(geo_data_UPP,style_function=lambda feature: {'color': 'black','fillColor': 'red', 'weight' : 0.6, 'fillOpacity' : 1}).add_to(macarte)

	macarte.save(path.replace('/data','/results')+'/figureB1_{}.html'.format(L[date]))
	


##################################################################################
##################################################################################
##################################################################################
##################################################################################
##################################################################################
'''
Figure Q.1: Mapping between districts and UPPs
'''
macarte = folium.Map(location=[-22.94,-43.42], zoom_start=11.5)
# openstreetmap,stamenterrain, Mapbox Control Room, stamenwatercolor, stamen toner
folium.TileLayer("stamenterrain").add_to(macarte)

# districts
with open(path+'{}'.format('/intermediary/DPEstado_do_RioFinal.json'),'r') as gd:
	geo_data_DP = json.load(gd)

AA = []
for feature in geo_data_DP['features']:
	dp = feature['properties']['DP']
	# list of dp in the city of rio de janeiro
	if dp in ['35', '21', '41', '32', '33', '34', '29', '30', '40', '28', '18', '20', '19', '23', '24', '25', '44', '26', '38', '27', '5', '39', '31', '43', '36', '15 e 11', '22 e 45', '16 e 42', '13', '12', '10', '7', '14', '4', '9', '1', '37', '17', '6']:
		AA.append(feature)
geo_data_DP['features']=AA
folium.GeoJson(geo_data_DP,style_function=lambda feature: {'color': 'blue','fillColor': 'grey', 'weight' : 1, 'fillOpacity' : 0.0}).add_to(macarte)

# upp
with open(path+'{}'.format('/source/RioPrefeitura/Limiteupp_arcgis.geojson'),'r') as gd:
	geo_data_UPP = json.load(gd)
	
A=[]
for feature in geo_data_UPP['features']:
	if feature['properties']['Nome'] not in ['UPP Baixa do Sapateiro / Timbau','UPP Praia de Ramos / Roquete Pinto','UPP Vila do João / Pinheiros','UPP Nova Holanda / Parque União']:
		A.append(feature)
geo_data_UPP['features']=A
folium.GeoJson(geo_data_UPP,style_function=lambda feature: {'color': 'black','fillColor': 'red', 'weight' : 0.6, 'fillOpacity' : 1}).add_to(macarte)


macarte.save(path.replace('/data','/results')+'/figureQ1.html')
