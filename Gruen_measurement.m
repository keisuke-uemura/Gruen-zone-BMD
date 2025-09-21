function [BMD_out,Area_out,BMC_out,zone_DRRs_out] = Gruen_measurement(AP_Gruen_stem_region,AP_Gruen_femur_region)                
    % flip stem labels
      AP_Gruen_stem_region(AP_Gruen_stem_region>0)=2;   
      AP_Gruen_stem_region(AP_Gruen_stem_region==0)=1;   
      AP_Gruen_stem_region(AP_Gruen_stem_region==2)=0;   
    
      DRR_with_stem= AP_Gruen_femur_region.*AP_Gruen_stem_region;
      DRR_with_stem(DRR_with_stem<0)=0;
      
      flipped_AP_Gruen_stem_region=  flip(permute(AP_Gruen_stem_region,[2 1]),2);
      flipped_DRR_with_stem=  flip(permute(DRR_with_stem,[2 1]),2);
                
        inferior_edge=max(find(min(flipped_AP_Gruen_stem_region)==0));
        superior_edge=min(find(min(flipped_AP_Gruen_stem_region)==0));
        
        region_range=inferior_edge-superior_edge;
       
        %Gruen zone based on GE's defenition
        superior_DRR=flipped_DRR_with_stem(:,superior_edge:superior_edge+round(region_range/3));   
        mid_DRR=flipped_DRR_with_stem(:,superior_edge+round(region_range/3)+1:superior_edge+round(region_range/3*2));
        inf_DRR=flipped_DRR_with_stem(:,superior_edge+round(region_range/3*2)+1:inferior_edge);
        zone4_DRR=flipped_DRR_with_stem(:,inferior_edge+1:inferior_edge+20);
        
%% Delete small islands and only select the largest island 
        
        all_imgs = cell(4,1);
        all_imgs(1,:) = {superior_DRR};
        all_imgs(2,:) = {mid_DRR};
        all_imgs(3,:) = {inf_DRR};
        all_imgs(4,:) = {zone4_DRR};
        
   BMD_results=[];
   Area_results=[];
   BMC_results=[];
   save_zone_DRRs = cell(7,1);
   
   for m=1:4
            target_DRR= all_imgs{m,:};
         
      stats=regionprops(target_DRR~=0, 'Area', 'PixelIdxList','Centroid');
      [~, index] = maxk([stats.Area],2);
      
   if m==4
      order=index(1);
   else    
      
      %get the coordinates of the y-axis
      largestisland_centroid=stats(index(1)).Centroid;
      largestisland_centroid_Y=largestisland_centroid(2);
                            
      %get the coordinates of the y-axis
      secondisland_centroid=stats(index(2)).Centroid;
      secondisland_centroid_Y=secondisland_centroid(2);
      
      if largestisland_centroid_Y>secondisland_centroid_Y
          
          order=[index(1),index(2)];
      else
           order=[index(2),index(1)];
      end
   end
   
      count=1;
      for k=  order % gruen_zone would be analyzed in the orders of [1,7,2,6,3,5,4];
          
       zone_number_find=find(order==k);
          
       zone_DRR_label = zeros(size(target_DRR),'like',target_DRR);
       needed_pixels = false(size(target_DRR));

       needed_pixels(stats(k).PixelIdxList) = true;    
       zone_DRR_label(needed_pixels) = 1; 
       analyze_DRR=zone_DRR_label.*target_DRR;
     
       q = find(analyze_DRR);% calculate number of pixels without zero 
       Area_results=[Area_results,length(q)*0.5*0.5/100];%saved in cm2      
       BMC_results=[BMC_results,sum(analyze_DRR,'all')/1000/8000];
       BMD_results=[BMD_results,sum(analyze_DRR,'all')/1000/8000/(length(q)*0.5*0.5/100)];
           
      % save DRR image   
        save_zone_DRRs((m-1)*2+count,:) = {analyze_DRR};  
        count=count+1;
      end
      
   end
           
    %order_change to zones 1 -> 7
    BMD_out=[BMD_results(:,1),BMD_results(:,3),BMD_results(:,5),BMD_results(:,7),BMD_results(:,6),BMD_results(:,4),BMD_results(:,2)];
    BMC_out=[BMC_results(:,1),BMC_results(:,3),BMC_results(:,5),BMC_results(:,7),BMC_results(:,6),BMC_results(:,4),BMC_results(:,2)];
    Area_out=[Area_results(:,1),Area_results(:,3),Area_results(:,5),Area_results(:,7),Area_results(:,6),Area_results(:,4),Area_results(:,2)];
    zone_DRRs_out=cell(7,1);
    zone_DRRs_out(1,:) = save_zone_DRRs(1,:);
    zone_DRRs_out(2,:) = save_zone_DRRs(3,:);
    zone_DRRs_out(3,:) = save_zone_DRRs(5,:);
    zone_DRRs_out(4,:) = save_zone_DRRs(7,:);
    zone_DRRs_out(5,:) = save_zone_DRRs(6,:);
    zone_DRRs_out(6,:) = save_zone_DRRs(4,:);
    zone_DRRs_out(7,:) = save_zone_DRRs(2,:);