clear;clc;
%% Configuration
%Initial Chaser State
x0 = [7/8*pi;0;0];
u0 = [0;0];

%Target Trajectory
load_target_trajectory_theta;

%Sim/Controller Rates
dt_opt = 1;
dt_controller = 0.05;
dt_sim = 0.01;
tf = 16;

%MPC configuration

N = 50; % MPC predicition horizon

if(N*dt_controller < dt_opt)
    error("Error: control horizon insufficient for optimizer (too short)");
end

%% Generate & Run Simulation
ovsf = dt_controller/dt_sim; %oversampling factor
tspan_sim = 0:dt_sim:tf;
tspan_controller = 0:dt_controller:dt_opt;
tspan_opt = 0:dt_opt:tf;
tspan_ode = 0:dt_sim:dt_controller;

options = odeset('RelTol', 1e-9, 'AbsTol', 1e-9);

xk = x0;
u_hist = [];
x_hist = [];
for k = 1:length(tspan_opt)-1
    %tspan_ode = tspan_controller(k):dt_sim:tspan_controller(k+1);

    % Find the location of the target robot
    if tspan_opt(k) + N*dt_controller < tf %tspan_controller((k-1)*floor(dt_opt/dt_controller) + N) <= tf
        x_target_kpn = interp1(tspan_target,refTraj,tspan_opt(k) + N*dt_controller)';%tspan_controller((k-1)*floor(dt_opt/dt_controller) + N))';
    else
        x_target_kpn = interp1(tspan_sim,refTraj,tspan_sim(end))';
    end
    % Run controller to find u
    
    u = controller_nlp(xk,x_target_kpn,N,dt_controller);
    
    xc = xk;
    for c = 1:length(tspan_controller)-1
        %tspan_controller(c):dt_sim:tspan_controller(c+1);

        [~,x] = ode45(@dynamics,tspan_ode,xc,options,u(:,c));
        x_hist = [x_hist, x(1:end-1,:)'];
        u_hist = [u_hist, u(:,c).*ones(2,ovsf)];
        xc = x(end,:)';
        % Check for if the target is hit. If so, end sim.
        
%         if abs(x_target_kpn(end-1) - xk(end-1)) < 0.01 && abs(x_target_kpn(end) - xk(end)) < 0.01
%             disp("Target Hit!")
%             break
%         end
    end
    xk = xc;

    % Check for if the target is hit. If so, end sim.
%     if abs(x_target_kpn(end-1) - xk(end-1)) < 0.01 && abs(x_target_kpn(end) - xk(end)) < 0.01
%         disp("Target Hit!")
%         break
%     end
end
x_hist = [x_hist, x(end,:)'];




% Plot graphs
plot_trajectory;
plot_data;
