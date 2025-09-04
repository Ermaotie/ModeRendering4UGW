function [trans_ele,trans_nodes_xyz] = generate_trans_sec_mesh(line_mesh,z_length,trans_num)
%GENERATE_TRANS_SEC_MESH 此处显示有关此函数的摘要
%   此处显示详细说明
%   line_mesh 按顺序的线网格节点xyz
line_mesh_num = size(line_mesh,1);
trans_elements_num = line_mesh_num * trans_num;
trans_nodes_num = line_mesh_num * (trans_num + 1);
trans_nodes_xyz = zeros(trans_nodes_num,3);

for i=1:trans_num+1
    start = 1+(i-1)*line_mesh_num;
    n_end = line_mesh_num+(i-1)*line_mesh_num;
    temp_line_mesh = line_mesh;
    z = ones(line_mesh_num,1)*(i-1)*z_length/trans_num;
    temp_line_mesh(:,3) = z;
    trans_nodes_xyz(start:n_end,:) = temp_line_mesh;
end

index = 1:trans_nodes_num;
index_mat = reshape(index,[line_mesh_num,trans_num+1]);

trans_ele = zeros((line_mesh_num-1)*(trans_num),4);

tmp = 1;
for col_t = 1:trans_num
    for row_t = 1:(line_mesh_num-1)
        trans_ele(tmp,:) = [index_mat(row_t,col_t), index_mat(row_t+1,col_t), index_mat(row_t+1,col_t+1), index_mat(row_t,col_t+1)];
        tmp = tmp+1;
    end
      
end


end

