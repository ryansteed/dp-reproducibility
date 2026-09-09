""" Simulations

This file simulates the model of political selection in Le Barbanchon and Sauvagnat (2018)
and produces Figure 4, and Table 7, as well as results in Appenidx B (intrinsic party bias)
Extra simulations reported in Appendix B are produced in Simulations_JEEA_2.py 

We consider the baseline model with voter bias only, and the model that also features
intrinsic party bias.
The program also simulates a two-layer model, an extension of the baseline model
that accounts for bargaining btw local party units and a central party board. 
The 2-layer model is not in the wp (See Fouquet report).

Prog allows to either consider simulations with full strategic interactions 
or models with non-strategic parties.

Also when aggregating selection decisions by parties, we can either vary the types of the 
opponents, or consider an average opponent with average valence. 

To replicate the draft results:
Figure 4 is obtained by running plot_basic_model(25, "simple", "one-layer")
with the baseline calibration from Table 6. It varies b from 0.01 to 0.06 
for two values of c pre-quota c=0 and post-quota

Corresponding Appendix Figure C.1 with party bias is obtained by running the same 
command but setting B=0.0035 in the program header

Simulation Results Table 7 are obtained by running basic_model(0.06, "simple", "one-layer") 
several times changing in the initialization header:
    c to obtain pre and post-quota figures  
    sigmabis to vary electoral competition

Correspoding Appendix Table C.1 with intrinsic party bias is obtained 
by running the same command but setting B=0.0035 in the program header


PLAN:
    1/ INITIALIZATION. Useful packages are imported,
    variables are set, and the distribution of the
    CDF is computed. Some basic graphs are plotted.
    
    2/ QUOTA BINDING. We solve the strategical interactions
    between the two parties in the different models. 
    Some 3D graphs are plotted, and proportions of 
    women fielded and elected are computed.
    The party bias model is obtained when B!=0.
    The two-layers model is obtainded by changing "layers".
    The plots show the average share of female candidates selected by party R,
    for different levels of electoral competition and voters bias.
    The plots aggregates the decisions of party R, when it plays first or second.
    When simulation mode is set to "simple", party L candidate is the average candidate
    When it is set to "complex", a simulation is produced for every valence of the party L
    candidate and then averaged.
    
    3/ LIMITED QUOTA. The upper bound of the quota is
    taken into account, so that the fine disapears over 50%.
    Proportions of women fielded and elected are computed.
    Some 3D graphs are plotted.
    The party bias model is obtained when B!=0.
    
    4/ EXECUTION. All the calls to functions are summed 
    here. This part is, with the beginning of the 
    initialization, the only one a user needs.
    
////////////////////////////////////////////////////////////
1/ INITIALIZATION """

# Definition of the cost of fine, the party bias/cost of 
# authority, and the maximum value for valences
# post-quota 
c=0.004
# pre-quota
#c=0

B=0.00 # for figure 4  and main simulations
B=0.0035 # for figure C.1 and intrinsic party bias simulations

theta=0.05

# Definition of the popularity schock
sigma=0.06 

# Definition of the variance of the distribution of Zk
#  baseline
sigmabis=0.16
# higher competition Panel C of Table 7 or Table C.1
#sigmabis=0.14
#lower competition Panel D of Table 7 or Table C.1
#sigmabis=0.18


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

# This function plots a graph explaining a party's
# incentives to field a woman
def plot_incentives(model):
    L, M = [],[]
    vectorz=np.linspace(-1,1,N*2)
    if model[0]=="B":
        for i in range(N*2):
            L+=[c-f(vectorz[i],c*0.5)]
            M+=[c-f(vectorz[i],c*1.5)]
        plt.plot(vectorz, L, label='High valence women')
        plt.plot(vectorz, M, '--', label='Low valence women')
        plt.plot(vectorz, np.zeros(N*2), 'r-.')
        plt.xlabel('Predicted pre-campaign popularity of party R')
        plt.ylabel('Incentives to field a woman for party R')
        plt.legend()
        plt.show()
    else:
        b=0.02
        if model[0]=="P":
            LABEL="Party bias"
        else:
            LABEL="Cost of enforcing authority"
        for i in range(N*2):
            L+=[c-f(vectorz[i],b)]
            M+=[B*cdf(vectorz[i]+b)]
        lim_inf=L[0]-(L[0]-L[N])*1.3 # put the legend under the graphs
        plt.plot(vectorz, L, label="Objective gain in fielding a woman") 
        plt.plot(vectorz, M, 'r--', label=LABEL)
        plt.ylim(lim_inf)
        plt.xlabel('Predicted pre-campaign popularity of party R')
        plt.ylabel('Units of utility for parties')
        plt.legend(bbox_to_anchor=[0.68, 0.08],loc='center')
        plt.show()


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
                Results=[0,0.5]
        else:
            if eq[3]>0:
                Results=[0,0]
            else:
                Results=[0.5,0.5]
    else:
        if eq[1]>0:
            if eq[4]>0:
                Results=[0.5,0]
            else:
                Results=[0,0.5]
        else:
            if eq[5]>0:
                Results=[0.5,0]
            else:
                Results=[0.5,0.5]   
    ##############################
    # Now we need to sum with the case in which party R
    # plays first
    if eq[2]>0:
        if eq[5]>0:
            if eq[0]<0:
                Results[0]+=0.5
        else:
            if eq[6]<0:
                Results[0]+=0.5
                Results[1]+=0.5
    else:
        if eq[5]>0:
            if eq[4]>0:
                Results[1]+=0.5
            else:
                Results[0]+=0.5
        else:
            if eq[1]>0:
                Results[1]+=0.5
            else:
                Results[0]+=0.5
                Results[1]+=0.5
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
    Results=[fielded/count,valence_fielded[0]/fielded,elected[0]/count]
    Results+=[valence_elected[0]+valence_elected[1],elected[0]+elected[1]]
    return(Results)


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
def plot_basic_model(acc, complexity, layers):
    Z=[[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
    #vectorb=np.linspace(0,0.06,acc)
    vectorb=np.linspace(0.01,0.06,acc)
    for j in range(acc): # for any value of b
        L1,L2=[],[]
        M=[[],[],[],[],[],[],[],[],0,0,0,0,0,0]
        b=vectorb[j]
        t=time.time()
        for i in range(N): # for any value of Zk
            # Here we just put the results from Agreg in
            # the corresponding lists
            L1+=[agreg(vectorz[i],b,vectorc[0],acc,complexity,layers)]
            L2+=[agreg(vectorz[i],b,vectorc[1],acc,complexity,layers)]
        for i in range(N):   
            M[0]+=[L1[i][0]]           
            M[1]+=[(L2[i][0]+L2[N-i-1][0])/2]
            M[2]+=[L1[i][1]]
            M[3]+=[L2[i][1]]
            M[4]+=[(L1[i][2]+L1[N-i-1][2])]            
            M[5]+=[(L2[i][2]+L2[N-i-1][2])]
            M[6]+=[(L1[i][3]+L1[N-i-1][3])/(L1[i][4]+L1[N-i-1][4])]
            M[7]+=[(L2[i][3]+L2[N-i-1][3])/(L2[i][4]+L2[N-i-1][4])]
            if i<N/2:
                M[8]+=M[0][i]
                M[9]+=M[1][i]
            else:
                M[10]+=M[0][i]
                M[11]+=M[1][i]
            M[12]+=M[4][i]
            M[13]+=M[5][i]
        for k in range(14):
            Z[k]+=[M[k]]
        print(1+j,"/",acc, " - ",round(time.time()-t,1), " seconds")
    # Time to plot !
    for k in range(14):
        Z[k]=np.array(Z[k])
    List_titles=['Pre-quota','Post-quota']
    List_names=['Proportion fielded','Valence of fielded women']
    List_names+=['Proportion elected','Valence of all elected']
    List_names+=['Winnable Vs unwinnable pre-quota','Winnable Vs unwinnable post-quota']
    List_names+=['Fielded Vs elected pre-quota','Fielded Vs elected post-quota']
    

    fig = plt.figure(figsize=(8,6))
#      X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))        
    X, Y = np.meshgrid(vectorz, np.linspace(0.01,0.06,acc))        
    ax = fig.add_subplot(1,1,1, projection='3d')
    ax.plot_surface(X, Y, Z[0], rstride=1, cstride=1)
    ax.set_ylim(0.06,0.01)
    ax.set_zlim(0,1)
    plt.title("Pre-quota")
    plt.xlabel("Pre-campaign popularity")
#    plt.xlabel("$S_R$")
    plt.ylabel("Voter bias (b)")
#    plt.zlabel("Share of female candidates")
    plt.savefig('Pre-quota__')
    plt.show()
    
    fig = plt.figure(figsize=(8,6))
#      X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))        
    X, Y = np.meshgrid(vectorz, np.linspace(0.01,0.06,acc))        
    ax = fig.add_subplot(1,1,1, projection='3d')
    ax.plot_surface(X, Y, Z[1], rstride=1, cstride=1)
    ax.set_ylim(0.06,0.01)
    ax.set_zlim(0,1)
    plt.title("Post-quota")
    plt.xlabel("Pre-campaign popularity")
#    plt.xlabel("$S_R$")
    plt.ylabel("Voter bias (b)")
#    plt.zlabel("Share of female candidates")
    plt.savefig('Post-quota__')
    plt.show()

           
"""  
    for k in range(0,4): # same format for all 3D graphs
        fig = plt.figure(figsize=plt.figaspect(0.5))
#        X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))        
        X, Y = np.meshgrid(vectorz, np.linspace(0.01,0.06,acc))        
        for i in [0,1]:
            ax = fig.add_subplot(1, 2, i+1, projection='3d')
            ax.plot_surface(X, Y, Z[k*2+i], rstride=1, cstride=1)
            ax.set_ylim(0.06,0.01)
            plt.title(List_titles[i])
            plt.xlabel("$S_R$")
            plt.ylabel("voters' bias")
        plt.savefig(List_names[k])

    for i in [0,1]:
        plt.figure(figsize=(8,2))
        plt.plot(np.linspace(0,0.06,acc), Z[8+i], label='unwinnable')
        plt.plot(np.linspace(0,0.06,acc), Z[10+i],'r--', label='winnable')
        plt.title(List_titles[i])
        plt.legend()
        plt.savefig(List_names[4+i])
    
    for i in [0,1]:
        plt.figure(figsize=(8,2))
        plt.plot(np.linspace(0,0.06,acc), Z[8+i]+Z[10+i],label='fielded')
        plt.plot(np.linspace(0,0.06,acc), Z[12+i],'r--', label='elected')
        plt.title(List_titles[i])
        plt.legend()
        plt.savefig(List_names[6+i])

"""           

"""
t=time.time()
b=0.04
L,M1,M2=[],[],[]
for i in range(N):
            L+=[agreg(vectorz[i],b,vectorc[1],15,"c","o")]
            print(i+1,"/",N)
for i in range(N):              
            M2+=[(L[i][0]+L[N-i-1][0])/2]
            M1+=[L[i][0]]
fig = plt.figure(figsize=plt.figaspect(0.5))
plt.plot(vectorz, M1, label='unwinnable')
plt.plot(vectorz, M2, label='unwinnable')
plt.show()
print(time.time()-t)
"""
"""///////////////////////////////////////////////////////////////////////////
3/ LIMITED QUOTA """

# StratQuota is the equivalent of Strategy and Solve 
# combined together. Here there is no threat of discriminating
# between men and women as the selection will occur latter on.
# The difference with Strategy is that we do not return
# a strategy of allocation but a quantified measure of the
# party's incentive to field a woman.
def StratQuota(w, b, vRm, vRf, vLm, vLf, c):
    while cdf(w)<0.00001:
        w+=0.01
    while 1-cdf(w)<0.00001:
        w-=0.01
    bL=b+vLm-vLf
    bR=b+vRm-vRf
    x=f(w,bR)
    y=f(w+bL,bL)
    z=f(w,bR-bL) 
    if B==0:
        eq=[x-c, y+z-c, y-c, -z-c, y+x-c, x-z-c, z-c]
    else: # The model with party bias is implemented here
        eq=[x+B*cdf(w-bR)-c, y+z+B*cdf(w-bR+bL)-c, y+B*(1-cdf(w+bL))-c]
        eq+=[-z+B*(1-cdf(w-bR+bL))-c, y+x+B*(1-cdf(w+bL))-c]
        eq+=[x-z+B*(1-cdf(w-bR+bL))-c, z+B*cdf(w-bR+bL)-c]
    Strat=[0,0]
    ##########################################
    # Party L plays first
    if eq[0]>=0:
        if eq[1]>=0:
            if eq[2]>=0:
                Strat[1]=-eq[0]
            else:
                Strat[1]=-eq[1]
        else:
            if eq[3]>=0:
                Strat[1]=-eq[0]
            else:
                Strat[1]=-eq[1]
    else:
        if eq[1]>=0:
            if eq[4]>=0:
                Strat[1]=-eq[0]
            else:
                Strat[1]=-eq[1]
        else:
            if eq[5]>=0:
                Strat[1]=-eq[0]
            else:
                Strat[1]=-eq[1]
    ######################################
    # Party R plays first
    if eq[2]>=0:
        if eq[5]>=0:
                Strat[0]=-eq[0]
        else:
                Strat[0]=-eq[6]
    else:
        if eq[5]>=0:
                Strat[0]=-eq[4]
        else:
                Strat[0]=-eq[1]
    return(Strat)


# Now we need first to collect all the measures of incentives
# by calling StratQuota. This is the first part of agregQuota
# which looks like Agreg.
# The second part chooses among locations where to field
# women by choosing the most interesting ones.
def agregQuota(b, acc, c, Quota):
    Incentives, Victory = [],[]
    vectorV=np.linspace(-theta,theta,acc)
    for z in vectorz:
        Incentives_local, Victory_local  = [],[]
        count=0
        for vRm in vectorV:
            for vRf in vectorV: 
                V_rival=theta/3
                Strat_rival=0.5*(1-(b/(2*theta))**2)
                Incentives_local+=StratQuota(z+vRm,b,vRm,vRf,V_rival,V_rival,c)
                prob_victory=Strat_rival*cdf(z+vRf-V_rival)
                prob_victory+=(1-Strat_rival)*cdf(z-b+vRf-V_rival)
                Victory_local+=[prob_victory,prob_victory]
                count+=2
        Incentives+=[Incentives_local]
        Victory+=[Victory_local]
    ###################################################
    # Part 2 of the function. Here we will perform a 
    # dichotomy to get as close as possible to 
    # fielding 50% of women.
    Strat=[np.zeros(count) for i in range(N)]
    Election=[np.zeros(count) for i in range(N)]
    prop_fielded=[0,0,0,0]
    levelInf, levelSup = 0, 2*c
    Tot_gaussian=Sum_gaussian*count
    if c==0:
        levelInf=-1
        levelSup=1
    # We define a level of "incentives" above which women
    # are fielded and move it until %fielded is 50%.
    # If the number of recursions gets too high, the 
    # program understands that the treshold cannot be reached.
    while abs(prop_fielded[0]-Quota)>0.001 and levelSup-levelInf>0.0000001:
        l=(levelSup+levelInf)*0.5
        prop_fielded, prop_elected, gauss = [0,0,0,0],0,0
        Result_fielded, Result_elected = [],[] 
        for i in range(N):
            sum_fielded, sum_elected = 0,0
            for j in range(count):
                field=0
                temp_gauss=gaussian(vectorz[i],sigmabis)
                
                if Incentives[i][j]>l:
                    field=1
                if Incentives[i][j]==l:
                    field=0.5
                
                
                index_competition=2
                if gauss<Sum_gaussian/3:
                    index_competition=1
                elif gauss>=2*Sum_gaussian/3:
                    index_competition=3
                    
                gauss+=temp_gauss/count
                
                Strat[i][j]=field
                sum_fielded+=field
                prop_fielded[index_competition]+=field*temp_gauss/Tot_gaussian*3
                prop_fielded[0]+=field*temp_gauss/Tot_gaussian
                                
                Election[i][j]=field*Victory[i][j]
                prop_elected+=field*Victory[i][j]*temp_gauss/Tot_gaussian*2
                sum_elected+=Election[i][j]
                
            Result_fielded+=[sum_fielded/count]
            Result_elected+=[sum_elected*2/count]
        #print(l,levelInf,levelSup,prop_fielded)
        if prop_fielded[0]>0.5:
            levelInf=l
        else:
            levelSup=l
        if c==0:
            levelSup=levelInf #avoids useless computations
    """
    Result_bis=[]
    for i in range(N):
        Result_bis+=[(Result_fielded[i]+Result_fielded[N-i-1])/2]
    Result_fielded=Result_bis
    """
    return(Result_fielded, Result_elected, prop_fielded, prop_elected)

# quota_model just returns %fielded and %elected
def quota_model(b, c, Quota):
    Results=agregQuota(b, acc, c, Quota)
    To_print=[round(b,3), round(Results[2][0],3), round(Results[3],3)]
    To_print+=[round(Results[2][1],3), round(Results[2][2],3), round(Results[2][3],3)]
    print(To_print)

#plotQuota plots 3D graphs for %fielded and %elected
def plotQuota(acc, Quota):
    Ll, Lh=[],[]
    M=[[],[],[],[]]
    vectorb=np.linspace(0,0.06,acc)
    for j in range(acc):
        t=time.time()
        Ll+=[agregQuota(vectorb[j],acc, 0, Quota)[0:2]]
        Lh+=[agregQuota(vectorb[j],acc, c, Quota)[0:2]]
        print(j+1,"/",acc, " - ",round(time.time()-t,2), " seconds")
    for j in range(acc):
        M[0]+=[Ll[j][0]]
        M[1]+=[Lh[j][0]]
        M[2]+=[Ll[j][1]]
        M[3]+=[Lh[j][1]]
    for i in range(4):
        M[i]=np.array(M[i])
    List_titles=['Pre-quota','Post-quota']
    
    for k in [0,1]:
        fig = plt.figure(figsize=plt.figaspect(0.5))
        X, Y = np.meshgrid(vectorz, np.linspace(0,0.06,acc))
        for i in [0,1]:
            ax = fig.add_subplot(1, 2, 1+i, projection='3d')
            plt.title(List_titles[i])
            ax.set_ylim(0.06,0)
            ax.plot_surface(X, Y, M[k*2+i], rstride=1, cstride=1)
     
"""///////////////////////////////////////////////////////////////////////////
4/ EXECUTION """
         
t=time.time()
print("//////////////////////////////////////////////////////")


# To replicate Figure 4, and C.1 run following exeution command
# with different initialization value above
# first argument is grid size for voters bias
# plot_basic_model(25, "simple", "one-layer")

# To replicate Table 7, and C.1 run following exeution command
# with different initialization value above
# first argument is voters bias
basic_model(0.06, "simple", "one-layer")

print("Total time : ", round(time.time()-t,1), " seconds")
"""
# We compute the average electoral benefit of buying
# votes with c
sum_c=0
sum_gauss=0
vectorz=np.linspace(-1,1,500)
for i in range(500):
    z=vectorz[i]
    sum_c+=f(z+0.016,0.032)*gaussian(z,sigmabis)
    sum_gauss+=gaussian(z,sigmabis)
print(sum_c/sum_gauss)
"""
# Graph of f-1(c)
# figure 2
"""
N=100
b=0.04
L=[]
vectorZ=np.linspace(-1,1,N)
for i in range(N):
    bl,bh=-2*theta,+2*theta
    delta_theta=0
    z=vectorZ[i]
    done=0
    if f(z,b+2*theta)<=c:
        delta_theta=-2*theta
        done=1
    while abs(f(z,b-delta_theta)-c)>0.00001 and done==0:
        if f(z,b-delta_theta)>c:
            bl=delta_theta
        else:
            bh=delta_theta
        delta_theta=(bh+bl)/2
    L+=[delta_theta]
vectorZ=np.linspace(0,100,N)
plt.plot(vectorZ,L, label="Post-quota selection level")
M=b*np.ones(N)
O=(-2*theta)*np.ones(N)
P=(2*theta)*np.ones(N)
plt.plot(vectorZ,M, "--", label="Pre-quota selection level")
plt.plot(vectorZ,O, "r-.", label="Bounds of valence gap")
plt.plot(vectorZ,P, "r-.")
plt.xlabel("Predicted vote share of party R (%)")
plt.ylabel("Valence gap between the female and male aspirants")

plt.yticks([-0.1,0.04,0.1],["-2Θ","b","2Θ"])
plt.legend(bbox_to_anchor=[0.75, 0.82],loc='center')
plt.show()
"""
# updated figure 2
"""
N=100
b=0.04
L=[]
vectorZ=np.linspace(-1,1,N)
for i in range(N):
    bl,bh=-2*theta,+2*theta
    delta_theta=0
    z=vectorZ[i]
    done=0
    if f(z,b+2*theta)<=c:
        delta_theta=-2*theta
        done=1
    while abs(f(z,b-delta_theta)-c)>0.00001 and done==0:
        if f(z,b-delta_theta)>c:
            bl=delta_theta
        else:
            bh=delta_theta
        delta_theta=(bh+bl)/2
    L+=[delta_theta]
plt.plot(vectorZ,L, label="Post-quota selection level")
M=b*np.ones(N)
plt.plot(vectorZ,M, "--", label="Pre-quota selection level")
plt.xlabel("Predicted Pre-campaign Popularity of Party R")
plt.ylabel("$Θ^F_R - Θ^M_R$")

plt.yticks([-0.1,0.04,0.1],["-2Θ","b","2Θ"])
plt.legend(bbox_to_anchor=[0.75, 0.9],loc='center')
#plt.figtext(0.24,0.8,"Women only")
#plt.figtext(0.2,0.75,"Pre and post-quota")
#plt.figtext(0.14,0.60,"Post-quota Women")
#plt.figtext(0.14,0.55,"Pre-quota Men")
#plt.figtext(0.67,0.60,"Post-quota Women")
#plt.figtext(0.72,0.55,"Pre-quota Men")
#plt.figtext(0.45,0.40,"Men only")
#plt.figtext(0.4,0.35,"Pre and post-quota")
plt.figtext(0.25,0.8,"F only")
plt.figtext(0.2,0.75,"Pre and post-quota")
plt.figtext(0.15,0.60,"Post-quota F")
plt.figtext(0.15,0.55,"Pre-quota M")
plt.figtext(0.72,0.60,"Post-quota F")
plt.figtext(0.72,0.55,"Pre-quota M")
plt.figtext(0.46,0.40,"M only")
plt.figtext(0.4,0.35,"Pre and post-quota")
plt.show()
"""
