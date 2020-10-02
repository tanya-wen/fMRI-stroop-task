%% Template Matlab script to create an BIDS compatible _bold.json file
% https://github.com/bids-standard/bids-starter-kit/blob/master/matlabCode/func/createBIDS_anat_json_full.m
% https://github.com/gllmflndn/JSONio

%%
function write_anat_josn(output_dir,sub_label)

% output_dir = ['..' filesep '..'];
% sub_label = '01';
% task_label = 'FullExample';
% run_label = '01';

% 
anat_json_name = fullfile(output_dir,...
    ['sub-' sprintf('%02d',str2double(sub_label)) '_T1w.json']);



%% template

    anat_json.Modality = 'MR';
    anat_json.MagneticFieldStrength = 3;
    anat_json.ImagingFrequency = 127.7659;
    anat_json.Manufacturer = 'GE MEDICAL SYSTEMS';
    anat_json.ManufacturersModelName = 'DISCOVERY MR750';
    anat_json.InstitutionName = 'Duke Univ Hosp MR5';
    anat_json.InstitutionalDepartmentName = 'Center for Cognitive Neuroscience';
    anat_json.InstitutionAddress = 'LSRC';
    anat_json.DeviceSerialNumber = '0000000919684MR5';
    anat_json.StationName = 'bia5';
    anat_json.BodyPartExamined = 'BRAIN';
    anat_json.PatientPosition = 'HFS';
    anat_json.ProcedureStepDescription = 'decodCC.01';
    anat_json.SoftwareVersions = '24_LX_MR Software release:DV24.0_R01_1344.a';
    anat_json.MRAcquisitionType = '3D';
    anat_json.SeriesDescription = 'Ax FSPGR BRAVO';
    anat_json.ProtocolName = 'T1w_FSPGR';
    anat_json.ScanningSequence = 'GR';
    anat_json.SequenceVariant = 'SS_SK';
    anat_json.ScanOptions = 'FAST_GEMS_EDR_GEMS_ACC_GEMS';
    anat_json.ImageType = [
        'ORIGINAL',...
        'PRIMARY',...
        'OTHER'
    ];
    anat_json.AcquisitionNumber = 1;
    anat_json.SliceThickness = 1;
    anat_json.EchoTime = 0.002928;
    anat_json.RepetitionTime = 7.652;
    anat_json.InversionTime = 0.450;
    anat_json.FlipAngle = 12;
    anat_json.PhaseResolution = 1;
    anat_json.ReceiveCoilName = 'Head_32';
    anat_json.PercentPhaseFOV = 100;
    anat_json.AcquisitionMatrixPE = 256;
    anat_json.PixelBandwidth = 278.9840;
    anat_json.InPlanePhaseEncodingDirectionDICOM = 'ROW';


%% Write
% this just makes the json file look prettier when opened in a text editor
json_options.indent = '    ';

jsonSaveDir = fileparts(anat_json_name);
if ~isdir(jsonSaveDir)
    fprintf('Warning: directory to save json file does not exist, first create: %s \n',jsonSaveDir)
end

try
    jsonwrite(anat_json_name,anat_json,json_options)
catch
    warning( '%s\n%s\n%s\n%s',...
        'Writing the JSON file seems to have failed.', ...
        'Make sure that the following library is in the matlab/octave path:', ...
        'https://github.com/gllmflndn/JSONio')
end

end