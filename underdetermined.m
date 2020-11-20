% Demonstrate that the linear equation system for photometric 
% stereo is underdetermined for every single pixel.

image_dir = './photometrics_images/SphereGray2/';
[image_stack, scriptV] = load_syn_images(image_dir);
[h, w, n] = size(image_stack);
[albedo, normals] = estimate_alb_nrm(image_stack, scriptV);
[p, q, SE] = check_integrability(normals);
threshold = 0.005;
SE(SE <= threshold) = NaN; 
fprintf('Number of outliers: %d\n\n', sum(sum(SE > threshold)));
height_map = construct_surface( p, q );
show_results(albedo, normals, SE);
show_model(albedo, height_map);