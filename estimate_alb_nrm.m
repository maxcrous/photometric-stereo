function [ albedo, normal ] = estimate_alb_nrm(image_stack, scriptV, shadow_trick)
%COMPUTE_SURFACE_GRADIENT compute the gradient of the surface
%   image_stack : the images of the desired surface stacked up on the 3rd
%   dimension
%   scriptV : matrix V (in the algorithm) of source and camera information
%   shadow_trick: (true/false) whether or not to use shadow trick in solving
%   	linear equations
%   albedo : the surface albedo
%   normal : the surface normal


[h, w, ~] = size(image_stack);
if nargin == 2
    shadow_trick = true;
end

% create arrays for 
%   albedo (1 channel)
%   normal (3 channels)
albedo = zeros(h, w, 1);
normal = zeros(h, w, 3);

% For each point in the image array
for row = 1:h
    for column = 1:w
        
        % Stack image values into a vector i
        i = image_stack(row, column, :);

        % Reshape i to an array
        i = i(:);
       
        if shadow_trick
            
            % Construct the diagonal matrix scriptI
            scriptI = diag(i);
            IV = scriptI * scriptV;
            
            % When a pixel has a value other than 0 in less than 3 lighting 
            % conditions, the linear equation will be underdetermined and 
            % linsolve will return g = [0, 0, 0] as a solution, resulting 
            % in albedo = 0 and normal = [Nan, Nan, Nan]. The linsolver 
            % will issue a rank defficient warning. 
            % To avoid this, the albedo and normal are manually set.
            if rank(IV) < 3
                albedo(row, column) = 0;
                normal(row, column, :) = [NaN, NaN, NaN];
                continue; 
            end
            
            % Solve scriptI * scriptV * g = scriptI * i to obtain g 
            g = linsolve(IV, scriptI * i);
            
        else 
            g = linsolve(scriptV, i);
        end
        
        % Albedo at this point is |g|
        albedo(row, column) = norm(g);
        
        % Normal at this point is g / |g|
        normal(row, column, :) = g ./ norm(g);
    end
end

end

