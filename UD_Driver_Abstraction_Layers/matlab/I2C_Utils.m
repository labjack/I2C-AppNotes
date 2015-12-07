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
			% Shift the 7-bit slave address to the left one bit to make an 8-bit
			% address where the last bit can be toggled to indicate read vs
			% write I2C commands.
			shifted_address = bitshift(obj.slave_address, 1);

			% Retrieve various I2C configuration parameters.
			sda_num = obj.sda_num;
			scl_num = obj.scl_num;
			options = obj.options.calculate();
			speed_adj = obj.speed_adj;

			% All of the function calls are using this ioType.
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

		function [readData]=read(obj, numBytesToRead)
			% Define variables needed for this operation
			rawReadData = NET.createArray('System.Byte', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);
			
			% Save the ioType being used in a shorter variable name.
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;

			% Add an I2C read request
			channel = LabJack.LabJackUD.CHANNEL.I2C_READ;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numBytesToRead, rawReadData, 0);
			
			% Execute the I2C Read Request
			obj.ljud.GoOne(obj.handle);

			% Print out debugging info
			if obj.enable_debug
				readData
				disp('Indexing through data...');
			end

			% Transfer the data out of the NET array and into a more standard
			% matlab array.
			for n=1:numBytesToRead
				readData(n) = rawReadData(n);

				% If debugging is enabled print out the read data in hex format.
				if obj.enable_debug
					dataByte = dec2hex(readData(n))
				end
			end
		end
		function write(obj, userWriteData)
			% Define variables needed for this operation
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			
			% Save the ioType being used in a shorter variable name.
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;

			% Add an I2C write request
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);
			
			% Execute the I2C Write Request.
			obj.ljud.GoOne(obj.handle);
		end
		function [numAcks] = writeAndGetAcks(obj, userWriteData)
			% Define variables needed for this operation
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			
			% Save the ioType being used in a shorter variable name.
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;

			% Add an I2C write request
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);

			% Add an I2C Get-Acks request.
			numAcks = 0;
			channel = LabJack.LabJackUD.CHANNEL.I2C_GET_ACKS;
			obj.ljud.AddRequest(obj.handle, ioType, channel, numAcks, 0, 0);
			
			% Execute the I2C Write and GetAcks Request.
			obj.ljud.GoOne(obj.handle);

			% Get the number of ack bits received during the write request.
			[ljerror, numAcks] = obj.ljud.GetResult(obj.handle, ioType, channel, 0);

			% If debugging is enabled print out the number of received ack bits.
			if obj.enable_debug
				numAcks
			end
		end
		function [readData]=writeAndRead(obj, userWriteData, numBytesToRead)
			% Define variables needed for this operation
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);
			rawReadData = NET.createArray('System.Byte', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			
			% Save the ioType being used in a shorter variable name.
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;

			% Add an I2C write request
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);

			% Add an I2C read request
			channel = LabJack.LabJackUD.CHANNEL.I2C_READ;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numBytesToRead, rawReadData, 0);
			
			% Execute the I2C Write and Read Request
			obj.ljud.GoOne(obj.handle);

			% Print out debugging info
			if obj.enable_debug
				readData
				disp('Indexing through data...');
			end

			% Transfer the data out of the NET array and into a more standard
			% matlab array.
			for n=1:numBytesToRead
				readData(n) = rawReadData(n);

				% If debugging is enabled print out the read data in hex format.
				if obj.enable_debug
					dataByte = dec2hex(readData(n))
				end
			end
		end
		function [numAcks, readData]=writeGetAcksAndRead(obj, userWriteData, numBytesToRead)
			% Define variables needed for this operation
			numWrite = length(userWriteData);
			writeData = NET.createArray('System.Byte', numWrite);
			rawReadData = NET.createArray('System.Byte', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end
			
			% Save the ioType being used in a shorter variable name.
			ioType = LabJack.LabJackUD.IO.I2C_COMMUNICATION;

			% Add an I2C write request
			channel = LabJack.LabJackUD.CHANNEL.I2C_WRITE;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numWrite, writeData, 0);

			% Add an I2C Get-Acks request
			numAcks = 0;
			channel = LabJack.LabJackUD.CHANNEL.I2C_GET_ACKS;
			obj.ljud.AddRequest(obj.handle, ioType, channel, numAcks, 0, 0);

			% Add an I2C read request
			channel = LabJack.LabJackUD.CHANNEL.I2C_READ;
			obj.ljud.AddRequestPtr(obj.handle, ioType, channel, numBytesToRead, rawReadData, 0);
			
			% Execute the I2C Write, GetAcks, and Read Request
			obj.ljud.GoOne(obj.handle);

			% Get the number of ack bits received during the read request.
			[ljerror, numAcks] = obj.ljud.GetResult(obj.handle, ioType, channel, 0);

			% Print out debugging info
			if obj.enable_debug
				numAcks
				readData
				disp('Indexing through data...');
			end

			% Transfer the data out of the NET array and into a more standard
			% matlab array.
			for n=1:numBytesToRead
				readData(n) = rawReadData(n);

				% If debugging is enabled print out the read data in hex format.
				if obj.enable_debug
					dataByte = dec2hex(readData(n))
				end
			end
		end
	end
end