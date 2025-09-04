%% 三清、计时
clc,clear,close all %清除缓存
%% 读取网格化csv文件
disp('1.读取网格文件...');
tic;%计时
[filename,pathname]=uigetfile({'*.mat','Matlab Files(*.mat)'},'打开文件');
str=[pathname,filename];
% str = ['C:\Users\Chen\Documents\MATLAB\ljf\Pinsan_3mm\show\','example.mat'];
load(str);%读取数据文件
% clear pathname str 
toc;


%% 获取Nodes列表
nodes_xyz = cell(nodes_num,1);

x1=mesh_all(:,5);x2=mesh_all(:,6);x3=mesh_all(:,7);%网格截面为xy，读取节点坐标
y1=mesh_all(:,8);y2=mesh_all(:,9);y3=mesh_all(:,10);
node1_index = mesh_all(:,2);node2_index = mesh_all(:,3);node3_index = mesh_all(:,4);

for i = 1:elements_num
    nodes_xyz{node1_index(i)} = [x1(i) y1(i) 0];
    nodes_xyz{node2_index(i)} = [x2(i) y2(i) 0];
    nodes_xyz{node3_index(i)} = [x3(i) y3(i) 0];
end
nodes_xyz = cell2mat(nodes_xyz);
clear x1 x2 x3 y1 y2 y3 node1_index node2_index node3_index;

%% 获取Mesh_list
mesh_list = mesh_all(:,[2,3,4]);


%%  显示原截面
figure;
view(3);
S1.Vertices = nodes_xyz;
S1.Faces = mesh_list;
S1.FaceColor = 'flat';
color = ones(elements_num,1);
% color(28) = 0;
   color([677;678;310;313;676;311]) = 0;

% S1.FaceVertexCData = color;
% S1.FaceVertexCData = (1:elements_num)';

S1.EdgeColor = 'red';
S1.LineWidth = 1;
patch(S1)
hold on
% plot([-0.005128521200000,-3.470000000000000e-18,0])
% plot3(0,0.010000000000000,0,'*')
% hold on

% plot3(line_mesh(:,1),line_mesh(:,2),line_mesh(:,3),'*')
% temp_dots = 