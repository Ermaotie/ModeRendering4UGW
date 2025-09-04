%% 三清、计时
clc,clear,close all %清除缓存

str = ['get_contour_mesh_trail.mat'];
load(str);%读取数据文件


%% 找初始
[~,Index] = get_bound_points(0.01,mesh);
bottom_ele = ele_list(Index(2),:);
origin_ele_id = Index(2);



origin_nodes_id = [bottom_ele(1),bottom_ele(2),bottom_ele(3)];

[r1,c1] = find(ele_list==bottom_ele(1));
[r2,c2] = find(ele_list==bottom_ele(2));
[r3,c3] = find(ele_list==bottom_ele(3));


r_cell = {r1';r2'; r3'};
length_r = [length(r1) length(r2) length(r3)];
[~,I] = sort(length_r);

origin_nodes_id = origin_nodes_id(I);

origin_node_id = origin_nodes_id(1);

left_node_id = origin_nodes_id(1);

right_node_id = origin_nodes_id(2);

contour_nodes_list = [origin_node_id];
ele_on_edge_list = [origin_ele_id];
drop_nodes_list = [origin_nodes_id(3)];

while(right_node_id~=origin_node_id)
    contour_nodes_list(end+1) = right_node_id;
    
    [ele_ids,c] = find(ele_list==right_node_id);

    if(length(ele_ids)==1)
        drop_nodes_list(end) = 0;
        % drop_node_id = setdiff(ele_list(ele_ids,:),right_node_id);
        right_node_id = setdiff(ele_list(ele_ids,:),contour_nodes_list);
        % drop_node_id = setdiff(ele_list(ele_ids,:),right_node_id);
        contour_nodes_list(end+1) = right_node_id;
        [new_ele_ids,~] = find(ele_list==right_node_id);
        tmp_ele_ids = setdiff(new_ele_ids,ele_on_edge_list);
        same_edge = intersect(ele_list(tmp_ele_ids(1),:),ele_list(tmp_ele_ids(2),:));
        
        right_node_id = setdiff(setdiff(ele_list(tmp_ele_ids(1),:),same_edge),contour_nodes_list);
        if isempty(right_node_id)
            right_node_id = setdiff(setdiff(ele_list(tmp_ele_ids(2),:),same_edge),contour_nodes_list);
            ele_on_edge_list(end+1) = tmp_ele_ids(2);
        else
            ele_on_edge_list(end+1) = tmp_ele_ids(1);
        end
        % drop_node_id(end+1) = drop_node_id(1);

        
    elseif (length(ele_ids) == 2)
        next_ele_id = setdiff(ele_ids,ele_on_edge_list);
        ele_on_edge_list(end+1) = next_ele_id;
        right_node_id =  setdiff(setdiff(ele_list(next_ele_id,:),right_node_id),drop_nodes_list);


    elseif (length(ele_ids) == 3)
        tmp_ele_ids = setdiff(ele_ids,ele_on_edge_list);
        same_edge = intersect(ele_list(tmp_ele_ids(1),:),ele_list(tmp_ele_ids(2),:));
        new_drop_node_id = setdiff(same_edge,right_node_id);
        drop_nodes_list(end+1) = new_drop_node_id;
        
        right_node_id = setdiff(ele_list(tmp_ele_ids(1),:),same_edge);
        if intersect(right_node_id,drop_nodes_list) 
            right_node_id = setdiff(ele_list(tmp_ele_ids(2),:),same_edge);
            ele_on_edge_list(end+1) = tmp_ele_ids(2);
        else
            ele_on_edge_list(end+1) = tmp_ele_ids(1);
        end

            

        
    end
right_node_id

end







% left_node_id = 

% origin_point_id = 