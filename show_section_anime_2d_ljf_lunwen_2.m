%% 三清、计时
clc,clear,close all %清除缓存
%% 读取文件
disp('1.读取网格文件...');
tic;%计时
[filename,pathname]=uigetfile({'*.mat','Matlab Files(*.mat)'},'打开文件');
str=[pathname,filename];
% str = ['C:\Users\Chen\Documents\MATLAB\ljf\Pinsan_3mm\show\','example.mat'];
load(str);%读取数据文件
% clear pathname str 
toc;


%% 选择模态序号及频率,获取对应各节点位移矩阵Q
disp('2.选择模态序号及频率（前面所求包括的）');
m = 14;
f = 350;
U = Us_new(m,f);
U = U{1,1}(:,1);


%% 获取N、Q,获得A矩阵(对应节点)
disp('3.计算N与Q,获得A矩阵');
tic; %计时
syms x y;
A = cell(1,nodes_num);

% ["elements", "node1", "node2", "node3", "x1", "x2", "x3", "y1", "y2", "y3", "z1", "z2", "z3"];% 指定列名称和类型
x1=mesh_all(:,5);x2=mesh_all(:,6);x3=mesh_all(:,7);%网格截面为xy，读取节点坐标
y1=mesh_all(:,8);y2=mesh_all(:,9);y3=mesh_all(:,10);
node1_index = mesh_all(:,2);node2_index = mesh_all(:,3);node3_index = mesh_all(:,4);
% ppm=ParforProgressbar(elements_num,'showWorkerProgress', true,'title','获取形函数、被积分项中...'); % parfor进度条参数定义
% N_all = {};

for i=1:elements_num
    % Ae(i)=0.5*abs(det([1 x1(i) y1(i);1 x2(i) y2(i);1 x3(i) y3(i)]));%三角形单元面积，取xy截面，z为波传播方向
    

    %%%%%% 获得3个节点位置对应的形函数
    % N1(i)=((y2(i)-y3(i))*(x-x2(i))+(x3(i)-x2(i))*(y-y2(i)))/(2*Ae(i));%三角形单元形函数
    % N2(i)=((y3(i)-y1(i))*(x-x3(i))+(x1(i)-x3(i))*(y-y3(i)))/(2*Ae(i));
    % N3(i)=((y1(i)-y2(i))*(x-x1(i))+(x2(i)-x1(i))*(y-y1(i)))/(2*Ae(i));
    % N=[N1(i) 0 0 N2(i) 0 0 N3(i) 0 0;0 N1(i) 0 0 N2(i) 0 0 N3(i) 0;0 0 N1(i) 0 0 N2(i) 0 0 N3(i)];%形函数矩阵
    Na = double(subs(N_all{1,i},[x,y],[x1(i),y1(i)]));
    Nb = double(subs(N_all{1,i},[x,y],[x2(i),y2(i)]));
    Nc = double(subs(N_all{1,i},[x,y],[x3(i),y3(i)]));
    
    % Nx_all(i) = {[Na,Nb,Nc]};
%     ppm.increment(); % 进度条

    %%%%%%% 获取对应Q
    Q = [U(3*(node1_index(i)-1)+1) U(3*(node1_index(i)-1)+2) U(3*(node1_index(i)-1)+3) U(3*(node2_index(i)-1)+1) U(3*(node2_index(i)-1)+2) U(3*(node2_index(i)-1)+3) U(3*(node3_index(i)-1)+1) U(3*(node3_index(i)-1)+2) U(3*(node3_index(i)-1)+3) ]';
    
    A1 = Na * Q;
    A2 = Nb * Q;
    A3 = Nc * Q;

    %%%%%% 保存A幅值
    
    %%% 验证多个值是否一致
    % for ii = 1:10
    %     if isempty(A{node1_index(i),ii})
    %         A{node1_index(i),ii} = {A1};
    %         break
    %     end
    % end
    % 
    % for ii = 1:10
    %     if isempty(A{node2_index(i),ii})
    %         A{node2_index(i),ii} = {A2};
    %         break
    %     end
    % end
    % 
    % for ii = 1:10
    %     if isempty(A{node3_index(i),ii})
    %         A{node3_index(i),ii} = {A3};
    %         break
    %     end
    % end

    % 更新矩阵A
    A{1,node1_index(i)} = A1;
    A{1,node2_index(i)} = A2;
    A{1,node3_index(i)} = A3;
end
A = cell2mat(A)';
toc; %读取时间
clear A1 A2 A3 Ae i N_all Na Nb Nc Q str U x y;


%% 获取Nodes列表
nodes_xyz = cell(nodes_num,1);

for i = 1:elements_num
    nodes_xyz{node1_index(i)} = [x1(i) y1(i) 0];
    nodes_xyz{node2_index(i)} = [x2(i) y2(i) 0];
    nodes_xyz{node3_index(i)} = [x3(i) y3(i) 0];
end
nodes_xyz = cell2mat(nodes_xyz);
clear x1 x2 x3 y1 y2 y3 node1_index node2_index node3_index;


%% 绘制
disp('4.绘制单截面动态效果');
tic; %计时

% nodes, elements, time
% 设置k, z, ω, t
k = new_wave(m,f);
z = 0;
w = f * 1000 * (2*pi);
% nodes = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0];


step = 0.0000001;
time = 0:step:0.01; % 假设需要更新节点位置的时间序列为0到3，步长为0.01

mesh_list = mesh_all(:,[2,3,4]);



%%  显示原截面
% % figure;
% % view(2);
% % S1.Vertices = nodes_xyz;
% % S1.Faces = mesh_list;
% % S1.FaceVertexCData = (1:elements_num)';
% % S1.FaceColor = 'flat';
% % S1.EdgeColor = 'red';
% % S1.LineWidth = 1;
% % patch(S1)
% 

% 
% % 设置坐标系
% figure(1);
% view(3); % 将视角切换到三维
% 
% range_x = 0.08;range_y = 0.05; range_z = 0.05;
% center_x = 0; center_y = 0.0125; center_z = 0;
% 
% xlim([center_x-range_x/2, center_x+range_x/2]); % 设置X轴范围
% ylim([center_y-range_y/2, center_y+range_y/2]); % 设置Y轴范围
% zlim([-center_z-range_z/2, center_z+range_z/2]); % 设置Z轴范围
% 
% span_x = 0.1 * range_x;
% span_y = 0.1 * range_y;
% span_z = 0.05 * range_z;
% 
% temp = real(A);
% [tmp_max, I] = max(temp(:,3));
% 
% factor = span_z/tmp_max;
% 
% S.Vertices = nodes_xyz;
% S.Faces = mesh_list;
% S.FaceVertexCData = (1:elements_num)';
% S.FaceColor = 'flat';
% S.EdgeColor = 'red';
% S.LineWidth = 1;

% for t = time
% 
%     temp = real(A * exp(j*(k*z-w*t)));
%     cla;
%     S.Vertices = nodes_xyz + temp * factor;
%     % S.Vertices = nodes_xyz ;
%     patch(S);
%     pause(0.05);
% end
% 
% 
% toc;


%% 二维竖直截面

% mesh_list = mesh_all(:,[2,3,4]);



% % 设置坐标系
% figure(2);
% view(3); % 将视角切换到三维
% 
% %%%%%%%%%%%%%%% 坐标转换
% nodes_xyz_verticle = -nodes_xyz(:,[3,1,2]);
% 
% % range_x = 0.08;range_y = 0.05; range_z = 0.05;
% % center_x = 0; center_y = 0.0125; center_z = 0;
% range_x = 0.05;range_y = 0.08; range_z = 0.05;
% center_x = 0; center_y = 0; center_z = 0;
% xlim([center_x-range_x/2, center_x+range_x/2]); % 设置X轴范围
% ylim([center_y-range_y/2, center_y+range_y/2]); % 设置Y轴范围
% zlim([-center_z-range_z/2, center_z+range_z/2]); % 设置Z轴范围
% 
% span_x = 0.05 * range_x;
% span_y = 0.1 * range_y;
% span_z = 0.1 * range_z;
% 
% 
% 
% S.Vertices = nodes_xyz_verticle;
% S.Faces = mesh_list;
% % S.FaceVertexCData = (1:elements_num)';
% % S.FaceVertexCData = 'none';
% 
% % S.FaceColor = 'yellow';
% S.FaceColor = 'flat';
% S.EdgeColor = 'red';
% S.LineWidth = 1;
% 
% 
% 
% 
% nodes_displacement = real(-A(:,[3,1,2]));
% [tmp_max, I] = max(abs(nodes_displacement(:,1)));
% 
% factor = span_x/tmp_max;
% 
% %%%%  根据位移大小分配不同颜色
% %%%%% 节点位移模 displacement
% displacement = sqrt(sum(nodes_displacement.*nodes_displacement,2));
% % 单元位移模均值
% ele_mean = mean(displacement(mesh_list),2);
% S.FaceVertexCData = normalize(ele_mean,"range");
% 
% 
% for t = time
%     nodes_displacement = real(A(:,[3,1,2]) * exp(j*(k*z-w*t)));
%     cla;
%     S.Vertices = nodes_xyz_verticle + nodes_displacement * factor;
%     patch(S);
%     pause(0.05);
% end
% 
% 
% toc;

z_length = 0;
% 设置坐标系
figure(2);
view([-90 0]); % 将视角切换到三维
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
             0.02];

rot_angle = [pi/2,0,pi/2];

lim_span = abs(rotate_nodes(lim_span',rot_angle))';

% 获取到坐标轴限制范围
lim_list = [-lim_span,lim_span];

xlim(lim_list(1,:));ylim(lim_list(2,:));zlim(lim_list(3,:));


% 设置原截面S_o
S_o.Vertices = nodes_xyz;
S_o.Faces = mesh_list;
S_o.FaceColor = 'flat';
S_o.EdgeColor = '#808080';
S_o.LineWidth = 0.01;

shift_nodes_xyz_o = shift_nodes(nodes_xyz,-center);

factor = 0.15;

% 绘制颜色
displacement_o = sqrt(sum(A.*A,2));
ele_mean_o = mean(displacement_o(mesh_list),2);
S_o.FaceVertexCData = normalize(abs(ele_mean_o),"range");

for t = time
    nodes_displacement_o = real(A * exp(1j*(-w*t)));
    % 各截面旋转
    % S_o.Vertices = rotate_nodes(shift_nodes_xyz_o + nodes_displacement_o * factor,rot_angle);
    S_o.Vertices = rotate_nodes(shift_nodes_xyz_o ,rot_angle);
    cla;
    patch(S_o);
    
    hold on;

    pause(0.02);
end
toc;