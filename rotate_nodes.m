function [new_nodes_xyz] = rotate_nodes(nodes_xyz,theta_xyz)
%ROTATE_NODES 此处显示有关此函数的摘要
%   此处显示详细说明
%   依次 绕全局x y z轴旋转
t1 = theta_xyz(1);
t2 = theta_xyz(2);
t3 = theta_xyz(3);
r_x = [1, 0, 0;
                0, cos(t1),-sin(t1);
                0, sin(t1), cos(t1)];
r_y = [cos(t2),0 ,sin(t2);
                0, 1, 0;
                -sin(t2), 0 ,cos(t2)];
r_z = [cos(t3),-sin(t3),0;
                sin(t3), cos(t3), 0
                0,0,1];

new_nodes_xyz = r_z * r_y * r_x * nodes_xyz';
new_nodes_xyz = new_nodes_xyz';
end

