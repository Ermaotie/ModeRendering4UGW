# 超声导波模态渲染可视化系统

## 项目简介
本项目是一个用于超声导波（Ultrasonic Guided Waves）模态分析和三维动态可视化的MATLAB工具集。该系统可以读取有限元网格数据，计算导波传播特性，并生成高质量的三维动画展示导波在结构中的传播行为。
## 内容展示



![Cg3200.9562-m6-f300kHz-3d](select_img/Cg3200.9562-m6-f300kHz-3d.gif)






## 主要功能
- 读取和处理有限元网格数据
- 计算超声导波的模态位移场
- 生成三维动态可视化动画
- 绘制群速度频散曲线
- 支持多模态批量处理

## 文件结构与功能说明

### 主程序文件

#### 1. `Cg_and_gif_3d_model_gif.m`
**功能**：主程序，生成指定模态的3D动画
- 读取网格数据和模态信息
- 计算节点位移矩阵
- 创建侧面网格
- 生成3D动画GIF文件
- 绘制群速度曲线

#### 2. `Cg_and_gif_3d_model_gif_all.m`
**功能**：批量处理版本，可处理所有模态
- 自动遍历所有模态
- 批量生成动画和群速度图

#### 3. `show_body_anime_3d.m`
**功能**：展示3D实体动画
- 显示带颜色映射的位移场
- 使用jet色图显示位移幅值

#### 4. `show_section_anime_2d.m` / `show_section_anime_2d_ljf_lunwen.m`
**功能**：2D截面动画展示
- 显示横截面的位移动画
- 支持不同视角的2D展示

### 核心功能函数

#### 网格处理函数

##### `get_contour_mesh.m`
```matlab
function [contour_nodes_xyz, contour_nodes_list] = get_contour_mesh(ele_list, mesh, nodes_xyz)
```
**功能**：获取网格轮廓
- 输入：单元列表、网格结构、节点坐标
- 输出：轮廓节点坐标、轮廓节点列表
- 用途：提取网格边界，用于创建侧面

##### `generate_trans_sec_mesh.m`
```matlab
function [trans_ele, trans_nodes_xyz] = generate_trans_sec_mesh(line_mesh, z_length, trans_num)
```
**功能**：生成传播方向的截面网格
- 输入：线网格、z方向长度、传播方向网格数
- 输出：传播单元列表、传播节点坐标
- 用途：沿传播方向拉伸网格

##### `get_line_mesh.m`
```matlab
function [line_mesh, line_mesh_index] = get_line_mesh(base_points, mesh, n)
```
**功能**：获取线网格
- 输入：基点、网格结构、点数
- 输出：线网格坐标、对应网格索引

##### `get_mesh_id.m` / `get_mesh_id_by_x.m`
```matlab
function [mesh_index] = get_mesh_id(point, mesh, n)
function [index] = get_meshes_id_by_x(x, mesh)
```
**功能**：查找点所在的网格单元
- 用途：定位特定坐标点在哪个网格单元内

#### 坐标变换函数

##### `rotate_nodes.m`
```matlab
function [new_nodes_xyz] = rotate_nodes(nodes_xyz, theta_xyz)
```
**功能**：节点坐标旋转
- 输入：原始节点坐标、旋转角度(绕x,y,z轴)
- 输出：旋转后的节点坐标
- 用途：调整视角和坐标系

##### `shift_nodes.m`
```matlab
function [new_nodes_xyz] = shift_nodes(nodes_xyz, shift_vec)
```
**功能**：节点坐标平移
- 输入：原始节点坐标、平移向量
- 输出：平移后的节点坐标
- 用途：调整模型位置

#### 辅助函数

##### `get_bound_points.m`
```matlab
function [intersections, index] = get_bound_points(x, mesh)
```
**功能**：获取边界点
- 输入：x坐标、网格结构
- 输出：交点坐标、对应单元索引
- 用途：找到特定x位置的上下边界点

##### `rough_judge.m`
```matlab
function [I] = rough_judge(point, mesh_centers, n)
```
**功能**：粗略判断最近网格
- 输入：查询点、网格中心、返回数量
- 输出：最近的n个网格索引
- 用途：加速网格搜索

##### `get_num_ele_on_node.m`
```matlab
function [num] = get_num_ele_on_node(node_id, ele_list)
```
**功能**：获取节点相关单元
- 输入：节点ID、单元列表
- 输出：包含该节点的单元列表

### 测试和显示文件

- `gpt_test.m` - 简单的3D patch动画测试
- `show_mesh.m` - 显示网格结构
- `show_sec_orgin.m` - 显示原始截面
- `color_test.m` - 颜色映射测试
- `test_contour.m` - 轮廓提取测试
- `judge_tri_test.m` - 三角形判定测试

## 使用流程

### 1. 数据准备
- 准备有限元网格数据文件（.mat格式）
- 确保包含以下变量：
  - `mesh_all`: 网格信息
  - `Us_new`: 位移模态数据
  - `Cg`: 群速度数据
  - `new_wave`: 波数数据
  - `N_all`: 形函数数据

### 2. 参数设置
```matlab
% 选择模态和频率
m = 14;        % 模态序号
f = 300;       % 频率 (kHz)

% 动画参数
step = 50;     % 时间步数
rp_time = 1;   % 重复周期数
factor = 0.003; % 位移放大系数

% 网格参数
trans_num = 100; % 传播方向网格数
N = 1;          % 波长周期数
```

### 3. 运行主程序
```matlab
% 单个模态处理
run('Cg_and_gif_3d_model_gif.m')

% 批量处理
run('Cg_and_gif_3d_model_gif_all.m')
```

### 4. 输出结果
- 生成的动画保存在 `image_*` 文件夹
- 群速度曲线保存在 `image_*_Cg` 文件夹
- 文件命名格式：`m[模态号]-Cg[群速度]-f[频率]kHz-3d.gif`

## 可视化效果说明

### 动画类型
1. **线框模式**：显示网格边界，适合查看变形
2. **填充模式**：显示位移场颜色映射
3. **混合模式**：同时显示线框和颜色

### 颜色映射
- 使用jet色图
- 颜色表示位移幅值大小
- 红色：最大位移
- 蓝色：最小位移

### 视角控制
- 支持3D旋转视角
- 可调整坐标轴范围
- 支持模型中心对齐

## 注意事项

1. **内存需求**：处理大型网格时需要充足内存
2. **计算时间**：复杂模态可能需要较长计算时间
3. **文件路径**：确保输出文件夹存在
4. **MATLAB版本**：建议使用MATLAB R2019b或更高版本

## 依赖项

- MATLAB基础工具箱
- Symbolic Math Toolbox（符号计算）
- Image Processing Toolbox（图像处理，用于GIF生成）

## 常见问题

### Q: 动画播放速度太快/太慢？
A: 调整`step`参数控制时间步数，或修改`pause`时间

### Q: 位移看不清楚？
A: 调整`factor`参数放大位移显示

### Q: 内存不足？
A: 减少`trans_num`网格密度或分批处理模态

## 作者与维护

## 版本历史
- v1.0 - 初始版本，基础功能实现

## 许可证
