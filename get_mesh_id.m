function [mesh_index] = get_mesh_id(point,mesh, n)
%GET_MESH_ID 此处显示有关此函数的摘要
%   返回所求点所在面元索引
    if(~exist('n','var'))
        n = 5;
    end
    % if(~exist('point','var'))
    %     point = base_point;
    % end
    % if(~exist('mesh','var'))
    %     mesh = mesh;
    % end
I =rough_judge(point,mesh{4},n);

    for i  =  1:length(I)
        pa = mesh{1}(I(i),:);
        pb = mesh{2}(I(i),:);
        pc = mesh{3}(I(i),:);
        
        vab = pb - pa;
        vbc = pc - pb;
        vca = pa - pc;
    
        vap = point - pa;
        vbp = point - pb;
        vcp = point - pc;
    
        area_cross = cross(vab,pc - pa);

        
    
        if (sign(dot(area_cross,cross(vab,vap)))==sign(dot(area_cross,cross(vbc,vbp))) && sign(dot(area_cross,cross(vbc,vbp)))==sign(dot(area_cross,cross(vca,vcp))))
            mesh_index = I(i);
            break
        % else 
        %     if norm(cross(vab,vap))==0 || norm(cross(vbc,vbp))==0 || norm(cross(vca,vcp))==0
        %         mesh_index = I(i);
        %     break
        %     end
        end
        mesh_index = I(1);
    end
    
end

