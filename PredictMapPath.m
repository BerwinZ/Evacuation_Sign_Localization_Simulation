function [path maxErr accErr] = PredictMapPath(path_real, path_obser, boundPos)
%% Parameters
prtcleNum = 1000;
Q = 1000;
prtcle = repmat(path_obser(1,:), [prtcleNum 1]) + sqrt(Q) * randn(prtcleNum, 2);
weight = ones(prtcleNum, 1) * 1 / prtcleNum;    
path(1, :) = sum(prtcle) / prtcleNum;
%% Canculation
for cnt = 2: length(path_obser) 
    % Update the particles of the next time point
    prtcle = prtcle + sqrt(Q) * randn(prtcleNum, 2);
    % Canculate the weight of particles and resample the particles
    [prtcle weight] = UpdateParticle(prtcle, weight, ...
        path(cnt-1, :), path_obser(cnt,:) - path_obser(cnt-1, :), boundPos, 0);
    % Canculate the path according to the particle set
    path(cnt, :) = sum(prtcle) / prtcleNum;
end
%% Canculate the errors of path_cons compared with the real path
[maxErr, accErr] = GetPositionError(path_real, path);
end