import csv
import os
import numpy as np

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileP=os.listdir(path+'/preprocessed')
if 'UPP_Crime.csv' not in FileP:
	Link={}
	Link['Santa Marta']='DoUppSantaMarta'
	Link['Cidade de Deus']='DoUppCdd'
	Link['Batam']='DoUppBatan'
	Link['Chapéu Mangueira / Babilônia']='DoUppChapeuMangueiraEBabilonia'
	Link['Pavão-Pavãozinho']='DoUppPavaoPavaozinho'
	Link['Tabajaras']='DoUppTabajaras'
	Link['Providência']='DoUppProvidencia'
	Link['Borel']='DoUppBorel'
	Link['Formiga']='DoUppFormiga'
	Link['Andaraí']='DoUppAndarai'
	Link['Salgueiro']='DoUppSalgueiro'
	Link['Turano']='DoUppTurano'
	Link['São João / Matriz / Queto']='DoUppSaoJoaoQuietoMatriz'
	Link['Coroa / Fallet / Fogueteiro']='DoUppCoroaFalletFogueteiro'
	Link['Escondidinho / Prazeres']='DoUppEscondidinhoEPrazeres'
	Link['São Carlos']='DoUppSaoCarlos'
	Link['Mangueira']='DoUppMangueira'
	Link['Macacos']='DoUppMacacos'
	Link['Vidigal']='DoUppVidigal'
	Link['Nova Brasília']='DoUppNovaBrasilia'
	Link['Fazendinha']='DoUppFazendinha'
	Link['Adeus / Baiana']='DoUppAdeusBaiana'
	Link['Alemão']='DoUppAlemao'
	Link['Chatuba']='DoUppChatuba'
	Link['Fé / Sereno']='DoUppFeSereno'
	Link['Parque Proletário']='DoUppParqueProletario'
	Link['Vila Cruzeiro']='DoUppVilaCruzeiro'
	Link['Rocinha']='DoUppRocinha'
	Link['Jacarezinho']='DoUppJacarezinho'
	Link['Manguinhos']='DoUppManguinhos'
	Link['Barreira do Vasco / Tuiuti']='DoUppBarreiraVascoTuiuti'
	Link['Caju']='DoUppCaju'
	Link['Cerro-Corá']='DoUppCerroCora'
	Link['Arará / Mandela']='DoUppAraraMandela'
	Link['Lins']='DoUppLins'
	Link['Camarista Méier']='DoUppCamaristaMeier'
	Link['Vila Kennedy']='DoUppVilaKennedy'
	Link["Mangueirinha"]="DoUppMangueirinha"

	List_UPP=[]
	for upp in Link.keys():
		List_UPP.append(Link[upp])

	'''
	Dict_Crime - headings of crime: portuguese - english
	'''
	Dict_Crime={}
	Dict_Crime['hom_doloso']='homicideintentional'
	Dict_Crime['lesao_corp_morte']='bodyinjurydeathfollowed'
	Dict_Crime['latrocinio']= 'robberydeathfollowed'
	Dict_Crime['tentat_hom']= 'attemptedmurder'
	Dict_Crime['lesao_corp_dolosa']= 'bodyinjuryintentional'
	Dict_Crime['estupro']= 'rape'
	Dict_Crime['hom_culposo']= 'homicidenointentional'
	Dict_Crime['lesao_corp_culposa']= 'bodyinjurynointentional'
	Dict_Crime['encontro_cadaver']= 'deadbodyfound'
	Dict_Crime['encontro_ossada']= 'bonesfound'
	Dict_Crime['roubo_comercio']= 'storerobbery'
	Dict_Crime['roubo_residencia']= 'homerobbery'
	Dict_Crime['roubo_veiculo']= 'carrobbery' 
	Dict_Crime['roubo_carga']= 'boatrobbery' 
	Dict_Crime['roubo_transeunte']= 'passerbyrobbery'
	Dict_Crime['roubo_em_coletivo']= 'collectiverobbery'
	Dict_Crime['roubo_banco']= 'bankrobbery'
	Dict_Crime['roubo_cx_eletronico']= 'atmrobbery' 
	Dict_Crime['roubo_celular']='mobilephonerobbery'
	Dict_Crime['roubo_conducao_saque']= 'robberywithdrivingtotakeoutinatm' 
	Dict_Crime['furto_veiculos']= 'cartheft' 
	Dict_Crime['sequestro']= 'extortionwithkidnapping'
	Dict_Crime['extorsao']= 'extortion'
	Dict_Crime['sequestro_relampago']= 'extortionwithmomentarykidnapping' 
	Dict_Crime['estelionato']='fraud' 
	Dict_Crime['apreensao_drogas']= 'drugarrest'
	Dict_Crime['armas_apreendidas']= 'armarrest'
	Dict_Crime['recuperacao_veiculos']= 'carrecovery'
	Dict_Crime['cump_mandado_prisao']= 'compliancewarrantofarrest'
	Dict_Crime['ocorr_flagrante']= 'occurrenceswithflagrante'
	Dict_Crime['ameaca']= 'threat'
	Dict_Crime['pessoas_desaparecidas']= 'persondisappearance' 
	Dict_Crime['hom_por_interv_policial']='resistancetodeathofpoliceopponent' 
	Dict_Crime['pol_militares_mortos_serv']='deathofmilitarypolice'
	Dict_Crime['pol_civis_mortos_serv']='deathofcivilpolice' 
	Dict_Crime['total_roubos']= 'totalrobbery' 
	Dict_Crime['total_furtos']= 'totaltheft' 
	Dict_Crime['registro_ocorrencias']='eventsregistration'

	List_Crime=[]
	for crime in Dict_Crime.keys():
		List_Crime.append(Dict_Crime[crime])

	Eq_Date={}
	i = 1
	for y in range(2007,2019):
		y = str(y)
		Eq_Date[y]={}
		for m in range(1,13):
			m = str(m)
			Eq_Date[y][m]= str(i)
			i = i + 1

	Base={}
	with open(path+"/source/ISP/UppEvolucaoMensalDeTitulos.csv", "r",encoding='latin1') as infile:
		data=csv.reader(infile,delimiter=';',lineterminator='\n')
		for index, row in enumerate(data):
			if index == 0:
				row0 = row
			else:
				upp = Link[row[1]]
				if upp not in Base.keys():
					Base[upp]={}

				ano = str(row[2])
				if ano not in Base[upp].keys():
					Base[upp][ano]={}

				mes = str(row[3])
				if mes not in Base[upp][ano].keys():
					Base[upp][ano][mes]={}

				j = 4
				while j<len(row):
					crime = Dict_Crime[row0[j]]
					val_crime = row[j]
					Base[upp][ano][mes][crime]=val_crime
					j = j + 1
	 



	with open(path+"/preprocessed/UPP_Crime.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter=',',lineterminator='\n')
		row0=["upp","year","month","date","homicideintentional","bodyinjurydeathfollowed","robberydeathfollowed","attemptedmurder","bodyinjuryintentional","rape",
		"homicidenointentional","bodyinjurynointentional","deadbodyfound","bonesfound","storerobbery","homerobbery","carrobbery","boatrobbery","passerbyrobbery",
		"collectiverobbery","bankrobbery","atmrobbery","mobilephonerobbery","robberywithdrivingtotakeoutinatm","cartheft","extortionwithkidnapping","extortion",
		"extortionwithmomentarykidnapping","fraud","drugarrest","armarrest","carrecovery","compliancewarrantofarrest","occurrenceswithflagrante","threat",
		"persondisappearance","resistancetodeathofpoliceopponent","deathofmilitarypolice","deathofcivilpolice","totalrobbery","totaltheft","eventsregistration"]
		data.writerow(row0)

		for upp in List_UPP:
			for y in range(2007,2017):
				y = str(y)
				# We study up to june 2016 
				if y == '2016':
					month_max = 7
				else:
					month_max = 13

				for m in range(1,month_max):
					m = str(m)
					date = Eq_Date[y][m]
					row=[upp,y,m,date]
					for crime in List_Crime:
						row.append(Base[upp][y][m][crime])

					data.writerow(row)


		'''
		Add missing data for Mare because not pacified
		'''
		for upp in ['DoUppMare']:
			for y in range(2007,2017):
				y = str(y)
				# We study up to june 2016 
				if y == '2016':
					month_max = 7
				else:
					month_max = 13

				for m in range(1,month_max):
					m = str(m)
					date = Eq_Date[y][m]
					row=[upp,y,m,date]
					for crime in List_Crime:
						row.append(np.nan)

					data.writerow(row)


