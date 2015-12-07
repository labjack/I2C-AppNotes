classdef I2C_Utils
	% LabJack I2C Utilities Object
	properties
		ljud % LabJack UD Driver reference
		handle % The handle to the open LabJack device.
		slave_address % 7-bit I2C Slave Address
		sda_num % The SDA pin number
		scl_num % The SCL pin number
		options % The integer used for I2C Options
		speed_adj % The speed adjust

		enable_debug % A variable that can be set to true to print out debugging data
	end

	methods
		function obj=I2C_Utils(ljud, handle)
			obj.ljud = ljud;
			obj.handle = handle;
		end
		function configure(obj)
			shifted_address = bitshift(obj.slave_address, 1);
			sda_num = obj.sda_num;
			scl_num = obj.scl_num;
			options = obj.options.calculate();
			speed_adj = obj.speed_adj;

			ioType = LabJack.LabJackUD.IO.PUT_CONFIG;

			% Configure the I2C slave address
			channel = LabJack.LabJackUD.CHANNEL.I2C_ADDRESS_BYTE;
			obj.ljud.ePut(obj.handle, ioType, channel, shifted_address, 0);

			% Configure the SDA pin number
			channel = LabJack.LabJackUD.CHANNEL.I2C_SDA_PIN_NUM;
			obj.ljud.ePut(obj.handle, ioType, channel, sda_num, 0);

			% Configure the SCL pin number
			channel = LabJack.LabJackUD.CHANNEL.I2C_SCL_PIN_NUM;
			obj.ljud.ePut(obj.handle, ioType, channel, scl_num, 0);

			% Configure the I2C Options
			channel = LabJack.LabJackUD.CHANNEL.I2C_OPTIONS;
			obj.ljud.ePut(obj.handle, ioType, channel, options, 0);

			% Configure the I2C bus speed
			channel = LabJack.LabJackUD.CHANNEL.I2C_SPEED_ADJUST;
			obj.ljud.ePut(obj.handle, ioType, channel, speed_adj, 0);

			% Finished configuring the LabJack's I2C Bus
			if obj.enable_debug
				disp('Configured I2C Bus');
			end
		end

		function read(obj, numBytesToRead)
			disp('Function not tested!');
		end
		function write(obj, userWriteData)
			disp('Function not tested!');
		end
		function [numAcks] = writeAndGetAcks(obj, userWriteData)
			disp('Function not tested!');
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);

			numAcks = 0;
			channel = LabJack.LabJackUD.CHANNEL.I2C_GET_ACKS;
			obj.ljud.AddRequest(obj.handle, ioType, channel, numAcks, 0, 0);

			% Executge the I2C Write Request
			obj.ljud.GoOne(obj.handle);

			[ljerror, numAcks] = obj.ljud.GetResult(obj.handle, ioType, channel, 0)

		end
		function writeAndRead(obj, userWriteData, numBytesToRead)
			disp('Function not tested!');
		end
		function [numAcks,readData]=writeGetAcksAndRead(obj, userWriteData, numBytesToRead)
			% Define variables needed for this operation
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);
			rawReadData = NET.createArray('System.Byte', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			
			% Add an I2C write request
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);

			% Add an I2C Get-Acks request
			numAcks = 0;
			channel = LabJack.LabJackUD.CHANNEL.I2C_GET_ACKS;
			obj.ljud.AddRequest(obj.handle, ioType, channel, numAcks, 0, 0);

			% Add an I2C read request
			channel = LabJack.LabJackUD.CHANNEL.I2C_READ;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numBytesToRead, rawReadData, 0);
			
			% Executge the I2C Write Request
			obj.ljud.GoOne(obj.handle);

			% Get the number of received ack bits.
			[ljerror, repAcks] = obj.ljud.GetResult(obj.handle, ioType, channel, 0);
			numAcks = repAcks;

			% Print out debugging info
			if obj.enable_debug
				numAcks
				readData
				disp('Indexing through data...');
			end

			for n=1:numBytesToRead
				readData(n) = rawReadData(n);
				if obj.enable_debug
					dataByte = dec2hex(readData(n))
				end
			end
		end
	end
end