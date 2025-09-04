function [intersections,index] = get_bound_points(x,mesh)
%GET_BOUND_POINTS 此处显示有关此函数的摘要
%   获取x=x_0坐标上 二维截面整体网格的交点 ，并返回对应的单元索引id
    meshes_index = get_mesh_id_by_x(x,mesh);
    %  %  使用重心找到最高最低的单元，不严谨此处, 网格单元形状太狭长时不适用
    match_mesh_centers = mesh{4}(meshes_index,2);
    [~,I]= sort(match_mesh_centers);
    top_index = meshes_index(I(end));
    bottom_index = meshes_index(I(1));
    index = [top_index bottom_index];
    top_tri = [mesh{1}(top_index,:);mesh{2}(top_index,:);mesh{3}(top_index,:)];
    top_tri = sortrows(top_tri,2,"descend");
    y_top = top_tri(2,2) + (top_tri(1,2)-top_tri(2,2))/(top_tri(1,1)-top_tri(2,1))*(x -top_tri(2,1));
    top_intersection = [x, y_top, 0];

    bottom_tri = [mesh{1}(bottom_index,:);mesh{2}(bottom_index,:);mesh{3}(bottom_index,:)];
    bottom_tri = sortrows(bottom_tri,2,"ascend");
    y_bottom = bottom_tri(2,2) + (bottom_tri(1,2)-bottom_tri(2,2))/(bottom_tri(1,1)-bottom_tri(2,1))*(x -bottom_tri(2,1));
    bottom_intersection = [x, round(y_bottom,10), 0];
    
    intersections = [top_intersection;bottom_intersection];
    %  
end

