function result = hello_world()
	%This function executes vaious I2C commands to demonstrate the basic usage 
	%of the ADXL345 accelerometer and a LabJack in matlab.

	clc %Clear the MATLAB command window
	clear %Clear the MATLAB variables

	%Make the UD .NET assembly visible in MATLAB
	ljasm = NET.addAssembly('LJUDDotNet');
	ljudObj = LabJack.LabJackUD.LJUD;

	disp('Opening U6');
	%Open the first found LabJack U6.
	[ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);
	
	%Print the ljhandle and ljerror variables.
	ljhandle
	ljerror

	% Define d variable for the I2C Utility
	i2cUtils = I2C_Utils(ljudObj, ljhandle);
	
	

	% Define variables for various I2C attributes.
	i2cUtils.slave_address = hex2dec('53');
	i2cUtils.sda_num = 6;
	i2cUtils.scl_num = 7;
	% Define a variable for the I2C Options (clock stretching etc.)
	i2cUtils.options = I2C_Options(true, false, false);
	i2cUtils.speed_adj = 0;

	% Configure the LabJack's I2C Bus
	i2cUtils.configure();

	% Write one byte of data (setting the read-pointer to be the DEVID register).
	% Read the data stored in the DEVID register & retrieve the number of
	% received acks.
	writeData = [0];
	[numAcks, readData] = i2cUtils.writeGetAcksAndRead(writeData, 1)

	% Print out the DEVID register result.
	disp('DEVID Result:');
	for n=1:length(readData)
		dec2hex(readData(n))
	end

	%Close the device
	ljudObj.Close();

