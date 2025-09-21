function [stem_output_volume,femur_needed_volume,landmark_mm_tbl_moved] = Gruen_transformation(landmark_mm_tbl,output_ElementSpacing,output_DimSize,CT_img_calibrated,CT_hdr,stem_label_img)                
     
        origin = landmark_mm_tbl{'F-2',:};

        Z_axis = landmark_mm_tbl{'two_cm_distal_center',:}-landmark_mm_tbl{'five_cm_distal_center',:}; Z_axis = Z_axis./norm(Z_axis);       
        Y_axis = cross(landmark_mm_tbl{'condyle-2',:}-landmark_mm_tbl{'condyle-1',:}, Z_axis); Y_axis = Y_axis./norm(Y_axis);
        X_axis = cross(Y_axis, Z_axis);
   
        transMatrix_3x3= [X_axis(:) Y_axis(:) Z_axis(:)];      
        transMatrix = [transMatrix_3x3 origin(:); 0 0 0 1];            
       
       % prepare input and output grid
        [X, Y, Z] = meshgrid((0:size(CT_img_calibrated,2)-1)*CT_hdr.ElementSpacing(2), (0:size(CT_img_calibrated,1)-1)*CT_hdr.ElementSpacing(1), (0:size(CT_img_calibrated,3)-1)*CT_hdr.ElementSpacing(3));
        h_mm = (output_DimSize-1).*output_ElementSpacing/2;
        [qX, qY, qZ] = meshgrid(-h_mm(2):output_ElementSpacing(2):h_mm(2), -h_mm(1):output_ElementSpacing(1):h_mm(1), -h_mm(3):output_ElementSpacing(3):h_mm(3));
         qXYZ =transMatrix * [qX(:)'; qY(:)'; qZ(:)'; ones(1,numel(qX))];
        
       % interpolate and move the landmarks
        stem_output_volume = permute( interp3(X, Y, Z, permute(single(stem_label_img),[2 1 3]), reshape(qXYZ(1,:),size(qX)), reshape(qXYZ(2,:),size(qY)), reshape(qXYZ(3,:),size(qZ)), "cubic", 0), [2 1 3]);     
        stem_output_volume=flip(flip(stem_output_volume,1),2); 
                    
        CT_output_volume = permute( interp3(X, Y, Z, permute(single(CT_img_calibrated),[2 1 3]), reshape(qXYZ(1,:),size(qX)), reshape(qXYZ(2,:),size(qY)), reshape(qXYZ(3,:),size(qZ)), "cubic", 0), [2 1 3]);     
        femur_needed_volume=flip(flip(CT_output_volume,1),2);                    
      
        landmark_mm_tbl_moved= ([eye(3)* [-1 0 0;0 -1 0;0 0 1] h_mm(:)] * (transMatrix \ [landmark_mm_tbl{:,:}'; ones(1,height(landmark_mm_tbl))]) )';
