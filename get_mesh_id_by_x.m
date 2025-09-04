function [index] = get_meshes_id_by_x(x,mesh)
%GET_MESH_ID_BY_X 此处显示有关此函数的摘要
%   x 坐标 mesh 网格结构单元
% 通过x坐标找到 在包含x在内的meshes

% 找所有mesh的x的最大最小值，确定范围
mesh_min = min([mesh{1,1}(:,1) mesh{1,2}(:,1) mesh{1,3}(:,1)],[],2);
mesh_max = max([mesh{1,1}(:,1) mesh{1,2}(:,1) mesh{1,3}(:,1)],[],2);

index_1 = find(x<mesh_max);

index_2 = find(x>mesh_min);

index = intersect(index_1,index_2);


end

