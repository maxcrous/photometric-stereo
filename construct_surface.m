function [ height_map ] = construct_surface( p, q, path_type )
%CONSTRUCT_SURFACE construct the surface function represented as height_map
%   p : measures value of df / dx
%   q : measures value of df / dy
%   path_type: type of path to construct height_map, either 'column',
%   'row', or 'average'
%   height_map: the reconstructed surface


if nargin == 2
    path_type = 'column';
end

[h, w] = size(p);
height_map = zeros(h, w);

switch path_type
    case 'column' 
        q(1, 1) = 0;
        
        % Fill first column of q with its column-wise cumulative sum 
        q(:, 1) = cumsum(q(:, 1), 1);
        
        % Fill all other heightmap columns with values from p 
        % and take the row-wise cumulative sum
        height_map = p;
        height_map(:, 1) = q(:, 1);
        height_map = cumsum(height_map, 2);
               
    case 'row'
        p(1, 1) = 0;
        
        % Similar to column case but with 
        % column-wise cumulative sum
        p(1, :) = cumsum(p(1, :), 2);
        height_map = q;
        height_map(1, :) = p(1, :);
        height_map = cumsum(height_map, 1);
        
          
    case 'average'
        height_map_c = construct_surface(p, q, 'column');
        height_map_r = construct_surface(p, q, 'row');
        height_map = (height_map_c + height_map_r) ./ 2;
end
end

