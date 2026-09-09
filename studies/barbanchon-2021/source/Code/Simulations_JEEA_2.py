""" Simulations

This file simulates the model of political selection in Le Barbanchon and Sauvagnat (2018)
 to replicate Figure B.2 

It has the same structure as simulations_JEEA.py (see its header for more information).

The user only needs to run the whole file to replicate Figure B.2

after updating the file path "D:\Dropbox\Elections\Mathieu\" in lines 506 and 542

    
////////////////////////////////////////////////////////////
1/ INITIALIZATION """

# Definition of the cost of fine, the party bias/cost of 
# authority, and the maximum value for valences
c=0.004
#c=0

B=0.00 # for figure 4 (previously 5)
#B=0.0035 # for figure B.1 and party bias simulations

theta=0.05

# Definition of the popularity schock, and of the 
# variance of the distribution of Zk
sigma=0.06 # true value : 0.06 ; for nice graphs : 0.3
#sigma=0.2 # for figure 2
#sigma=0.1 # for figure 3 and B.1

sigmabis=0.16
# higher competition
#sigmabis=0.14
#lower competition
sigmabis=0.18


#Numbers of values computed for Zk, b and c
N=60
acc=75
Nc=3


#Precision of computations of the CDF
precis=0.00005

# Useful packages are imported.
import math
import numpy as np #to work with arrays
import pylab as plt #for basic plots
import pandas as pd 
import time
from mpl_toolkits.mplot3d import Axes3D #for plots in 3D
import pickle #saves and imports variables
import warnings
warnings.filterwarnings("ignore")

#Definition of the arrays of Z, b and c
vectorz=np.linspace(-1,1.,N)
vectorb=np.linspace(0,0.06,acc)
vectorc=np.linspace(0,2*c,Nc)

# Basic computation of a gaussian distribution
def gaussian(t,sigma):
	return(1/(sigma*math.sqrt(2*math.pi))*math.exp(-(t**2)/(2*(sigma**2))))

Sum_gaussian=0
for i in range(N):
    Sum_gaussian+=gaussian(vectorz[i],sigmabis)

# For the program to be efficient, a limited amount
# of values of the CDF are calculated and saved in a file
# This operation is to be done only once, afterwards the
# list of values is direclty downloaded from the file
Num=int(1/precis)*100
precision=1.5/Num

t=time.time()
CDF=[0.5]
for i in range(1,Num):
    CDF += [CDF[i-1]+precision*gaussian(i*precision,sigma)]
print(time.time()-t)
"""
with open('CDF', 'wb') as fichier:
     pickler = pickle.Pickler(fichier)
     pickler.dump(CDF)

# The list of values of the CDF are downloaded
with open('CDF', 'rb') as fichier:
     pickler = pickle.Unpickler(fichier)
     CDF = pickler.load()
""" 
# Here we match the desired value of the CDF with the
# closest value in the list previously computed.
# If a bit of precision is lost, the program runs
# dramatically faster, allowing for more precision on
# other variables
def cdf(t):
    if t>=0:
        return(CDF[int(t/precision)])
    else:
        return(1-cdf(-t))

def f(z,b): 
    if b==0:
        return(0) #just a gain of time
    return(cdf(z)-cdf(z-b))


"""////////////////////////////////////////////////////////
2/ QUOTA BINDING """

# First step is to determine if parties want to field a 
# woman or not. The two following functions derive the 
# strategic interactions between both parties.

# Strategy is called with all the parameters of a specific
# strategic interaction : w, b, the valence of all four
# candidates and c. This function computes the seven 
# comparisons which matter and sends them to solve.
# The output is a vector with 7 elements, each correspodinng 
# to a comparison to make.

# Solve uses the value of the seven comparisons to solve
# the Bayesian game as shown in appendix of the paper.
# It averages over whether party R plays first or second.
# The output is a vector with 2 elements:
# 0. share of woman fielded by party R (averaged over playing order)
# 1. share of woman fielded by party L (averaged over playing order)

def Solve(eq):
    # If a comparison returns an equality (e.g. x=c), we
    # must not give the advantage neither to the man, nor
    # to the woman. So we take the mean of the two cases.
    for i in range(7):
        if eq[i]==0:
            save=[]
            for j in range(7):
                save+=[eq[j]]
            save[i]=1
            Solve1=Solve(save)
            save[i]=-1
            Solve2=Solve(save)
            return([0.5*(Solve1[0]+Solve2[0]),0.5*(Solve1[1]+Solve2[1])])
    ###############################
    # First, the case in which party L plays first
    if eq[0]>0:
        if eq[1]>0:
            if eq[2]>0:
                Results=[0,0]
            else:
                Results=[0,1]
        else:
            if eq[3]>0:
                Results=[0,0]
            else:
                Results=[1,1]
    else:
        if eq[1]>0:
            if eq[4]>0:
                Results=[1,0]
            else:
                Results=[0,1]
        else:
            if eq[5]>0:
                Results=[1,0]
            else:
                Results=[1,1]   
    return(Results)



def Strategy(w, b, vRm, vRf, vLm, vLf, c, layers):
    # The computation of the cdf can never be accurate 
    # enough, we need to correct for cases where it would
    # be mistaken with zero.
    while cdf(w)<0.00001:
        w+=0.005
    while 1-cdf(w)<0.00001:
        w-=0.005
    bL=b+vLm-vLf
    bR=b+vRm-vRf
    x=f(w,bR)
    y=f(w+bL,bL)
    z=f(w,bR-bL)    
    # Here are the seven comparisons to be considered
    if B==0:
        eq=[x-c, y+z-c, y-c, -z-c, y+x-c, x-z-c, z-c]
    else: # The extensions are implemented here
        if layers[0]=="o":
            eq=[x+B*cdf(w-bR)-c, y+z+B*cdf(w-bR+bL)-c, y+B*(1-cdf(w+bL))-c]
            eq+=[-z+B*(1-cdf(w-bR+bL))-c, y+x+B*(1-cdf(w+bL))-c]
            eq+=[x-z+B*(1-cdf(w-bR+bL))-c, z+B*cdf(w-bR+bL)-c]
        else:
            eq=[x+B*cdf(w)-c, y+z+B*cdf(w+bL)-c, y+B*(1-cdf(w))-c]
            eq+=[-z+B*(1-cdf(w-bR))-c, y+x+B*(1-cdf(w))-c]
            eq+=[x-z+B*(1-cdf(w-bR))-c, z+B*cdf(w+bL)-c]
    return(Solve(eq))

def two_layers(w, b, vRm, vRf, vLm, vLf, c):
    if vRf>vRm+b:
        if vLf>vLm+b:
            return([1,1])
        else:
            return([1,0])
    else:
        if vLf>vLm+b:
            return([0,1])
        else:
            return(Strategy(w, b, vRm, vRf, vLm, vLf, c, "two-layers"))


# The agreg function computes for specific values of z, b 
# and c, the average behavior over valence draws regarding
# the decision of the party R to field a woman,
# but also the probability that a woman is elected and
# the average valence of fielded or elected women.
# The output is a vector with 5 elements:
# 0. the share of female candidates of party R,
# 1. the average valence of female candidates,
# 2. the share of elected female 
# 3. the cumulative valence of the elected candidate (over both female and male candidates)
#       to obtain an average valence of elected candidates, 
#       this should be normalized by victory probability
# 4. the probability of victory of party R 
            
# To do so, it computes the strategical interaction for
# any potential levels of valence.
# The simple mode only takes into account the valences of 
# the candidates of party R, while the complex mode takes
# into account the valences of all four candidates, thus
# being much longer to run.
    
def agreg(z, b, c, accuracy, complexity, layers):
    # data_vote stores the output (selection of women and vote shares) of every simulation
    # where is a simulation is indexed by (z,b,c), the valence of candidtes draw (vRm, vRf)
    #  and the campaign popularity shock (delta)
    #               data_vote[0]+=[z]
    #                data_vote[1]+=[b]
    #                data_vote[2]+=[vRm]
    #                data_vote[3]+=[vRf]
    #                data_vote[4]+=[s]
    #                data_vote[5]+=[delta]
    #                data_vote[6]+=[vote] 
    data_vote=[[],[],[],[],[],[],[]]
    # fielded counts the number of female candidates by party R 
    # the sum is over valence draws; 
    # for every valence draw, averaged over play order already taken
    # Count just sums the number of candidates selected (by party R)
    fielded, count = 0,0
    # valence_fielded sums up the valence of party-R candidates,
    # weighted by selection probability
    # Element 0 is the woman, Elt 1 is the man. 
    # When the woman is not selected, valence_fielded[0]=0
    valence_fielded=[0,0]
    # elected sums up the probability of party-R winning the election
    # again weighted by selection probability    
    # Element 0 is the woman, Elt 1 is the man. 
    # When the woman is not selected, elected[0]=0
    # assumption: when both parties change the gender of their candidates with the 
    # playing order, this is independent...
    elected=[0,0]
    # valence_elected sums up the valence of party-R candidates,
    # weighted by selection and election probability 
    valence_elected=[0,0]
    vectorV=np.linspace(-theta,theta,accuracy) # all the potential valences
    
    for vRm in vectorV:
        for vRf in vectorV:
            #######################################
            # Here is the simple mode
            if complexity[0]=="s":
                w=z+vRm
                V_rival=theta/3
                
                if layers[0]=="o":
                    s=Strategy(w,b,vRm,vRf,V_rival,V_rival,c,layers)[0]
                    s1=Strategy(w,b,vRm,vRf,V_rival,V_rival,c,layers)[1]
                else:
                    s=two_layers(w,b,vRm,vRf,V_rival,V_rival,c)[0]
                    
                s2=0.5*(1-(b/(2*theta))**2)
                fielded+=s
                count+=1
                
                valence_fielded[0]+=s*vRf
                valence_fielded[1]+=(1-s)*vRm 
                # probabilities of victory for party R :
                probVF=s2*cdf(z+vRf-V_rival)+(1-s2)*cdf(z+vRf-b-V_rival)
                probVM=s2*cdf(w+b-V_rival)+(1-s2)*cdf(w-V_rival)
                # if we want to simulate outcomes of naive parties
                # we need to replace b by 0.06
                probVF=s2*cdf(z+vRf-V_rival)+(1-s2)*cdf(z+vRf-0.06-V_rival)
                probVM=s2*cdf(w+0.06-V_rival)+(1-s2)*cdf(w-V_rival)
                #probVF=s2*cdf(z+vRf-V_rival)+(1-s2)*cdf(z+vRf-0.1-V_rival)
                #probVM=s2*cdf(w+0.1-V_rival)+(1-s2)*cdf(w-V_rival)
                
                elected[0]+=s*probVF
                elected[1]+=(1-s)*probVM
                valence_elected[0]+=s*vRf*probVF
                valence_elected[1]+=(1-s)*vRm*probVM   
                
                vectordelta = np.random.normal(0,sigma, 100)
                for delta in vectordelta:
                    gamma=s*(vRf-b)+(1-s)*vRm-V_rival+b*s1-delta
                    if gamma<-2:
                        vote=0
                    else:
                        if gamma>2:
                            vote==1
                        else:
                            Istar=gamma/2
                            vote=min(max(0,(1+z/2-Istar)/2),1)
                    #data_vote+=[z,b,vRm,vRf,s,vote]
                    data_vote[0]+=[z]
                    data_vote[1]+=[b]
                    data_vote[2]+=[vRm]
                    data_vote[3]+=[vRf]
                    data_vote[4]+=[s]
                    data_vote[5]+=[delta]
                    data_vote[6]+=[vote] 
                
            ######################################
            # Now comes the complex mode
            else:
                for vLm in vectorV:
                    for vLf in vectorV:
                        w=z+vRm-vLm
                        if layers[0]=="o":
                            [s,s2]=Strategy(w,b,vRm,vRf,vLm,vLf,c,layers)
                        else:
                            [s,s2]=two_layers(w,b,vRm,vRf,vLm,vLf,c)
                        fielded+=s
                        count+=1
                        
                        valence_fielded[0]+=s*vRf
                        valence_fielded[1]+=(1-s)*vRm
                        probVF=s2*cdf(z+vRf-vLf)+(1-s2)*cdf(z+vRf-b-vLm)
                        probVM=s2*cdf(z+vRm-vLf+b)+(1-s2)*cdf(w)
                        
                        elected[0]+=s*probVF
                        elected[1]+=(1-s)*probVM
                        valence_elected[0]+=s*vRf*probVF
                        valence_elected[1]+=(1-s)*vRm*probVM
            #######################################
    if fielded==0:
        fielded=0.0000001 # better not divide by zero
#    print(data_vote)
    Results=[fielded/count,valence_fielded[0]/fielded,elected[0]/count]
    Results+=[valence_elected[0]+valence_elected[1],elected[0]+elected[1]]
#    print(Results)
    return(data_vote)


# Now we finally compute the proportions of women fielded and elected at the national level. 
# To do so, we use the agreg function and sum the results for any value of Zk,
# weighted so as to get the actual distribution of Zk.
# basic_model output:
# 0. recall voter bias    
# 1. share of female candidate by party R
# 2. share of female elected politicians (in party R)
# 3. share of female candidates (in party R) conditional on non-winnable districts      
# 4. share of female candidates (in party R) conditional on contestable districts      
# 5. share of female candidates (in party R) conditional on winnable districts   
# 6. average valance of elected candidates (party R both female and male candidates)    
def basic_model(b, complexity, layers):
    # all_sums stores in [0][0] the cdf of the gaussian taken in popularity z
    # this is used to determine whether we compute the game
    #   in a non-winnable dist (index_competition=1) 
    #   in a contestable dist (index_competition=2) 
    #   in a winnable dist (index_competition=3) 
    # all_sums[.][0] stores the share of female candidates and of female elec. politicians
    # all_sums[.][index_competition] stores the same statitics, cond. on the competition index
    all_sums=[[0,0,0,0],[0,0,0,0],[0,0,0,0],0]
    # Cumulative sums of the gaussian, the %fielded and 
    # the %elected. For each we sum on all districts
    # (first case) then separately for winnable, contested
    # and unwinnable districts.
    for i in range(N):
        gauss=gaussian(vectorz[i],sigmabis)
        L=agreg(vectorz[i],b,c,acc,complexity,layers)
        # values keeps the share of female candidates (party-R) 
        # and the share of elected candidates (party-R)
        values=[1,L[0],L[2]*2]
        # why multiplied by 2??
        # to compute a proba to win for running candidates 
        # half size / population of potential candidates 
        index_competition=2
        if all_sums[0][0]<Sum_gaussian/3:
            index_competition=1
        if all_sums[0][0]>=2*Sum_gaussian/3*0.95: #to get 20 points in each category
            index_competition=3
        for k in range(3):
            all_sums[k][index_competition]+=values[k]*gauss
            all_sums[k][0]+=values[k]*gauss 
        all_sums[3]+=L[3]/L[4]*gauss
        # This computes the average valence of elected politicians 
        # as L[3] is the cumulative valence of elected politicians and 
        # L[4] is the cum proba of victory
    prop_fielded=all_sums[1][0]/all_sums[0][0]
    prop_elected=all_sums[2][0]/all_sums[0][0]
    average_valence=all_sums[3]/Sum_gaussian
    # Sum_gaussian and  all_sums[0][0] should be equal
    Results=[b, round(prop_fielded,3), round(prop_elected,3)]
    for k in range(1,4):
        #print(Results)
        Results+=[round(all_sums[1][k]/all_sums[0][k],3)]
        #print(Results)
    Results+=["Valence : ", round(average_valence,4)]
    print(Results)
    print('b',Results[0]) 
    print('Share of women running',Results[1]) 
    print('Share of women elected',Results[2]) 


# The following programs plots several 2D and 3D graphs.
# All plots are done both pre and post-quota.
# They are in the following order : %women fielded, average
# valence of women fielded, %women elected, average valence
# of all elected deputies, at the end the 2D graphs    
    # it calls the function agreg
def plot_basic_model(acc, complexity, layers, post):
   M=[[],[],[],[],[],[],[]]
   vectorb=np.linspace(0.01,0.06,acc)
   for j in range(acc): # for any value of b
        b=vectorb[j]
        t=time.time()
#        print('b', vectorb[j] )
        for i in range(N): # for any value of Zk
            # Here we just put the results from Agreg in
            # the corresponding list
            data=agreg(vectorz[i],b,vectorc[post],acc,complexity,layers)
#             print('toto')
            for k in range(7):
                M[k]+=data[k]
   #for k in range(7):
   #     M1[k]+=L1[k]
   #     M2[k]+=L2[k]
   return(M)

    
 
     
def test(sigma):
    delta = np.random.normal(0,sigma, 100)
    print(delta)
    
    
"""///////////////////////////////////////////////////////////////////////////
4/ EXECUTION """
         
np.random.seed(123)

t=time.time()
print("//////////////////////////////////////////////////////")

# def agreg(z, b, c, accuracy, complexity, layers):
#data=agreg(0, 0.03, c, 25,  "simple", "one-layer")    
#data2=agreg(0.01, 0.03, c, 25,  "simple", "one-layer")
#        for k in range(7):
#            data[k]+=data2[k]
#mydata2=pd.DataFrame(data2)

   #               data_vote[0]+=[z]
    #                data_vote[1]+=[b]
    #                data_vote[2]+=[vRm]
    #                data_vote[3]+=[vRf]
    #                data_vote[4]+=[s]
    #                data_vote[5]+=[delta]
    #                data_vote[6]+=[vote] 
  
# this is the median idelology of the district
#np.mean(data[0])
#np.mean(data[1])
#np.mean(data[2])
#np.mean(data[3])
#np.mean(data[4])
#np.mean(data[5])
#np.mean(data[6])
#np.amin(data[6])
#np.amax(data[6])
#np.histogram(data[6])

# for debug test
#N=30
acc=16


# def plot_basic_model(acc, complexity, layers, post):
    # where post indicate if there is a quota
# aacuracy is grid size for voters bias
#data=plot_basic_model(8, "simple", "one-layer",1)
data=plot_basic_model(acc, "simple", "one-layer",1)

mydata=pd.DataFrame(data)
mydata=mydata.transpose()
mydata.columns=['z','b','vRm','vRf','s','delta','vote']
mydata.head()
mydata.describe()
mydata.s.describe()
mydata.mean()

mydata.loc[:, 'vote_round'] = np.round(mydata['vote'],2)

mydata.to_csv('D:\Dropbox\Elections\Mathieu\simulation_postquota.csv', index = False)

test=mydata.groupby(['b','vote_round']).mean()
test.describe()
test['b']=test.index.get_level_values(0)
test['vote_round']=test.index.get_level_values(1)

fig = plt.figure(figsize=(8,6))
#      X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))        
   # X, Y = np.meshgrid(vectorvote, np.linspace(0.01,0.06,acc))        
ax = fig.add_subplot(1,1,1, projection='3d')
ax.plot_trisurf(test.vote_round, test.b, test.s, linewidth=0.2)
ax.set_ylim(0.06,0.01)
ax.set_zlim(0,1)
plt.title("Post-quota")
plt.xlabel("Realized vote share")
plt.ylabel("Voter bias (b)")
plt.savefig('Post-quota_vote_')
plt.show()

#quit()

# def plot_basic_model(acc, complexity, layers, post):
    # where post indicate if there is a quota
# aacuracy is grid size for voters bias
data=plot_basic_model(acc, "simple", "one-layer",0)

mydata=pd.DataFrame(data)
mydata=mydata.transpose()
mydata.columns=['z','b','vRm','vRf','s','delta','vote']
mydata.head()
mydata.describe()
mydata.s.describe()
mydata.mean()

mydata.loc[:, 'vote_round'] = np.round(mydata['vote'],2)
mydata.to_csv('D:\Dropbox\Elections\Mathieu\simulation_prequota.csv', index = False)

test=mydata.groupby(['b','vote_round']).mean()
test.describe()
test['b']=test.index.get_level_values(0)
test['vote_round']=test.index.get_level_values(1)

test=test[test['vote_round']>0.2]
test=test[test['vote_round']<0.8]

fig = plt.figure(figsize=(8,6))
#      X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))        
   # X, Y = np.meshgrid(vectorvote, np.linspace(0.01,0.06,acc))        
ax = fig.add_subplot(1,1,1, projection='3d')
ax.plot_trisurf(test.vote_round, test.b, test.s, linewidth=0.2)
#;ax.set_xlim(0.25,0.75)
ax.set_ylim(0.06,0.01)
ax.set_zlim(0,1)
plt.title("Pre-quota")
plt.xlabel("Realized vote share")
plt.ylabel("Voter bias (b)")
plt.savefig('Pre-quota_vote_')
plt.show()



#vectorvote=np.unique(test['vote_round'])
#vectorb=np.unique(test['b'])    
#vectors=np.array(test['s'])
#fig = plt.figure(figsize=(8,6))
#X, Y = np.meshgrid(vectorvote, vectorb)        
#ax = fig.add_subplot(1,1,1, projection='3d')
#ax.plot_surface(X, Y, vectors, rstride=1, cstride=1)
#ax.set_ylim(0.06,0.01)
#ax.set_zlim(0,1)
#plt.title("Post-quota")
#plt.xlabel("Pre-campaign popularity")
#plt.ylabel("Voter bias (b)")
#plt.savefig('Post-quota__')
#plt.show()
