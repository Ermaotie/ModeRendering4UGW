%% 三清、计时
clc,clear,close all %清除缓存
%% 读取网格文件
disp('1.读取网格文件...');
tic;%计时
[filename,pathname]=uigetfile({'*.mat','Matlab Files(*.mat)'},'打开文件');
str=[pathname,filename];
% str = ['C:\Users\Chen\Documents\MATLAB\ljf\Pinsan_3mm\show\','example.mat'];
%   细网格文件路径位于 C:\Users\Chen\Documents\MATLAB\ljf\3mm 下 show_example
load(str);%读取数据文件
clear pathname str 
toc;


%% 选择模态序号及频率,获取对应各节点位移矩阵Q
disp('2.选择模态序号及频率（前面所求包括的）');
m = 14;
f = 350;
U = Us_new(m,f);
clear Us_new;
U = U{1,1}(:,1);
cg = Cg(m,f); %对应模态群速度
clear Cg;



%% 挑选模态
disp('3.设置模态参数');
tic; %计时

% nodes, elements, time
% 设置k, z, ω, t
k = new_wave(m,f);
w = f * 1000 * (2*pi);
% nodes = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0];


step = 50;
rp_time = 1; % 重复周期数
time_length = 1/f/1000;
time = 0:time_length/step:time_length*rp_time; % 假设需要更新节点位置的时间序列为0到3，步长为0.01

mesh_list = mesh_all(:,[2,3,4]);
toc;

%% 获取N、Q,获得A矩阵(对应节点)
disp('4.计算N与Q,获得A矩阵');
tic; %计时
syms x y;
A = cell(1,nodes_num);

% ["elements", "node1", "node2", "node3", "x1", "x2", "x3", "y1", "y2", "y3", "z1", "z2", "z3"];% 指定列名称和类型
x1=mesh_all(:,5);x2=mesh_all(:,6);x3=mesh_all(:,7);%网格截面为xy，读取节点坐标
y1=mesh_all(:,8);y2=mesh_all(:,9);y3=mesh_all(:,10);
node1_index = mesh_all(:,2);node2_index = mesh_all(:,3);node3_index = mesh_all(:,4);

for i=1:elements_num
    Na = double(subs(N_all{1,i},[x,y],[x1(i),y1(i)]));
    Nb = double(subs(N_all{1,i},[x,y],[x2(i),y2(i)]));
    Nc = double(subs(N_all{1,i},[x,y],[x3(i),y3(i)]));

    Q = [U(3*(node1_index(i)-1)+1) U(3*(node1_index(i)-1)+2) U(3*(node1_index(i)-1)+3) U(3*(node2_index(i)-1)+1) U(3*(node2_index(i)-1)+2) U(3*(node2_index(i)-1)+3) U(3*(node3_index(i)-1)+1) U(3*(node3_index(i)-1)+2) U(3*(node3_index(i)-1)+3) ]';
    
    A1 = Na * Q;
    A2 = Nb * Q;
    A3 = Nc * Q;
    A{1,node1_index(i)} = A1;
    A{1,node2_index(i)} = A2;
    A{1,node3_index(i)} = A3;
end
A = cell2mat(A)';

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

toc; %读取时间
clear A1 A2 A3 Ae i N_all Na Nb Nc Q str U x y;


disp('5.创建侧面网格');
tic; %计时
%%%% 思路，确定轮廓，展开

% 截面位置 0~1之间的数

clear i mesh_all mesh_center mesh_fir_point mesh_sec_point mesh_thi_point node1_index node2_index node3_index x1 x2 x3 y1 y2 y3;
% 获取contour_mesh
[contour_nodes_xyz, contour_nodes_list] = get_contour_mesh(mesh_list,mesh,nodes_xyz);
contour_num = length(contour_nodes_list);

%%%% 创建传播方向新截面mesh

% z 方向上原截面为0 , 向z轴正方向拉伸N个周期的长度
N = 1;
% z_length = 2*pi/new_wave(m,f) * N; % 波数计算的周期
z_length = cg / f / 1000 * N;


% 传播方向网格数
trans_num = 100;

[trans_ele, trans_nodes_xyz] = generate_trans_sec_mesh(contour_nodes_xyz,z_length,trans_num);


toc;


disp('6.计算原截面与侧面的对应的EQ值');
tic; %计时
%%%% 原截面A_o
A_o = A;
%%%% 底面A_d
A_d = A * exp(1j*(k*z_length));
%%%% 侧面A_trans
A_c = A(contour_nodes_list,:);

A_trans = zeros(size(trans_nodes_xyz));

z = (0:trans_num)*z_length/trans_num;
for i = 1:trans_num+1
    start = (i-1)*contour_num + 1;
    n_end = i*contour_num;
    A_trans(start:n_end,:) = A_c*exp(1j*(k*z(i)));
end

toc;


disp('7.设置坐标系, 计算位移，绘制两截面')
tic; %计时
% 设置坐标系
f = figure(2);
fp = [128,48,1194,937];
set(gcf,'Position',fp);

view(3); % 将视角切换到三维
%%%% 找x,y 上的极差与中心
x_length = max(nodes_xyz(:,1))-min(nodes_xyz(:,1));
y_length = max(nodes_xyz(:,2))-min(nodes_xyz(:,2));

x_center = (max(nodes_xyz(:,1))+min(nodes_xyz(:,1)))/2;
y_center = (max(nodes_xyz(:,2))+min(nodes_xyz(:,2)))/2;
z_center = z_length/2;

center = [x_center, y_center, z_center];


expansion = 1.2;

lim_span = [ x_length/2*expansion;
             y_length/2*expansion;
             z_length/2*expansion];

rot_angle = [pi/2,0,pi/2];

lim_span = abs(rotate_nodes(lim_span',rot_angle))';

% 获取到坐标轴限制范围
lim_list = [-lim_span,lim_span];

xlim(lim_list(1,:));ylim(lim_list(2,:));zlim(lim_list(3,:));



% 设置原截面S_o
S_o.Vertices = nodes_xyz;
S_o.Faces = mesh_list;
S_o.FaceColor = 'flat';
S_o.EdgeColor = 'none';
S_o.LineWidth = 0.01;

% 设置底截面S_d
nodes_xyz_d = nodes_xyz;
nodes_xyz_d(:,3) = ones(length(nodes_xyz_d),1)*z_length;

S_d.Vertices = nodes_xyz_d;
S_d.Faces = mesh_list;
S_d.FaceColor = 'flat';
S_d.EdgeColor = 'none';
S_d.LineWidth = 0.01;

% 设置侧面S_trans
S_trans.Vertices = trans_nodes_xyz;
S_trans.Faces = trans_ele;
S_trans.FaceColor = 'flat';
S_trans.EdgeColor = 'none';
S_trans.LineWidth = 0.01;

% 各截面平移相同的量，使得中心位于原点处
shift_nodes_xyz_o = shift_nodes(nodes_xyz,-center);
shift_nodes_xyz_d = shift_nodes(nodes_xyz_d,-center);
shift_nodes_xyz_trans = shift_nodes(trans_nodes_xyz,-center);


% 根据不同位移量设置不同颜色
displacement_o = sqrt(sum(A_o.*A_o,2));
ele_mean_o = mean(displacement_o(mesh_list),2);

displacement_d = sqrt(sum(A_d.*A_d,2));
ele_mean_d = mean(displacement_d(mesh_list),2);

displacement_trans = sqrt(sum(A_trans.*A_trans,2));
ele_mean_trans = mean(displacement_trans(trans_ele),2);

% S_o.FaceVertexCData = normalize(abs(ele_mean_o),"range");
% S_d.FaceVertexCData = normalize(abs(ele_mean_d),"range");
% S_trans.FaceVertexCData = normalize(abs(ele_mean_trans),"range");

S_o.FaceVertexCData = abs(ele_mean_o);
S_d.FaceVertexCData = abs(ele_mean_d);
S_trans.FaceVertexCData = abs(ele_mean_trans);



factor = 0.003;
% 绘制

for t = time
    nodes_displacement_o = real(A_o * exp(1j*(-w*t)));
    nodes_displacement_d = real(A_d * exp(1j * (-w*t)));
    nodes_displacement_trans = real(A_trans * exp(1j*(-w*t)));
    % 各截面旋转
    S_o.Vertices = rotate_nodes(shift_nodes_xyz_o + nodes_displacement_o * factor,rot_angle);
    S_d.Vertices = rotate_nodes(shift_nodes_xyz_d + nodes_displacement_d * factor,rot_angle);
    S_trans.Vertices = rotate_nodes(shift_nodes_xyz_trans + nodes_displacement_trans* factor,rot_angle);
    cla;
    patch(S_o);
    hold on;
    patch(S_d);
    hold on;
    patch(S_trans);
    colormap jet;
    pause(0.05);
    colorbar;
    % 保存GIF
    % exportgraphics(gcf,'testAnimated.gif','Append',true);
end

toc;


