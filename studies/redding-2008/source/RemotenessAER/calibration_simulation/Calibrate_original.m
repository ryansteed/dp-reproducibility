
% Calibration and Simulation for Redding-Sturm;

% SJR, February, 2008;

clear;
clc;

format bank;

disp('Original Calibration Program');

% Parameter values;

% Elasticity of substitution;
sigma=4;

% Share of spending on manufactures;
mu=0.66;

% Fixed production cost;
F=1;

% Common technology parameter;
phi=1;

% Constant in wage equation;
xi = (F*(sigma-1))^(-(1/sigma)) * ((sigma-1)/sigma) * phi;

% DATA;
% Read in data (206 pre-war German cities);
% Pre-war German cities include cities in the future West Germany,;
% future East Germany, future parts of Poland, future parts of Russia;
% As with the regression sample, the three Saarland cities are excluded 
% from these data for the calibration and simulation of the model;
citydata = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/MatlabPopData.csv');
% Read in bilateral trade cost matrix (206 pre-war German cities);
% T = dist^(-1);
T = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/MatlabTrans.csv');
% Read in bilateral identifier for pairs of cities within future West Germany;
brdbrd_p = csvread('Z:/SRDS/RemotenessAER/calibration_simulation/data/Matlabbrdbrd.csv');

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

% City characteristics;
L=citydata(:,1);
lat=citydata(:,2);
long=citydata(:,3);
city=citydata(:,5);
sizecitydata=size(citydata)
sizeL=size(L)
% Distance;
sizeT=size(T)

% Total population of all cities;
LL=sum(L);

% Initial distribution of endogenous variables;

w_i  = 100*ones(206,1);
H_e  = L*100;

n_e  = (phi./(F.*sigma)).*L;
p_e  = (sigma./(sigma-1)).*(w_i./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_i.*L.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

% Solve system of equations - coarse criterion;
% for equilibrium that the real wage in each city;
% is the same to three decimal places;

converge=0;

disp('>>> Calibrating <<<');

i=1;

while i<100000;

n_e  = (phi./(F.*sigma)).*L;
p_e  = (sigma./(sigma-1)).*(w_e./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_e.*L.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

iom_e = round(om_e*1000);
test=abs(iom_e);
test=test-1000;
Sumtest=sum(test);

if iom_e(:) == 1000;
    converge=1;
    display('>>> Converged <<<');
    i=100000;
    
else;

% Adjust the housing stock of each pre-war German city;
% so that the real wage is equal to one in each;
% pre-war German city;

z = 1;
while z <= sizeL(1);
    if iom_e(z) > 1000;
    H_e(z) = H_e(z) .* 0.95;
    elseif iom_e(z) == 1000;
    H_e(z) = H_e(z);
    elseif iom_e(z) < 1000;
    H_e(z) = H_e(z) .* 1.05;
end;
z = z + 1;
end;

i = i + 1;
end;
end;

% End of solving system of equations - coarse criterion;

% Solve system of equations - fine criterion;
% for equilibrium that the real wage in each city;
% is the same to four decimal places;

converge=0;

disp('>>> Calibrating <<<');

i=1;

while i<100000;
    
n_e  = (phi./(F.*sigma)).*L;
p_e  = (sigma./(sigma-1)).*(w_e./phi);
PM_e = (T * (n_e .* (p_e.^(1-sigma)))).^(1./(1-sigma));
w_e  = xi .* (T * (w_e.*L.*(PM_e.^(sigma-1)))).^(1./sigma);
E_e  = (w_e.*L)./mu;
PH_e = ((1-mu).*E_e)./H_e;
om_e = w_e./((PM_e).^mu .* (PH_e).^(1-mu));

iom_e = round(om_e*10000);
test=abs(iom_e);
test=test-10000;
Sumtest=sum(test);

if iom_e(:) == 10000;
    converge=1;
    display('>>> Converged <<<');
    i=100000;
    
else;
    
% Adjust the housing stock of each pre-war German city;
% so that the real wage is equal to one in each;
% pre-war German city;

z = 1;
while z <= sizeL(1);
    if iom_e(z) > 10000;
    H_e(z) = H_e(z) .* 0.9999;
    elseif iom_e(z) == 10000;
    H_e(z) = H_e(z);
    elseif iom_e(z) < 10000;
    H_e(z) = H_e(z) .* 1.0001;
end;
z = z + 1;
end;

i = i + 1;
end;
end;

% End of solving system of equations - fine criterion;

% Output the data from this calibration;

data = horzcat(H_e);
data = horzcat(om_e,data);
data = horzcat(PH_e,data);
data = horzcat(E_e,data);
data = horzcat(w_e,data);
data = horzcat(PM_e,data);
data = horzcat(p_e,data);
data = horzcat(n_e,data);
data = horzcat(citydata,data);

csvwrite('Z:/SRDS/RemotenessAER/calibration_simulation/data/OrigCalibData.csv',data);

