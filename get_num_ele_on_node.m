function [num] = get_num_ele_on_node(node_id,ele_list)
%GET_NUM_ELE_ON_NODE 此处显示有关此函数的摘要
%   此处显示详细说明
num = (find(ele_list==node_id));
end

