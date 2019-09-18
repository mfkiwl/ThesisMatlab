%{
Part1:
TEST_ESTIMATE_POSITION:
Meeting 28/8
Verifiera beteendet hos estimate_position.m mha simuleringar, i 3 steg
1) Helt utan fel
2) Fel i mottagarposition
3) Klockfel (ms)
4) Fel i ber�knad satellitposition (slumpfel parameter/algoritmfel)
5) Fel i ber�knad satellitposition (klockfel UNIX->ToW conversion)

Kolla konvergens baserat p� olika fel i indata och plotta KLAR

Skall kolla hur konvergensen ser ut vid olika indata KLAR


For a given type of input noise, an error will be produced in the output
data. The behaviour is plotted in two kinds of graphs, investigating the
error in position estimate and clock bias estimate.
    1) How the error changes with an increasing error in input of given
    noise type, as well as the clock bias estimate.
    2) How the solution converges per iteration for both position and clock
    bias estimate.

How to run:
1) Load data
2) Create starting positions for receiver and satellites
3) Test the output of the simulations, either testing output or convergence
as specified by providing argument 'convergence'
--------------------------------------------------------------------------
Part 2: Relative position histograms from internal solution.
Plots histogram over indivudual estimates, using receiver 1 as reference 
position x0, as well as histogram over distance between estimated position 
between receivers. This is based on sampling estimates directly from
receiver, meaning that the position is at all times given by receiver
--------------------------------------------------------------------------
Part 3: Test magnitude between theoretical distance receiver<-->satellite
and measured. 
--------------------------------------------------------------------------
Part 4: Test Delta P over time for double differentiated satellite
measurements


%}
%% Load Data
addpath('../estGlobalPosition/')
addpath('../estGlobalPosition/SatsMove/')
addpath('../data');
addpath('../Simulations/GlobalPosEstimate')
load allLogData.mat
load allEstPos.mat
%% Create the starting position and satellite positions 
%Positions of satellites and receivers
in.pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
eph=ephE;
pSat=satPositions(eph, 0);
[~,elev]=ecef2elaz(pSat,in.pRec);
in.pSat=pSat(elev>10,:);
in.eph=eph(elev>10);
in.pSat=pSat(1:4,:);
in.eph=eph(1:4);
clearvars elev pSat eph;
%Error terms to be included in the simulations
in.eps.satPos=0; in.eps.recPos=0; in.eps.clockB=0; in.eps.gauss=0; in.eps.timeErr=0;
%% Testing the output of the simulations for different levels of input noise
% No noise 
in.noise='noiseless';
test_estimate_position(in);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in);
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in);
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in);
% Receiver positon error
%in.noise='recPos';
%test_estimate_position(in);
% Gaussian noise
in.noise='gauss';
test_estimate_position(in);
%% Testing the convergence of the simulations for different levels of input noise
% No noise 
in.noise='noiseless';
test_estimate_position(in, 'convergence', 1e-8);
% Receiver clock error
in.noise='clockB';
test_estimate_position(in,'convergence');
% Satellite position error (gaussian)
in.noise='satPos';
test_estimate_position(in,'convergence');
% Satellite position error (time conversion)
in.noise='clockErr';
test_estimate_position(in,'convergence');
% Receiver position error
%in.noise='recPos';
%test_estimate_position(in,'convergence');
% Gaussian noise
in.noise='gauss';
test_estimate_position(in,'convergence');
% Mixed noise in receiver position and clock bias
in.noise='mixedNoise';
test_estimate_position(in,'convergence', 1e-8);

%% Part 2: New plots over relative position from internal solution
%This plots the histogram of positions with rec1 as reference position p_0, 
%as well as the histogram of relative position between receivers.
close all
log_path='../Logs/Uggleviken0706';
%True distance between receivers
trueD=10; 
%True direction between receivers
direction='E';
%Logs to use for calculations
T1=strcat(log_path,'/',direction,'1/gps.csv');
T2=strcat(log_path,'/',direction,'2/gps.csv');
plotInternalSolution(T1,T2, trueD, direction, false);
direction='N';
T1=strcat(log_path,'/',direction,'1/gps.csv');
T2=strcat(log_path,'/',direction,'2/gps.csv');
plotInternalSolution(T1,T2, trueD, direction, false);
%% Part 3:
addpath('SatsMove/')
addpath('../data');
load allLogData.mat %Contains the raw log data organized in structs
load allEstPos.mat %Contains the positional estimate calculations already made
%% Step 2 compute the position based on the observation and ephmeris data
% 
%true position given by pRec as internal solution of E1_0706
pRec=[gpsData0706.ecef_0_(1) gpsData0706.ecef_1_(1) gpsData0706.ecef_2_(1)];
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, 1);
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, 2);
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, 3);
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, 4);
compare_obs_sat_pos(raw1E_0706,ephE_0706,pRec, 5);
%x1E_0706  = estGlobalPos(raw1E_0706(2), ephE_0706, 1);
% x1N       = estGlobalPos(raw1N, ephN, 1, 100);
%x1Ros=estGlobalPos(rawRos, ephRos)