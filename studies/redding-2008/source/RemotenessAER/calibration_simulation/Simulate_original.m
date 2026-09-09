
% Calibration and Simulation for Redding-Sturm;

% SJR, February, 2008;

clear;
clc;

format short;

disp('Original Simulation Program');

% Parameter values;

% Elasticity of substitution;
sigma=4;

% Share of spending on manufactures;
mu=0.66;

% Fixed production cost;
F=1;

% Common technology parameter;
phi=1;

% Constant in wage equation
xi = (F*(sigma-1))^(-(1/sigma)) * ((sigma-1)/sigma) * phi;

% DATA;
% Read in data (206 pre-war German cities);
% Pre-war German cities include cities in the future West Germany,;
% future East Germany, future parts of Poland, future parts of Russia;
% As with the regression sample, the three Saarland cities are excluded 
% from these data for the calibration and simulation of the model;
citydata = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/OrigCalibData.csv');
sizecitydata=size(citydata);

% Extract variables from data;
% Columns of citydata correspond to the following variables;
% Column 1 : population in 1939 : pop;
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
% Column 15 : population in 1919 : pop19
% Column 16 : number of varieties in each city in the calibration : n_cal;
% Column 17 : variety price in each city in the calibration : p_cal;
% Column 18 : price index for tradeable varieties in each city in the calibration : PM_cal;
% Column 19 : nominal wage in each city in the calibration : w_cal;
% Column 20 : aggregate expenditure in each city in the calibration : E_cal;
% Column 21 : price of the non-traded amenity in each city in the calibration : PH_cal;
% Column 22 : real wage in each city in the calibration : om_cal;
% Column 23 : stock of the non-traded amenity in each city in the calibration : H_cal;

L_i = citydata(:,1);
w_i = citydata(:,19);
n_i = citydata(:,16);
p_i = citydata(:,17);
PM_i = citydata(:,18);
PH_i = citydata(:,21);
om_i = citydata(:,22);
H_e = citydata(:,23);
n_e = citydata(:,16);
p_e = citydata(:,17);
PM_e = citydata(:,18);
w_e = citydata(:,19);
E_e = citydata(:,20);
PH_e = citydata(:,21);
brd = citydata(:,4);
city = citydata(:,5);
distgg = citydata(:,6);
L39 = citydata(:,1);
infdiv = citydata(:,12);

% Read in bilateral trade cost matrix (206 pre-war German cities);
% T = dist^(-1);
T = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/MatlabTrans.csv');
% Read in bilateral identifier for pairs of cities within future West Germany;
brdbrd_p = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/Matlabbrdbrd.csv');

sizeT = size(T);

% Keep only rows that correspond to West Germany;

cutb = find(brd==0);

L_i(cutb) = [];
w_i(cutb) = [];
n_i(cutb) = [];
p_i(cutb) = [];
PM_i(cutb) = [];
PH_i(cutb) = [];
om_i(cutb) = [];
H_e(cutb) = [];
n_e(cutb) = [];
p_e(cutb) = [];
PM_e(cutb) = [];
w_e(cutb) = [];
E_e(cutb) = [];
PH_e(cutb) = [];
brd(cutb) = [];
city(cutb) = [];
distgg(cutb) = [];
L39(cutb) = [];
infdiv(cutb) = [];
citydata(cutb,:) = [];

sizeL_i = size(L_i);
sizebrd = size(brd);

% Keep only bilateral pairs within West Germany;

T(cutb,:) = [];
T(:,cutb) = [];
brdbrd_p(cutb,:) = [];
brdbrd_p(:,cutb) = [];
sizeT = size(T);
sizebrdbrd_p = size(brdbrd_p);

% Total population of West German cities;
LL_i = sum(L_i);

% Initial distribution of endogenous variables;

L_e=L_i;

n_e  = (phi./(F.*sigma)).*L_e;
p_e  = (sigma./(sigma-1)).*(w_e./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_e.*L_e.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L_e)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

% Solve system of equations - coarse criterion;
% for equilibrium that the real wage in each city;
% is the same to three decimal places;

converge=0;

disp('>>> Simulating <<<');

i=1;

while i<100000;

n_e  = (phi./(F.*sigma)).*L_e;
p_e  = (sigma./(sigma-1)).*(w_e./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_e.*L_e.*(PM_e.^(sigma-1)))).^(1./sigma);
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
    converge=1;
    display('>>> Converged <<<');
    i=100000;
    
else

% Reallocate population across West German cities;
% until the real wage is the same in each West German city;

z = 1;
while z <= sizeL_i(1);
    if iwgap(z) > 0;
    L_e(z) = L_e(z) + 10;
    elseif iwgap(z) == 0;
    L_e(z) = L_e(z);
    elseif iwgap(z) < 0;
    L_e(z) = L_e(z) - 10;
end;
z = z + 1;
end;
   
% Ensure that the total West German population remains constant;

LL_e = sum(L_e);
adjust = (LL_i - LL_e)./sizeL_i(1);
L_e = L_e + adjust;
LL_e = sum(L_e);

end;
i = i + 1;
end;

% End of solving system of equations - coarse criterion;

% Solve system of equations - fine criterion;
% for equilibrium that the real wage in each city;
% is the same to four decimal places;

converge=0;

disp('>>> Simulating <<<');

i=1;

while i<100000;

n_e  = (phi./(F.*sigma)).*L_e;
p_e  = (sigma./(sigma-1)).*(w_e./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_e.*L_e.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L_e)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

mom_e=median(om_e);
iom_e=om_e*10000;
imom_e=mom_e*10000;
iom_e=round(iom_e);
imom_e=round(imom_e);

if iom_e == imom_e;
    L_e = L_e;
    converge=1;
    display('>>> Converged <<<');
    i=100000;
    
else 

% Reallocate population across West German cities;
% until the real wage is the same in each West German city;
    
z = 1;
while z <= sizeL_i(1);
    if iom_e(z) > imom_e;
    L_e(z) = L_e(z) + 5;
    elseif iom_e(z) == imom_e;
    L_e(z) = L_e(z);
    elseif iom_e(z) < imom_e;
    L_e(z) = L_e(z) - 5;
end;
z = z + 1;
end;
   
% Ensure that the total West German population remains constant;

LL_e = sum(L_e);
adjust = (LL_i - LL_e)./sizeL_i(1);
L_e = L_e + adjust;
LL_e = sum(L_e);

end;
i = i + 1;
end;

% End of solving system of equations - fine criterion;

% Output the data from this simulation;

data = H_e;
data = horzcat(om_e,data);
data = horzcat(PH_e,data);
data = horzcat(E_e,data);
data = horzcat(w_e,data);
data = horzcat(PM_e,data);
data = horzcat(p_e,data);
data = horzcat(n_e,data);
data = horzcat(L_e,data);
data = horzcat(citydata,data);

csvwrite('Z:/SRDS/RemotenessAER/calibration_simulation/data/OrigSimData.csv',data);

