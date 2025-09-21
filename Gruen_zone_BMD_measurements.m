% This skript shows the pipeline to calculate the BMD, BMC, and Area of the 7 Gruen zones for a left hip.

% Necessary input
  % refer to an example (sample_setup.json)
% Necessary functions
  % mhdread.m
  % LoadSlicerFiducialFile.m
  % Gruen_transformation.m
  % Gruen_measurement.m

% Output: BMD_results,Area_results,BMC_results,zone_DRRs_out

%% define output image size and pixel size
    output_ElementSpacing = [0.5 0.5 0.5];
    output_DimSize = [200 200 800];

%% inport data
    input_json_filename = '.\sample\sample_setup.json'; %importing sample data
    
%% import images and information
      [preop_CT, CT_hdr] =  mhdread(preoperativeCT); %preoperative CT
      CT_img_calibrated = max(preop_CT*slope + intercept, 0);% calibrate using phantom information
    
      [stem_label_img,stem_label_hdr] = mhdread(cad_model);%CAD model (registered to preoperative CT)  
      [femur_label,femur_label_hdr] = mhdread(preop_femur_label);%preoperative CT femur label;

      [landmark_pos, landmark_ID] = LoadSlicerMarkupFile('sample_landmarks.fcsv');%landmarks shown in figure
      landmark_mm_tbl = array2table(landmark_pos*diag([-1 -1 1]), 'RowNames', landmark_ID);  % negate X and Y to adjust from Slicer coordinate
        
%% calibrate CT and select regions
      CT_img_calibrated = max(preop_CT*slope + intercept, 0);% calibrate using phantom information
      CT_img_calibrated(femur_label==0) = 0; %only rotate femur region
     
%% Transform images      
      [stem_output_volume,femur_needed_volume,landmark_mm_tbl_moved] = Gruen_transformation(landmark_mm_tbl,output_ElementSpacing,output_DimSize,CT_img_calibrated,CT_hdr,stem_label_img);                
       
%% DRR generation            
     %Generate DRR for zones 1-7   
      [AP_Gruen_stem_region,AP_Gruen_femur_region] = Gruen_DRR_generation(stem_output_volume,femur_needed_volume,landmark_mm_tbl_moved);               
          
%% BMC, BMD, Area measurements
     %calculate BMC, BMD, Area of zones 1-7   
      [BMD_results,Area_results,BMC_results,zone_DRRs_out] = Gruen_measurement(AP_Gruen_stem_region,AP_Gruen_femur_region);
  