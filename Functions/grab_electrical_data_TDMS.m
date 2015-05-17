% grab_electrical_data_TDMS.m

function electrical = grab_electrical_data_TDMS(tempPath)
% directory = 'C:\Users\dhstuart\Dropbox\CLTC\LED life testing\photometric data';
% filename = [directory '\LED Lifetesting Electrical Data - Olga 1M 20141218.xlsx'];
% sheets = {
%     '1000 Hours'
%     '2000 Hours'
%     '3000 Hours'
%     };

% filePath = 'C:\Users\dhstuart\Dropbox\CLTC\PhotometricElectricTestingAutomation\Output\';
% fileList = 'Electrical - ledLifeTesting - 4000 - 5 - 21.tdms';

% filePath = 'C:\Users\dhstuart\Documents\MR16 teardown\Test Data\';
% fileList = 'Acculamp S-Series_Hatch RA12-60M-LED_Lutron DVELV-300P_50_1.tdms';

% temp = TDMS_readTDMSFile([filePath fileList]);
temp = TDMS_readTDMSFile(tempPath);
temp2 = TDMS_dataToGroupChanStruct_v4(temp);

electrical.voltage = temp2.Electrical_Data.Props.Volts_rms;
electrical.current = temp2.Electrical_Data.Props.Current_rms;
electrical.power = temp2.Electrical_Data.Props.Power_Real;
electrical.powerFactor = temp2.Electrical_Data.Props.Power_Factor;
electrical.VTHD = temp2.Electrical_Data.Props.Volts_THD;
electrical.ITHD = temp2.Electrical_Data.Props.Current_THD;
% electrical.date_time = temp2.Electrical_Data.Props.date_time;
end