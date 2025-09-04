%% 三清、计时
clc,clear,close all %清除缓存

nodes = [0, 0, 0; 1, 0, 0; 1, 1, 0; 0, 1, 0];
elements = [1, 2, 3, 4];
time = 0:0.1:1; % 假设需要更新节点位置的时间序列为0到1，步长为0.1

figure;
view(3); % 将视角切换到三维
% 手动设置坐标轴范围
xlim([-5, 5]); % 设置X轴范围
ylim([-5, 5]); % 设置Y轴范围
zlim([-5, 5]); % 设置Z轴范围

while true
    for t = time
        % 根据时间t更新节点位置，以简单的例子为：
        updated_nodes = nodes + t; 
    
        % 清空现有图形
        cla;
    
        % 绘制截面网格
        patch('Faces', elements, 'Vertices', updated_nodes, 'FaceColor', 'blue', 'EdgeColor', 'black');
        % axis equal;
    
        % 添加标题、标签等
        title(['时间：', num2str(t)]);
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        % 控制绘图速度
        pause(0.1);  % 以0.1秒为间隔展示每个时间点
    
    end
end

