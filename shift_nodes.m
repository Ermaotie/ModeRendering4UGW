function [new_nodes_xyz] = shift_nodes(nodes_xyz,shift_vec)
%SHIFT_NODES 此处显示有关此函数的摘要
%   此处显示详细说明
%   shift为1*3的向量
new_nodes_xyz = zeros(size(nodes_xyz));
for i = 1:length(nodes_xyz)
    new_nodes_xyz(i,:) = nodes_xyz(i,:) + shift_vec;
end

end

