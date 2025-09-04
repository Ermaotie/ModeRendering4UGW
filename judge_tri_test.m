    if(~exist('n','var'))
        n = 5;
    end
    base_point = base_points(2,:);
I =rough_judge(base_point,mesh{4},n);

    for i  =  1:length(I)
        pa = mesh{1}(I(i),:);
        pb = mesh{2}(I(i),:);
        pc = mesh{3}(I(i),:);
        
        vab = pb - pa;
        vbc = pc - pb;
        vca = pa - pc;
    
        vap = base_point - pa;
        vbp = base_point - pb;
        vcp = base_point - pc;

        area_cross = cross(vab,-vca);
        dot1 = dot(area_cross,cross(vab,vap));
        dot2 = dot(area_cross,cross(vbc,vbp));
        dot3 = dot(area_cross,cross(vca,vcp));
        
        sgn1 = sign(dot(area_cross,cross(vab,vap)));
        sgn2 = sign(dot(area_cross,cross(vbc,vbp)));
        sgn3 = sign(dot(area_cross,cross(vca,vcp))); 
        if (sign(dot(area_cross,cross(vab,vap)))==sign(dot(area_cross,cross(vbc,vbp))) && sign(dot(area_cross,cross(vbc,vbp)))==sign(dot(area_cross,cross(vca,vcp))))
        % if sum(area_cross.*cross(vab,vap)) * sum(area_cross.*cross(vbc,vbp)) * sum(area_cross.*cross(vca,vcp))>=0
            mesh_index = I(i);
            break
        end
    end
    if mesh_index>0
        return
    else
        mesh_index = nan;
    end