function [Na] = assign_value(N_all,value)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
syms x y;
    for i = 1:3
        for ii = 1:9
            Na(i,ii) = double(subs(N_all(i,ii),[x,y],[value(1),value(2)]);)
        end
    end
end

