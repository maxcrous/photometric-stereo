function [ p, q, SE ] = check_integrability( normals )
%CHECK_INTEGRABILITY check the surface gradient is acceptable
%   normals: normal image
%   p : df / dx
%   q : df / dy
%   SE : Squared Errors of the 2 second derivatives

normalsx = normals(:,:,1);
normalsy = normals(:,:,2);
normalsz = normals(:,:,3);

% p measures value of df / dx
p = normalsx./normalsz;
p(isnan(p)) = 0;

% q measures value of df / dy
q = normalsy./normalsz;
q(isnan(q)) = 0;

% approximate second derivate by neighbor difference
% pad to keep matrix dimensions the same
p_pad = padarray(p,[1 0],'replicate','pre');
dp_dy = diff(p_pad,1,1);

q_pad = padarray(q,[0 1],'replicate','pre');
dq_dx = diff(q_pad,1,2);

% Compute the Squared Errors SE of the 2 second derivatives SE
SE = (dp_dy - dq_dx).^2;

end

