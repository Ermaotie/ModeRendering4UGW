%% 三清、计时
clc,clear,close all %清除缓存
%% 读取网格化csv文件
disp('1.读取网格文件...');
tic;%计时
% [filename,pathname]=uigetfile({'*.mat','Matlab Files(*.mat)'},'打开文件');
% str=[pathname,filename];
str = ['C:\Users\Chen\Documents\MATLAB\ljf\Pinsan_3mm\show\','example.mat'];
load(str);%读取数据文件
% clear pathname str 
toc;


%% 选择模态序号及频率,获取对应各节点位移矩阵Q
disp('2.选择模态序号及频率（前面所求包括的）');
m = 14;
f = 350;
U = Us_new(m,f);
U = U{1,1}(:,1);


%% 绘制
disp('4.绘制传播方向单截面动态效果');
tic; %计时

% nodes, elements, time
% 设置k, z, ω, t
k = new_wave(m,f);
w = f * 1000 * (2*pi);
% nodes = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0];


step = 50;

time_length = 1/f/1000;
time = 0:time_length/step:time_length*1000; % 假设需要更新节点位置的时间序列为0到3，步长为0.01

mesh_list = mesh_all(:,[2,3,4]);



%% 二维竖直截面，传播方向
%%%% 思路，确定要展示的传播截面的位置，计算点源，沿传播方向展开，坐标转换，展示

% 截面位置 0~1之间的数
section_distance = 0.5;

        % 创建网格描述变量mesh
        x1=mesh_all(:,5);x2=mesh_all(:,6);x3=mesh_all(:,7);%网格截面为xy，读取节点坐标
        y1=mesh_all(:,8);y2=mesh_all(:,9);y3=mesh_all(:,10);
        node1_index = mesh_all(:,2);node2_index = mesh_all(:,3);node3_index = mesh_all(:,4);
        nodes_xyz = cell(nodes_num,1);
        
        for i = 1:elements_num
            nodes_xyz{node1_index(i)} = [x1(i) y1(i) 0];
            nodes_xyz{node2_index(i)} = [x2(i) y2(i) 0];
            nodes_xyz{node3_index(i)} = [x3(i) y3(i) 0];
        end
        nodes_xyz = cell2mat(nodes_xyz);

mesh_fir_point = nodes_xyz(mesh_list(:,1),:);
mesh_sec_point = nodes_xyz(mesh_list(:,2),:);
mesh_thi_point = nodes_xyz(mesh_list(:,3),:);
mesh_center = (mesh_thi_point+mesh_sec_point+mesh_fir_point)/3;

mesh = {mesh_fir_point,mesh_sec_point,mesh_thi_point,mesh_center};

% 确定基点 （重写）[top,bottom]
[base_points,base_index] = get_bound_points(section_distance *(max(nodes_xyz(:,1))-min(nodes_xyz(:,1)))+min(nodes_xyz(:,1)), mesh);

%%%% 获取想要的点在哪个面元内
%通过与三角形中心距离大致锁定哪几个面元，再做准确判定，减少计算量
%准确判定方式： 面积法，向量法。面积法精度限制时会误判，采用向量法

%%% 大致判断+ 准确判断

% 获取line_mesh
[line_mesh, line_mesh_index] = get_line_mesh(base_points,mesh);
line_mesh_num = length(line_mesh_index);

%% 创建传播方向新截面mesh

% z 方向上原截面为0 , 向z轴正方向拉伸N个周期的长度
N = 1;
z_length = 2*pi/new_wave(m,f) * N;

% 传播方向网格数
trans_num = 80;

trans_nodes_num = length(line_mesh_index) * (trans_num+1);

trans_element_num = (length(line_mesh_index)-1) * trans_num;

% 获取nodes列表 ele列表
[trans_ele, trans_nodes_xyz] = generate_trans_sec_mesh(line_mesh,z_length,trans_num);


% 获取A (N Q)
%%%%% 获取N
syms x y;
A = zeros(length(line_mesh_index),3);


for i = 1:length(line_mesh_index)
    N = double(subs(N_all{1,i},[x,y],[line_mesh(i,1), line_mesh(i,2)]));


    Q = [U(3*(node1_index(line_mesh_index(i))-1)+1) U(3*(node1_index(line_mesh_index(i))-1)+2) U(3*(node1_index(line_mesh_index(i))-1)+3) U(3*(node2_index(line_mesh_index(i))-1)+1) U(3*(node2_index(line_mesh_index(i))-1)+2) U(3*(node2_index(line_mesh_index(i))-1)+3) U(3*(node3_index(line_mesh_index(i))-1)+1) U(3*(node3_index(line_mesh_index(i))-1)+2) U(3*(node3_index(line_mesh_index(i))-1)+3) ]';

    A(i,:) = (N * Q)';
end

clear A1 A2 A3 Ae i N_all Na Nb Nc Q str U x y;

%% 绘制
disp('4.绘制运动方向截面动态效果');
tic; %计时

% 设置坐标系
figure(2);
view(3); % 将视角切换到三维


range_x = z_length*1.2 ;range_y = 0.08; range_z = 0.05;
center_x = -z_length*1.2/2; center_y = 0; center_z = 0;
xlim([center_x-range_x/2, center_x+range_x/2]); % 设置X轴范围
ylim([center_y-range_y/2, center_y+range_y/2]); % 设置Y轴范围
zlim([-center_z-range_z/2, center_z+range_z/2]); % 设置Z轴范围

span_x = 0.1 * range_x;
span_y = 0.005 * range_y;
span_z = 0.1 * range_z;


S.Vertices = trans_nodes_xyz;
S.Faces = trans_ele;
% S.FaceVertexCData = (1:elements_num)';
% S.FaceVertexCData = 'none';

% S.FaceColor = 'yellow';
S.FaceColor = 'flat';
S.EdgeColor = 'red';
S.LineWidth = 1;



%%% 获取new_A
new_A = zeros(size(trans_nodes_xyz));
z = (0:trans_num)*z_length/trans_num;
for ii = 1:trans_num+1
        start = 1+(ii-1)*line_mesh_num;
        n_end = ii*line_mesh_num;
        new_A(start:n_end,:) = A(:,[3,1,2]) * exp(1j*(k*z(ii)));
end

nodes_displacement = new_A;
[tmp_max, I] = max(abs(nodes_displacement(:,2)));

factor = span_y/tmp_max;

%%%%  根据位移大小分配不同颜色
%%%%% 节点位移模 displacement
displacement = sqrt(sum(nodes_displacement.*nodes_displacement,2));
% 单元位移模均值
ele_mean = mean(displacement(trans_ele),2);
S.FaceVertexCData = normalize(abs(ele_mean),"range");


nodes_xyz_verticle = -trans_nodes_xyz(:,[3,1,2]);



for t = time
% for i = 1:step
    nodes_displacement = real(new_A * exp(1j*(-w*t)))* factor;
    cla;
    S.Vertices = nodes_xyz_verticle + nodes_displacement;
    patch(S);
    pause(0.05);
end


toc;