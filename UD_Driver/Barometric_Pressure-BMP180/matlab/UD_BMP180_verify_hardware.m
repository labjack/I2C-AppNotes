function result = UD_BMP180_verify_hardware()
	% This function is designed to verify that the the BMP180 acceelrometer is
	% properly connected to the LabJack device.  Essentially, it reads the 
	% Chip-id register from the I2C sensor and makes sure that it received the 
	% proper number of ack bits.

	try
		clc % Clear the MATLAB command window
		clear % Clear the MATLAB variables

		% Make the UD .NET assembly visible in MATLAB
		ljasm = NET.addAssembly('LJUDDotNet');
		ljudObj = LabJack.LabJackUD.LJUD;

		% Open the first found LabJack U3.
		% disp('Opening U3');
		% [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U3,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);

		% Open the first found LabJack U6.
		disp('Opening U6');
		[ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);

		% Open the first found LabJack UE9.
		% disp('Opening UE9');
		% [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.UE9,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);		
		
		% Initialize the I2C Utility.
		i2cUtils = UD_I2C_Utils(ljudObj, ljhandle);
		i2cUtils.enable_debug = false;

		% Define variables for various I2C attributes.
		i2cUtils.slave_address = hex2dec('77');
		i2cUtils.sda_num = 6;
		i2cUtils.scl_num = 7;
		% Define a variable for the I2C Options:
		%   1. reset_at_start
		%   2. no_stop_when_restarting
		%   3. enable_clock_stretching
		i2cUtils.options = UD_I2C_Options(false, false, false);
		i2cUtils.speed_adj = 0;

		% Configure the LabJack's I2C Bus
		i2cUtils.configure();

		% Write one byte of data (setting the read-pointer to be the Chip-id 
		% register).  Read the data stored in the Chip-id register & retrieve 
		% the number of received acks.  According to page 18 of the datasheet
		% this value should always be 0x55 and its purpose is to check whether
		% communication is functioning.

		writeData = [hex2dec('D0')];
		[numAcks, readData] = i2cUtils.writeGetAcksAndRead(writeData, 1);

		% Print out the Chip-id register result.
		chipID = readData(1);

		if (numAcks > 0) & (chipID == hex2dec('55'))
			disp('BMP180 is properly connected for I2C communication.');
			disp(strcat('Num acks received:', num2str(numAcks)));
			disp(strcat('Chip-id Result: 0x', num2str(dec2hex(chipID))));
			result = true;
		else
			disp('BMP180 is not properly connected.');
			disp(strcat('Num acks received:', num2str(numAcks)));
			disp(strcat('Chip-id Result: 0x', num2str(dec2hex(chipID)), ' it should be 0x55 according to page 18 of the datasheet.'));
			result = false;
		end

		% Close the device
		ljudObj.Close();

	catch e
	    showErrorMessage(e)
	end
end

function showErrorMessage(e)
	% showErrorMessage Displays the UD or .NET error from a MATLAB exception.
	if(isa(e, 'NET.NetException'))
	    eNet = e.ExceptionObject;
	    if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
	        disp(['UD Error: ' char(eNet.ToString())])
	    else
	        disp(['.NET Error: ' char(eNet.ToString())])
	    end
	end
	disp(getReport(e))
end

