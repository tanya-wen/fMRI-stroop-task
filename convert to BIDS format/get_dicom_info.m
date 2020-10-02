%% Func
% get dicom
dcm_file = 'C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/decodCC.01/fMRI/DICOM/20180209_22909/20180209_22909_004_01/bia5_20180209_22909_004_01_00001.dcm';
X = dicominfo(dcm_file);

% nifti info
nifti_file = 'C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/decodCC.01/fMRI/Func/20180209_22909/bia5_22909_004_01.nii.gz';
V = niftiread(nifti_file);
N = niftiinfo(nifti_file);

n = size(V,3);
slice_order = [1:2:n 2:2:n-1];
slice_order*(2/n)


%% Anat
% get dicom
dcm_file = 'C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/decodCC.01/fMRI/DICOM/20180209_22909/20180209_22909_008_01/bia5_20180209_22909_008_01_00001.dcm';
X = dicominfo(dcm_file);

% nifti info
nifti_file = 'C:/Users/Tanya Wen/Box/Extra_Space_for_Tanya/decodCC.01/fMRI/Anat/20180209_22909/bia5_22909_008.nii.gz';
N = niftiinfo(nifti_file);