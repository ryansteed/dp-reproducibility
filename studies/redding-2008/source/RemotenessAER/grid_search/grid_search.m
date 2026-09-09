
% Grid Search;
% Calibration and Simulation;
% The Costs of Remoteness: Evidence from German Division and Reunification;
% Redding-Sturm;
% SJR, Feburary, 2008;

clear;
clc;
format short;

% ************************************************************;
% **** Size of Grid over which to search                  ****;
% **** Also determines the range of parameter values      ****;
% **** over which to search based on the increments       ****;
% **** for the parameter values specified below           ****;
% ************************************************************;

x=46;
xx=46.*46;
xxx=46.*46.*46;

% *******************;
% **** Read Data ****;
% *******************;

% Read in data (206 pre-war German cities);
% Pre-war German cities include cities in the future West Germany,;
% future East Germany, future parts of Poland, future parts of Russia;
% As with the regression sample, the three Saarland cities are excluded 
% from these data for the grid search;
citydata = csvread('Z:/SRDS/RemotenessAER/grid_search/data/MatlabPopData.csv');
% Read in bilateral trade cost matrix (206 pre-war German cities);
% T = dist^(-1);
T = csvread('Z:/SRDS/RemotenessAER/grid_search/data/MatlabTrans.csv');
% Read in bilateral identifier for pairs of cities within future West;
% Germany (206 pre-war German cities);
brdbrd_p = csvread('Z:/SRDS/RemotenessAER/grid_search/data/Matlabbrdbrd.csv');

% Extract variables from data;
% Columns of citydata correspond to the following variables;
% Column 1 : population in 1939 : pop39; 
% Column 2 : n_lat_deg;
% Column 3 : e_long_deg; 
% Column 4 : brd; 
% Column 5 : city;
% Column 6 : dist_gg_border;
% Column 7 : population in 1970 : pop70;
% Column 8 : population in 1960 : pop60;
% Column 9 : population in 1980 : pop80;
% Column 10 : population in 1988 : pop88;
% Column 11 : non-parametric estimates of the division treatment (mean == zero) : np_div;
% Column 12 : inf_div=(100+np_div)/100;
% Column 13 : divpop=((pop39*(inf_div^38))-pop39)/pop39;
% Column 14 : population in 1950 : pop50;
% Column 15 : population in 1919 : pop19;

L=citydata(:,1);
city=citydata(:,5);
L19=citydata(:,15);
brd=citydata(:,4);
lat=citydata(:,2);
long=citydata(:,3);
distgg=citydata(:,6);
npdiv=citydata(:,11);
sizecitydata=size(citydata)
sizeL=size(L)
sizeT=size(T)

% Total population of all cities;
LL=sum(L);

% *********************************;
% **** Define Parameter Values ****;
% *********************************;

% PARAMETER VALUES;
% 46*46*46 = 97336 possibilities;
% Elasticity of substitution;
% sigma : 2.0 to 6.5 in steps of 0.1;
% Share of spending on manufactures;
% mu : 0.50 to 0.95 in steps of 0.1;
% Elasticity of transport costs with respect to distance;
% eta : 0.10 to 2.35 in steaps of 0.05;

% ************************************;
% **** Elasticity of substitution ****;
% ************************************;

sigmavec=zeros(xxx,1);
z=1;
while z<x+1;
pstart=((z-1).*xx)+1;
pend=((z-1).*xx)+xx;
sigmavec(pstart:pend,1)=2.0+((z-1).*0.1);
z = z + 1;
end;

% *******************************************;
% **** Share of spending on manufactures ****;
% *******************************************;

muvec=zeros(xxx,1);
temp1=zeros(x,1);
temp2=zeros(xx,1);
% Loop to fill temp2;
z=1;
while z<x+1;
pstart=((z-1).*x)+1;
pend=((z-1).*x)+x;
temp2(pstart:pend,1)=0.50+((z-1).*0.01);
z = z + 1;
end;
% Loop to fill muvec;
z=1;
while z<x+1;
ppstart=((z-1).*xx)+1;
ppend=((z-1).*xx)+xx;
muvec(ppstart:ppend,1)=temp2;
z = z + 1;
end;

% ****************************************************************;
% **** Elasticity of transport costs with respect to distance ****;
% ****************************************************************;

etavec=zeros(xxx,1);
temp1=[0.10;0.15;0.20;0.25;0.30;0.35;0.40;0.45;0.50;0.55;0.60;0.65;0.70;0.75;0.80;0.85;0.90;0.95;1.00;1.05;1.10;1.15;1.20;1.25;1.30;1.35;1.40;1.45;1.50;1.55;1.60;1.65;1.70;1.75;1.80;1.85;1.90;1.95;2.00;2.05;2.10;2.15;2.20;2.25;2.30;2.35];
temp2=vertcat(temp1,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1,temp1);
temp2=vertcat(temp2,temp1);
z=1;
while z<x+1;
pstart=((z-1).*xx)+1;
pend=((z-1).*xx)+xx;
etavec(pstart:pend,1)=temp2;
z = z + 1;
end;

% *******************************************************;
% **** Delete parameter values where sigma(1-mu) < 1 ****;
% *******************************************************;

stabcond=(1-muvec).*sigmavec;
instab = find(stabcond<1);
sigmavec(instab)=[];
muvec(instab)=[];
etavec(instab)=[];
ssigmavec=size(sigmavec);
nojsims=ssigmavec(1,1);

% *************************;
% **** Initializations ****;
% *************************;

nojcity=nojsims.*119;
simresults=ones(nojcity,19);
output=ones(nojsims,18);
convtest=zeros(nojsims,2);

% ******************************************;
% **** Define Exponent on T = dist^(-1) ****;
% ******************************************;

deltavec=1-sigmavec;
deltavec=deltavec.*etavec;
deltavec=abs(deltavec);

% ***************************************;
% **** Define other Parameter Values ****;
% ***************************************;

% Fixed production cost;
F=1;

% *****************************************************;
% **** LOOP THROUGH EACH PARAMETER CONFIGURATION   ****;
% **** FIRST CALIBRATE AND THEN SIMULATE THE MODEL ****;
% *****************************************************;

y=1;
while y<nojsims+1;
    
display('Parameter Vector');
display(y);

% Parameter values for this value of y;
sigma=sigmavec(y);
mu=muvec(y);
delta=deltavec(y);
eta=etavec(y);
TT=T.^delta;

% Constant in wage equation for this value of y;
xi = (F*(sigma-1))^(-(1/sigma)) * ((sigma-1)/sigma);

% *******************************************************;
% **** CALIBRATION CODE                              ****;
% *******************************************************;

% Initial distribution of endogenous variables;
w_i  = 100*ones(206,1);
L_c  = L;
H_c  = L*100;
n_c  = (1./(F.*sigma)).*L;
p_c  = (sigma./(sigma-1)).*w_i;
PM_c = (TT * (n_c .* (p_c.^(1-sigma)))).^(1./(1-sigma));
w_c  = xi .* (TT * (w_i.*L.*(PM_c.^(sigma-1)))).^(1./sigma);
E_c  = (w_c.*L)./mu;
PH_c = ((1-mu).*E_c)./H_c;
om_c = w_c./((PM_c).^mu .* (PH_c).^(1-mu));

% **************************************************;
% **** BEGINNING OF LOOP FOR COARSE CALIBRATION ****;
% **** Solve system of equations                ****;
% **************************************************;

calconverge=0;
i=1;
while i<100000;

n_c  = (1./(F.*sigma)).*L;
p_c  = (sigma./(sigma-1)).*w_c;
PM_c = (TT * (n_c .* (p_c.^(1-sigma)))).^(1./(1-sigma));
w_c  = xi .* (TT * (w_c.*L.*(PM_c.^(sigma-1)))).^(1./sigma);
E_c  = (w_c.*L)./mu;
PH_c = ((1-mu).*E_c)./H_c;
om_c = w_c./((PM_c).^mu .* (PH_c).^(1-mu));

iom_c = round(om_c*100);
test=abs(iom_c);
test=test-100;
Sumtest=sum(test);

if iom_c(:) == 100;
    calconverge=1;
    i=100000;
    
else;
    
% Adjust the housing stock of each pre-war German city;
% so that the real wage is equal to one in each;
% pre-war German city;

z = 1;
while z <= sizeL(1);
    if iom_c(z) > 100;
    H_c(z) = H_c(z) .* 0.99;
    elseif iom_c(z) == 100;
    H_c(z) = H_c(z);
    elseif iom_c(z) < 100;
    H_c(z) = H_c(z) .* 1.01;
end;
z = z + 1;
end;

i = i + 1;
end;
end;

% ********************************************;
% **** END OF LOOP FOR COARSE CALIBRATION ****;
% ********************************************;

% ************************************************;
% **** BEGINNING OF LOOP FOR FINE CALIBRATION ****;
% **** Solve system of equations              ****;
% ************************************************;

calconverge=0;
i=1;
while i<100000;

n_c  = (1./(F.*sigma)).*L;
p_c  = (sigma./(sigma-1)).*w_c;
PM_c = (TT * (n_c .* (p_c.^(1-sigma)))).^(1./(1-sigma));
w_c  = xi .* (TT * (w_c.*L.*(PM_c.^(sigma-1)))).^(1./sigma);
E_c  = (w_c.*L)./mu;
PH_c = ((1-mu).*E_c)./H_c;
om_c = w_c./((PM_c).^mu .* (PH_c).^(1-mu));

iom_c = round(om_c*1000);
test=abs(iom_c);
test=test-1000;
Sumtest=sum(test);

if iom_c(:) == 1000;
    calconverge=1;
    i=100000;
    
else;

% Adjust the housing stock of each pre-war German city;
% so that the real wage is equal to one in each;
% pre-war German city;

z = 1;
while z <= sizeL(1);
    if iom_c(z) > 1000;
    H_c(z) = H_c(z) .* 0.9999;
    elseif iom_c(z) == 1000;
    H_c(z) = H_c(z);
    elseif iom_c(z) < 1000;
    H_c(z) = H_c(z) .* 1.0001;
end;
z = z + 1;
end;

i = i + 1;
end;
end;

% ******************************************;
% **** END OF LOOP FOR FINE CALIBRATION ****;
% ******************************************;

% *************************;
% **** SIMULATION CODE ****;
% *************************;

% Keep only rows that correspond to West Germany;
cutb = find(brd==0);
L_s=L;
brd_s=brd;
city_s=city;
distgg_s=distgg;
L19_s=L19;
npdiv_s=npdiv;
T_s=T;
TT_s=TT;
brdbrd_s=brdbrd_p;

L_s(cutb) = [];
L19_s(cutb) = [];
brd_s(cutb) = [];
city_s(cutb) = [];
distgg_s(cutb) = [];
npdiv_s(cutb) = [];
sizeL_s=size(L_s);

% Keep only bilateral pairs that correspond to West Germany;
T_s(cutb,:) = [];
T_s(:,cutb) = [];
TT_s(cutb,:) = [];
TT_s(:,cutb) = [];
brdbrd_s(cutb,:) = [];
brdbrd_s(:,cutb) = [];

% Initializations for simulation;

L_e  = L;
H_e  = H_c;
n_e  = n_c;
p_e  = p_c;
PM_e = PM_c;
w_e  = w_c;
E_e  = E_c;
PH_e = PH_c;
om_e = om_c;

L_e(cutb) = [];
w_e(cutb) = [];
n_e(cutb) = [];
p_e(cutb) = [];
PM_e(cutb) = [];
PH_e(cutb) = [];
E_e(cutb) = [];
om_e(cutb) = [];
H_e(cutb) = [];

% Total population of West German cities;
LL_s = sum(L_s);

% *************************************************;
% **** BEGINNING OF LOOP FOR COARSE SIMULATION ****;
% **** Solve system of equations               ****;
% *************************************************;

simconverge=0;
i=1;
while i<100000;

n_e  = (1./(F.*sigma)).*L_e;
p_e  = (sigma./(sigma-1)).*w_e;
PM_e = (TT_s * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (TT_s * (w_e.*L_e.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L_e)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

mom_e=median(om_e);
wgap = om_e - mom_e;
iwgap=wgap*100;
iwgap=round(iwgap);
test=abs(wgap);
test=sum(test);

if iwgap == 0;
    L_e = L_e;
    simconverge=1;
    i=100000;
    
else

% Reallocate population across West German cities;
% until the real wage is the same in each West German city;

z = 1;
while z <= sizeL_s(1);
    if iwgap(z) > 0;
    L_e(z) = L_e(z) + 20;
    elseif iwgap(z) == 0;
    L_e(z) = L_e(z);
    elseif iwgap(z) < 0;
    L_e(z) = L_e(z) - 20;
end;
z = z + 1;
end;

% Ensure that the total West German population remains constant;

LL_e = sum(L_e);
adjust = (LL_s - LL_e)./sizeL_s(1);
L_e = L_e + adjust;
LL_e = sum(L_e);

end;
i = i + 1;
end;

% *******************************************;
% **** END OF LOOP FOR COARSE SIMULATION ****;
% *******************************************;

% ***********************************************;
% **** BEGINNING OF LOOP FOR FINE SIMULATION ****;
% **** Solve system of equations             ****;
% ***********************************************;

simconverge=0;
i=1;
while i<1000000;

n_e  = (1./(F.*sigma)).*L_e;
p_e  = (sigma./(sigma-1)).*w_e;
PM_e = (TT_s * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (TT_s * (w_e.*L_e.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L_e)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

mom_e=median(om_e);
wgap = om_e - mom_e;
iwgap=wgap*1000;
iwgap=round(iwgap);
test=abs(wgap);
test=sum(test);

if iwgap == 0;
    L_e = L_e;
    simconverge=1;
    i=1000000;
    
else

% Reallocate population across West German cities;
% until the real wage is the same in each West German city;

z = 1;
while z <= sizeL_s(1);
    if iwgap(z) > 0;
    L_e(z) = L_e(z) + 5;
    elseif iwgap == 0;
    L_e(z) = L_e(z);
    elseif iwgap(z) < 0;
    L_e(z) = L_e(z) - 5;
end;
z = z + 1;
end;

% Ensure that the total West German population remains constant;

LL_e = sum(L_e);
adjust = (LL_s - LL_e)./sizeL_s(1);
L_e = L_e + adjust;
LL_e = sum(L_e);

end;
i = i + 1;
end;

% *****************************************;
% **** END OF LOOP FOR FINE SIMULATION ****;
% *****************************************;

% ********************************************;
% **** SOLVE FOR IMPACT OF DIVISION       ****;
% **** AND COMPARE RESULTS OF SIMULATION  ****;
% **** TO THOSE OF ECONOMETRIC ESTIMATION ****;
% ********************************************;

% Small versus large cities;
% Median 1919 population in the future West Germany is 44150 (including the three; 
% Saarland cities not present in these Matlab calibration and simulation data);
medL19=44150;
small19=find(L19_s<medL19); large19=find(L19_s>=medL19);
sm19distgg=distgg_s(small19); la19distgg=distgg_s(large19);

% Cities within 75km of the border;
d_0_75=find(distgg_s<75); 
% Small and large cities within 75km of the border;
dsm19_0_75=find(sm19distgg<75); dla19_0_75=find(la19distgg<75); 

% Cities beyond 75km of the border;
d_75=find(distgg_s>=75);
% Small and large cities beyond 75km from the border;
dsm19_75=find(sm19distgg>=75); dla19_75=find(la19distgg>=75);

% 1939 population;
Ls_0_75=L_s(d_0_75); Ls_75=L_s(d_75);

% Simulated population;
Le_0_75=L_e(d_0_75); Le_75=L_e(d_75);

% Simulated population change;
dL=L_e-L_s;
dL_0_75=(Le_0_75-Ls_0_75)./Ls_0_75; dL_75=(Le_75-Ls_75)./Ls_75;

% Annualized estimated population change;
npd_0_75=npdiv_s(d_0_75); npd_75=npdiv_s(d_75);
npd_0_75=mean(npd_0_75); npd_75=mean(npd_75);
smnpd_0_75=npdiv_s(small19); smnpd_75=npdiv_s(small19);
smnpd_0_75=smnpd_0_75(dsm19_0_75); smnpd_75=smnpd_75(dsm19_75);
smnpd_0_75=mean(smnpd_0_75); smnpd_75=mean(smnpd_75);
lanpd_0_75=npdiv_s(large19); lanpd_75=npdiv_s(large19);
lanpd_0_75=lanpd_0_75(dla19_0_75); lanpd_75=lanpd_75(dla19_75);
lanpd_0_75=mean(lanpd_0_75); lanpd_75=mean(lanpd_75);

% Annualized simulated population change;
mod=(((L_e./L_s).^(1/38))-1)*100;
mn_mod=mean(mod); mod=mod-mn_mod;
mod_0_75=mod(d_0_75); mod_75=mod(d_75);
mod_0_75=mean(mod_0_75); mod_75=mean(mod_75);
smmod_0_75=mod(small19); smmod_75=mod(small19);
smmod_0_75=smmod_0_75(dsm19_0_75); smmod_75=smmod_75(dsm19_75);
smmod_0_75=mean(smmod_0_75); smmod_75=mean(smmod_75);
lamod_0_75=mod(large19); lamod_75=mod(large19);
lamod_0_75=lamod_0_75(dla19_0_75); lamod_75=lamod_75(dla19_75);
lamod_0_75=mean(lamod_0_75); lamod_75=mean(lamod_75);

if dL_0_75<0;
    sgn=1;
else;
    sgn=0;
end;

% Store the data from each calibration and simulation;

sigmastore=sigma*ones(119,1);
mustore=mu*ones(119,1);
etastore=eta*ones(119,1);
deltastore=delta*ones(119,1);
ystore=y*ones(119,1);
data = horzcat(L19_s);
data = horzcat(L_s,data);
data = horzcat(npdiv_s,data);
data = horzcat(city_s,data);
data = horzcat(distgg_s,data);
data = horzcat(sigmastore,data);
data = horzcat(mustore,data);
data = horzcat(etastore,data);
data = horzcat(deltastore,data);
data = horzcat(H_e,data);
data = horzcat(om_e,data);
data = horzcat(PH_e,data);
data = horzcat(E_e,data);
data = horzcat(w_e,data);
data = horzcat(PM_e,data);
data = horzcat(p_e,data);
data = horzcat(n_e,data);
data = horzcat(L_e,data);
data = horzcat(ystore,data);
vals=((y-1)*119)+1;
vale=y*119;
simresults(vals:vale,:)=data;
convtest(y,1)=calconverge;
convtest(y,2)=simconverge;

% Store the parameters and moments;

output(y,1)=sigma; output(y,2)=mu; output(y,3)=eta;
output(y,4)=delta; output(y,5)=sgn; 
output(y,6)=npd_0_75; output(y,7)=npd_75; 
output(y,8)=mod_0_75; output(y,9)=mod_75;
output(y,10)=smnpd_0_75; output(y,11)=smnpd_75; 
output(y,12)=smmod_0_75; output(y,13)=smmod_75;
output(y,14)=lanpd_0_75; output(y,15)=lanpd_75; 
output(y,16)=lamod_0_75; output(y,17)=lamod_75;
output(y,18)=y;

y = y + 1;
end;

% **********************************************************;
% **** End of the loop for each set of parameter values ****;
% **********************************************************;

% *************************************************;
% **** DETERMINE THE BEST FIT PARAMETER VECTOR ****;
% *************************************************;

% Extract treatments for all parameter configurations

npd_0_75 = output(:,6); npd_75 = output(:,7);
mod_0_75 = output(:,8); mod_75 = output(:,9);
smnpd_0_75 = output(:,10); smnpd_75 = output(:,11);
smmod_0_75 = output(:,12); smmod_75 = output(:,13);
lanpd_0_75 = output(:,14); lanpd_75 = output(:,15);
lamod_0_75 = output(:,16); lamod_75 = output(:,17);
simorder = output(:,18);

% Find the parameter vector with the smallest sum of;
% squared deviations between the simulated and estimated;
% division treatments;

smalldiff = (smmod_0_75-smmod_75)-(smnpd_0_75-smnpd_75);
largediff = (lamod_0_75-lamod_75)-(lanpd_0_75-lanpd_75);
diff = (smalldiff.^2)+(largediff.^2);
Mdiff = min(diff);
fMdiff = find(diff==Mdiff);

% Extract simulation results for preferred parameter values;

moutput = output(fMdiff,:);
msigma = moutput(:,1); mmu = moutput(:,2);
meta = moutput(:,3); mdelta = moutput(:,4);
msimorder = moutput(:,18);

npd_0_75 = moutput(:,6); npd_75 = moutput(:,7);
mod_0_75 = moutput(:,8); mod_75 = moutput(:,9);
smnpd_0_75 = moutput(:,10); smnpd_75 = moutput(:,11);
smmod_0_75 = moutput(:,12); smmod_75 = moutput(:,13);
lanpd_0_75 = moutput(:,14); lanpd_75 = moutput(:,15);
lamod_0_75 = moutput(:,16); lamod_75 = moutput(:,17);

% Extract the data for individual cities for preferred parameter values;

simorder = simresults(:,1);
fsimresults = find(simorder==msimorder);
msimresults = simresults(fsimresults,:);

% Display results for preferred parameter values;

display('Best-fit Parameter Vector');
display('sigma   mu  eta  delta');
moutput(:,1:4)
display('Average Simulated Treatment Effect Overall');
mod_0_75-mod_75
display('Average Estimated Treatment Effect Overall');
npd_0_75-npd_75
display('Average Simulated Treatment Effect Small Cities');
smmod_0_75-smmod_75
display('Average Estimated Treatment Effect Small Cities');
smnpd_0_75-smnpd_75
display('Average Simulated Treatment Effect Large Cities');
lamod_0_75-lamod_75
display('Average Estimated Treatment Effect Large Cities');
lanpd_0_75-lanpd_75

% *******************;
% **** SAVE DATA ****;
% *******************;

% Results for individual cities from all parameter configurations;
% csvwrite('Z:/SRDS/RemotenessAER/grid_search/data/Data.csv',simresults);
% Results for individual cities for bestfit parameter configuration;
csvwrite('Z:/SRDS/RemotenessAER/grid_search/data/BestfitData.csv',msimresults);
% Simulated and estimated division treatments for all parameter;
% configurations;
csvwrite('Z:/SRDS/RemotenessAER/grid_search/data/output.csv',output);
% Convergence test for all parameter configurations;
csvwrite('Z:/SRDS/RemotenessAER/grid_search/data/ConvTest.csv',convtest);

