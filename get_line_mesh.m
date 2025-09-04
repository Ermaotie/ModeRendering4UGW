function [line_mesh,line_mesh_index] = get_line_mesh(base_points,mesh,n)
%GET_LINE_MESH 此处显示有关此函数的摘要
%   此处显示详细说明
    % 根据首尾两点，获取传播方向截面一条边的线网格节点
    % 返回 线元坐标点集，对应所在mesh_id

% 不指定n的话按照最接近于原网格的尺寸创建网格
if(~exist('n','var'))
        avg_distance = sqrt(mean(sum((mesh{1}-mesh{2}).*(mesh{1}-mesh{2}),2)));
        n = fix((base_points(1,2)-base_points(2,2))*2/avg_distance)+1;
end
    y1 = base_points(1,2);
    y2 = base_points(2,2);
    x1 = base_points(1,1);
    y = linspace(y1,y2,n);
    x = linspace(x1,x1,n);
    tmp_z = linspace(0,0,n);
    line_mesh = [x', y', tmp_z'];
    line_mesh_index = [];
    for i = 1:n
        line_mesh_index(i) = get_mesh_id(line_mesh(i,:),mesh);
    end
    % line_mesh_index = cell2mat(line_mesh_index);

        
end

