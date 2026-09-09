import csv
import pdb
import pickle
import os

# create path
owd = os.getcwd()
path = '/'.join(owd.split('/')[:-1])+'/data'

FileI = os.listdir(path+'/intermediary')
if 'DP_Crime.csv' not in FileI:
	# name of crime: portuguese - english
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

	Link={}
	
	Link['12']=['12']
	Link['13']=['13']
	Link['1']=['1']
	Link['4']=['4']
	Link['5']=['5']
	Link['16 e 42']=['16','42']
	Link['15 e 11']=['15','11']
	Link['22 e 45']=['22','45']
	Link['65 e 67']=['65','67']
	Link['71 e 70']=['71','70']
	Link['126 e 132']=['126','132']
	Link['143 e 148']=['143','148']
	Link['123 e 130']=['123','130']
	Link['101']=['101']
	Link['58']=['58']
	Link['19']=['19']
	Link['43']=['43']
	Link['62']=['62']
	Link['112']=['112']
	Link['25']=['25']
	Link['33']=['33']
	Link['152']=['152']
	Link['146']=['146']
	Link['74']=['74']
	Link['108']=['108']
	Link['151']=['151']
	Link['159']=['159']
	Link['40']=['40']
	Link['14']=['14']
	Link['6']=['6']
	Link['127']=['127']
	Link['157']=['157']
	Link['124']=['124']
	Link['72']=['72']
	Link['31']=['31']
	Link['129']=['129']
	Link['99']=['99']
	Link['168']=['168']
	Link['119']=['119']
	Link['156']=['156']
	Link['59']=['59']
	Link['153']=['153']
	Link['90']=['90']
	Link['147']=['147']
	Link['141']=['141']
	Link['167']=['167']
	Link['41']=['41']
	Link['55']=['55']
	Link['38']=['38']
	Link['128']=['128']
	Link['81']=['81']
	Link['105']=['105']
	Link['136']=['136']
	Link['96']=['96']
	Link['60']=['60']
	Link['34']=['34']
	Link['53']=['53']
	Link['24']=['24']
	Link['21']=['21']
	Link['27']=['27']
	Link['82']=['82']
	Link['140']=['140']
	Link['7']=['7']
	Link['52']=['52']
	Link['57']=['57']
	Link['110']=['110']
	Link['144']=['144']
	Link['165']=['165']
	Link['111']=['111']
	Link['118']=['118']
	Link['18']=['18']
	Link['91']=['91']
	Link['61']=['61']
	Link['48']=['48']
	Link['139']=['139']
	Link['35']=['35']
	Link['32']=['32']
	Link['73']=['73']
	Link['107']=['107']
	Link['39']=['39']
	Link['98']=['98']
	Link['135']=['135']
	Link['137']=['137']
	Link['138']=['138']
	Link['54']=['54']
	Link['64']=['64']
	Link['125']=['125']
	Link['79']=['79']
	Link['97']=['97']
	Link['23']=['23']
	Link['166']=['166']
	Link['9']=['9']
	Link['121']=['121']
	Link['26']=['26']
	Link['10']=['10']
	Link['155']=['155']
	Link['51']=['51']
	Link['94']=['94']
	Link['92']=['92']
	Link['20']=['20']
	Link['66']=['66']
	Link['104']=['104']
	Link['30']=['30']
	Link['63']=['63']
	Link['93']=['93']
	Link['75']=['75']
	Link['134']=['134']
	Link['120']=['120']
	Link['122']=['122']
	Link['50']=['50']
	Link['56']=['56']
	Link['88']=['88']
	Link['37']=['37']
	Link['142']=['142']
	Link['95']=['95']
	Link['17']=['17']
	Link['28']=['28']
	Link['36']=['36']
	Link['29']=['29']
	Link['89']=['89']
	Link['109']=['109']
	Link['154']=['154']
	Link['78']=['78']
	Link['106']=['106']
	Link['145']=['145']
	Link['44']=['44']
	Link['158']=['158']
	Link['77']=['77']
	Link['100']=['100']
	Link['76']=['76']


	List_CrimeDP=["homicideintentional","bodyinjurydeathfollowed","robberydeathfollowed","attemptedmurder","bodyinjuryintentional","rape","homicidenointentional",
	"bodyinjurynointentional","deadbodyfound","bonesfound","storerobbery","homerobbery","carrobbery","boatrobbery","passerbyrobbery","collectiverobbery",
	"bankrobbery","atmrobbery","mobilephonerobbery","robberywithdrivingtotakeoutinatm","cartheft","extortionwithkidnapping","extortion","extortionwithmomentarykidnapping",
	"fraud","drugarrest","carrecovery","threat","persondisappearance","resistancetodeathofpoliceopponent","deathofmilitarypolice","deathofcivilpolice","totalrobbery","totaltheft","eventsregistration"]


	Base={}
	with open(path+"/source/ISP/BaseDPEvolucaoMensalCisp.csv", "r",encoding='latin1') as infile:
		data=csv.reader(infile,delimiter=';',lineterminator='\n')
		for index, row in enumerate(data):
			if index == 0:
				row0 = row
			else:
				dp = row[0]
				if dp not in Base.keys():
					Base[dp]={}

				mes = str(row[1])
				ano = str(row[2])
				if int(ano)<2007 or int(ano)>2018:
					1
				else:
					if ano not in Base[dp].keys():
						Base[dp][ano]={}
					if mes not in Base[dp][ano].keys():
						Base[dp][ano][mes]={}

					j = 9
					while j<len(row):
						if row0[j] in Dict_Crime.keys():
							crime = Dict_Crime[row0[j]]
							val_crime = row[j]
							Base[dp][ano][mes][crime]=val_crime

						j = j + 1


	BaseMerge={}
	for dp in Link.keys():
		BaseMerge[dp]={}
		for y in range(2007,2019):
			y=str(y)
			BaseMerge[dp][y]={}
			for m in range(1,13):
				m = str(m)
				BaseMerge[dp][y][m]={}
				for crime in List_CrimeDP:
					val = 0
					for d in Link[dp]:
						try:
							int(Base[d][y][m][crime])
							val = val + int(Base[d][y][m][crime])
						except:
							'''
							missing data - very few data less than 10 for atmrobbery
							'''
							val = val + 0 
					BaseMerge[dp][y][m][crime]=str(val)





	with open(path+"/intermediary/DP_Crime.csv", "w",encoding='utf-8') as outfile:
		data=csv.writer(outfile,delimiter=',',lineterminator='\n')
		row = ['dp','date','homicideintentional','bodyinjurydeathfollowed','robberydeathfollowed','attemptedmurder','bodyinjuryintentional','rape','homicidenointentional','bodyinjurynointentional','deadbodyfound','bonesfound','storerobbery','homerobbery','carrobbery','boatrobbery','passerbyrobbery','collectiverobbery','bankrobbery','atmrobbery','mobilephonerobbery','robberywithdrivingtotakeoutinatm','cartheft','extortionwithkidnapping','extortion','extortionwithmomentarykidnapping','fraud','drugarrest','carrecovery','threat','persondisappearance','resistancetodeathofpoliceopponent','deathofmilitarypolice','deathofcivilpolice','totalrobbery','totaltheft','eventsregistration']
		data.writerow(row)
		for dp in Link.keys():
			date = 1
			for y in range(2007,2019):
				y = str(y)
				for m in range(1,13):
					m = str(m)
					# We study up to june 2016 
					if date<=114:
						row=[str(dp),date]
						for c in List_CrimeDP:
							row.append(BaseMerge[dp][y][m][c])
						date=date+1
						data.writerow(row)



