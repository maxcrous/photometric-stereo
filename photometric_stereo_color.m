image_dir = './photometrics_images/SphereColor/';

[image_stack_r, scriptV] = load_syn_images(image_dir, 1);
[image_stack_g, ~] = load_syn_images(image_dir, 2);
[image_stack_b, ~] = load_syn_images(image_dir, 3);

% In the case of an absent color channel
% replace nans with 0's.
image_stack_r(isnan(image_stack_r)) = 0;
image_stack_g(isnan(image_stack_g)) = 0;
image_stack_b(isnan(image_stack_b)) = 0;

[h, w, n] = size(image_stack_g);

[albedo_r, normals_r] = estimate_alb_nrm(image_stack_r, scriptV);
[albedo_g, normals_g] = estimate_alb_nrm(image_stack_g, scriptV);
[albedo_b, normals_b] = estimate_alb_nrm(image_stack_b, scriptV);

albedo = (albedo_r + albedo_g + albedo_b) ./ 3;
mask = albedo == 0;
mask = cat(3,mask, mask, mask);

normals_r(isnan(normals_r)) = 0;
normals_g(isnan(normals_g)) = 0;
normals_b(isnan(normals_b)) = 0;

normals = (normals_r + normals_g + normals_b) ./ 3;

% Make normals unit vectors again
for row = 1:h
    for col = 1:w
        normal = normals(row, col, :);
        normal = normal(:);
        normal = normal / norm(normal);
        normals(row, col, :) = normal;
    end
end

% Set all normals outside of object back to NaN
normals(mask) = NaN;
[p, q, SE] = check_integrability(normals);
threshold = 0.005;
SE(SE <= threshold) = NaN;
height_map = construct_surface(p, q, 'average');

show_results(albedo, normals, SE);
show_model(albedo, height_map);
