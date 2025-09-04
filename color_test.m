% 创建一个 patch 图形
x = [0 1 1 0];
y = [0 0 1 1];
c = [1 2 3 4];
patch(x, y, c);

% 设置颜色映射
colormap jet;

% 添加颜色条
colorbar;