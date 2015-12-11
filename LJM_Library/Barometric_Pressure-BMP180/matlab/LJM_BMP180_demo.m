function result = LJM_BMP180_demo()
	% This function is designed to verify that the the BMP180 acceelrometer is
	% properly connected to the LabJack device.  Essentially, it reads the 
	% Chip-id register from the I2C sensor and makes sure that it received the 
	% proper number of ack bits.

	try
		clc % Clear the MATLAB command window
		clear % Clear the MATLAB variables

		% Make the LJM .NET assembly visible in MATLAB
		ljmAsm = NET.addAssembly('LabJack.LJM');
		ljmType = ljmAsm.AssemblyHandle.GetType('LabJack.LJM');
		ljmConstantsType = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');

		% Create an object to nested class LabJack.LJM.CONSTANTS
		LJM_CONSTANTS = System.Activator.CreateInstance(ljmConstantsType);
		LJM = System.Activator.CreateInstance(ljmType);

		%Open first found LabJack
		ljhandle=0;
		[ljmError, ljhandle] = LJM.OpenS('LJM_dtT7', 'LJM_ctUSB', 'ANY', ljhandle);
		showDeviceInfo(ljhandle);

		% Initialize the I2C Utility.
		i2cUtils = LJM_I2C_Utils(LJM, LJM_CONSTANTS, ljhandle);
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
		i2cUtils.speed_adj = 65030;

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

		% Enable auto-printing of results
		bmpCal.print_results = true;

		% Read and calculate the true temperature and humidity
		[T, P] = bmp180Utils.collect_temp_and_pressure(bmpCal, oss);

		% Close the device
		LJM.Close(ljhandle);

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

