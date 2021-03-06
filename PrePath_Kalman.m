function [path stepErr] = PrePath_Kalman(para)
path_real = para{1};
path_obser = para{2};
signType = para{3};
signPos = para{4};
frequency = para{5};
%% Parameters
T = 1 / frequency;
N = length(path_real);
delta_w  = 1e-3;
Q = diag([100, 0]);  % var of process noise
G = [T^2/2, 0;               % drive matrix of process noise
    T, 0;
    0, T^2/2;
    0, T];
R = diag([30, 0]);         % var of observed noise
F = [1, T, 0, 0;            % transfer matrix of state
    0, 1, 0, 0;
    0, 0, 1, T;
    0, 0, 0, 1];
%% Convert path_obser to observation value
path_pre = path_real;
path_bel = path_real;
path_pre(end, :) = []; path_bel(1, :) = [];
vector = path_bel - path_pre; 
vector_length = (sum(vector.^2, 2)).^(1/2);
vector_angle = GetAngle(vector(:, 1), vector(:, 2))';
%% EKF
Xekf = zeros(4, N);
Xekf(:, 1) = [path_obser(1,1);  % beginning position and speed
                0.01;
                path_obser(1,2);
                0.01];
P0 = eye(4);
for cnt = 2: N
    Xn = F * Xekf(:, cnt-1);    % Predict state
    P1 = F * P0 * F' + G * Q * G';       % Predict cov 
    dd = Xn - Xekf(:, cnt-1);   % Predict observation
    % dd = path_obser(cnt, :) - path_obser(cnt-1, :);
    Z = [norm(dd);
        GetAngle(dd(1), dd(2))];
    
    % distance and get Jacoobi H
    %{
    [type index dist_real] = GetSignDistance(path_real(cnt, :), signType, signPos);
    if(type ~= -1)
        R = diag([300, 3, 50]);
        vec = Xn' - signPos(index);
        H = [dd(1)/norm(dd), 0, dd(2)/norm(dd), 0;
        -dd(2)/(norm(dd))^2, 0, dd(1)/(norm(dd))^2, 0;
        vec(1)/norm(vec), 0, vec(2)/norm(vec), 0];
    else
        R = diag([300, 3]);
        H = [dd(1)/norm(dd), 0, dd(2)/norm(dd), 0;
        -dd(2)/(norm(dd))^2, 0, dd(1)/(norm(dd))^2, 0];
    end
    %}

    H = [dd(1)/norm(dd), 0, dd(2)/norm(dd), 0;
        -dd(2)/(norm(dd))^2, 0, dd(1)/(norm(dd))^2, 0];
    K = P1 * H' * inv(H * P1 * H' + R);
    Xekf(:, cnt) = Xn + K * ([vector_length(cnt-1); vector_angle(cnt-1)] - Z);
    P0 = (eye(4) - K * H) * P1;
end
%% Generate the route
path = Xekf([1 3], :)';
%% Canculate the errors of path_cons compared with the real path
stepErr = GetPositionError(path_real, path);
end