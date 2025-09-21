function [AP_Gruen_stem_region,AP_Gruen_femur_region] = Gruen_DRR_generation(stem_output_volume,femur_needed_volume,landmark_mm_tbl_moved)                
     
          AP_Gruen_stem_region = sum(permute(stem_output_volume,[3 1 2]),3);  
          AP_Gruen_stem_region = single(AP_Gruen_stem_region >= 0.5);     
          AP_Gruen_femur_region = sum(permute(femur_needed_volume,[3 1 2]),3);  %without stem
 
       %for cropping
          four_projected_landmarks_Y= landmark_mm_tbl_moved([12:15],3)*2;  %stem four y landmarks
          four_projected_landmarks_X= landmark_mm_tbl_moved([12:15],1)*2;  %stem four y landmarks
          
           XX = [ones(length(four_projected_landmarks_X),1) four_projected_landmarks_X];
            b = XX\(four_projected_landmarks_Y); % correlation equation
       
       %neck and distal cut
       for m=1:800    
          for s=1:100 
            % create vectors 
            A=[ b(1) 0 1]; 
            B=[100*b(2)+b(1) 100 1];     
            P=[m,s,1];
            AB=B-A; AP=P-A; 
            Cross_product=cross(AB,AP);
            Cross_product=Cross_product(:,3);
            % crop image using cross product
               if    Cross_product<0
                  AP_Gruen_femur_region(m,s)=0;
                  AP_Gruen_stem_region(m,s)=0;
               end
           end
       end  