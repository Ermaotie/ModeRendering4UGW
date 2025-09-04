function [I] = rough_judge(point,mesh_centers,n)
%ROUGH_JUDGE 此处显示有关此函数的摘要
%   此处显示详细说明
% I 返回最近的5个点的单元的索引
% point 所求点坐标1*3
% mesh_ceters 网格单元中点
    if(~exist('n','var'))
        n = 5;
    end
    
    
    distances_pow = sum((mesh_centers-point).*(mesh_centers-point),2);
    [~,I] = sort(distances_pow);
    if length(I)>n
        I = I(1:n);
    end

end

