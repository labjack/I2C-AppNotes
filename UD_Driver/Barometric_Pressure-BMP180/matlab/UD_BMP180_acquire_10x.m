function result = UD_BMP180_acquire_10x()
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
		%   3. disable_clock_stretching
		i2cUtils.options = LJM_I2C_Options(false, false, false);
		i2cUtils.speed_adj = 0;

		% Configure the LabJack's I2C Bus
		i2cUtils.configure();

		% Initialize the matlab BMP180 utility
		bmp180Utils = BMP180_Utils(i2cUtils);

		% Verify that the BMP180 is properly connected to the device.
		% [hardwareInstalled] = bmp180Utils.verify_hardware();
		
		% Read the BMP180's calibration data.
		bmpCal = bmp180Utils.read_calibration();
		% bmpCal.printCal();
		
		% Call a function that over-writes the calibration & performs
		% a smoke-test on the calibration functions.
		% bmp180Utils.collect_dummy_data(bmpCal);

		% Collect & calibrate data with oss = 0
		oss = 3;

		% Configure auto-printing of results
		bmpCal.print_results = false;
		bmp180Utils.print_raw_results = false;
		bmp180Utils.print_calibrated_results = true;

		num_readings = 10;
		delay = 1;

		for m = 1:num_readings
			disp(' ');
			disp(strcat('Collection Iteration:', num2str(m)));
			% Read and calculate the true temperature and humidity
			[T, P] = bmp180Utils.collect_temp_and_pressure(bmpCal, oss);
			pause(delay)
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

