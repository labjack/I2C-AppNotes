classdef BMP180_Utils
	% LabJack I2C Utilities Object
	properties
		i2cUtils % A reference to the I2C Utility.

		calibration % A reference to the BMP180's calibration.
	end

	methods
		function obj=BMP180_Utils(i2cUtils)
			% Save the reference to the initialized I2C Utility.
			obj.i2cUtils = i2cUtils;
		end
		function [hardwareInstalled]=verify_hardware(obj)
			% Write one byte of data (setting the read-pointer to be the Chip-id 
			% register).  Read the data stored in the Chip-id register & retrieve 
			% the number of received acks.  According to page 18 of the datasheet
			% this value should always be 0x55 and its purpose is to check whether
			% communication is functioning.

			writeData = [hex2dec('D0')];
			[numAcks, readData] = obj.i2cUtils.writeGetAcksAndRead(writeData, 1);

			% Print out the Chip-id register result.
			chipID = readData(1);

			if (numAcks > 0) & (chipID == hex2dec('55'))
				disp('BMP180 is properly connected for I2C communication.');
				disp(strcat('Num acks received:', num2str(numAcks)));
				disp(strcat('Chip-id Result: 0x', num2str(dec2hex(chipID))));
				hardwareInstalled = true;
			else
				disp('BMP180 is not properly connected.');
				disp(strcat('Num acks received:', num2str(numAcks)));
				disp(strcat('Chip-id Result: 0x', num2str(dec2hex(chipID)), ' it should be 0x55 according to page 18 of the datasheet.'));
				hardwareInstalled = false;
			end
		end
		% Following page 15 of the devices datasheet...
		function cal=read_calibration(obj)
			% Write one byte of data to set the pointer to address 0xAA.  Then
			% read back 0xBF-0xAA number of registers that contain all of the 
			% BMP180's calibration information.

			writeData = [hex2dec('AA')];
			numBytesToRead = hex2dec('BF') - hex2dec('AA') + 1; 
			[numAcks, readData] = obj.i2cUtils.writeGetAcksAndRead(writeData, numBytesToRead);

			bmpCal = BMP180_Cal(readData);
			obj.calibration = bmpCal;
			cal = bmpCal;
			% obj.calibration.printCalData();
			% obj.calibration.printCal();
		end

		function UT = read_raw_temperature(obj, cal)
			% Write 0x2E into reg 0xF4
			writeData = [hex2dec('F4'), hex2dec('2E')];
			[numWriteAcks] = obj.i2cUtils.writeAndGetAcks(writeData);

			% Wait 4.5ms
			pause(0.0045);

			% Read reg 0xF6 (MSB), 0xF7 (LSB)
			writeData = [hex2dec('F6')];
			numBytesToRead = 2; 
			[numReadAcks, readData] = obj.i2cUtils.writeGetAcksAndRead(writeData, numBytesToRead);

			MSB = uint32(readData(1));
			LSB = uint32(readData(2));

			% disp(strcat('Num Write acks received:', num2str(numWriteAcks)));
			% disp(strcat('Num Read acks received:', num2str(numReadAcks)));
			% disp(strcat('MSB:', num2str(readData(1))));
			% disp(strcat('LSB:', num2str(readData(2))));

			UT = int32(bitor(bitshift(MSB,8), LSB));
			disp(strcat('UT:', num2str(UT)));
		end

		function UP = read_raw_pressure(obj, cal, oss)
			msTimeToWait = 0;
			if oss == 0
				msTimeToWait = 4.5;
			elseif oss == 1
				msTimeToWait = 7.5;
			elseif oss == 2
				msTimeToWait = 13.5;
			elseif oss == 3
				msTimeToWait = 25.5;
			else
				oss = 0;
				msTimeToWait = 4.5;
			end
			timeToWait = (msTimeToWait/1000);

			% Write 0x34+(oss<<6) into reg 0xF4
			writeVal = hex2dec('34') + bitshift(oss, 6);
			writeData = [hex2dec('F4'), writeVal];
			[numWriteAcks] = obj.i2cUtils.writeAndGetAcks(writeData);

			% Wait 4.5ms
			pause(timeToWait);

			% Read reg 0xF6 (MSB), 0xF7 (LSB), 0xF8 (XLSB)
			writeData = [hex2dec('F6')];
			numBytesToRead = 3; 
			[numReadAcks, readData] = obj.i2cUtils.writeGetAcksAndRead(writeData, numBytesToRead);

			MSB = uint32(readData(1));
			LSB = uint32(readData(2));
			XLSB = uint32(readData(3));

			UP = 0;
			UP = bitor(UP, bitshift(MSB, 16));
			UP = bitor(UP, bitshift(LSB, 8));
			UP = bitor(UP, bitshift(XLSB, 0));
			UP = bitshift(UP, -(8-oss));

			% disp(strcat('Num Write acks received:', num2str(numWriteAcks)));
			% disp(strcat('Num Read acks received:', num2str(numReadAcks)));
			% disp(strcat('MSB:', num2str(readData(1))));
			% disp(strcat('LSB:', num2str(readData(2))));
			% disp(strcat('XLSB:', num2str(readData(3))));
			disp(strcat('UP:', num2str(UP)));
		end

		function collect_dummy_data(obj, cal)
			% Perform temperature and pressure calibration with data defined
			% in the datasheet to check calculations.
			oss = 0;

			% Define test values
			UT = 27898;
			UP = 23843;

			% disp('Loading default cal');
			cal.AC1 = int32(int16(408));
			cal.AC2 = int32(int16(-72));
			cal.AC3 = int32(int16(-14383));
			cal.AC4 = uint32(uint16(32741));
			cal.AC5 = uint32(uint16(32757));
			cal.AC6 = uint32(uint16(23153));
			cal.B1 = int32(int16(6190));
			cal.B2 = int32(int16(4));
			cal.MB = int32(int16(-32768));
			cal.MC = int32(int16(-8711));
			cal.MD = int32(int16(2868));

			% Calculate the true temperature
			T = cal.calculateTemperature(UT, UP);
			if T == 15
				disp('Temperature calculations pass basic smoke test');
			else
				disp('T should equal 15');
			end
			% Calculate the true pressure
			P = cal.calculatePressure(UT, UP, oss);
			if P == 69.9650
				disp('Pressure calculations pass basic smoke test');
			else
				disp('P should equal 69.9650');
			end

		end
		function [T, P] = collect_temp_and_pressure(obj, cal, oss)
			% Read the raw temperature
			UT = obj.read_raw_temperature(cal);

			% Read the raw pressure
			UP = obj.read_raw_pressure(cal, oss);

			% Calculate the true temperature
			T = cal.calculateTemperature(UT, UP);
			
			% Calculate the true pressure
			P = cal.calculatePressure(UT, UP, oss);
		end
	end
end