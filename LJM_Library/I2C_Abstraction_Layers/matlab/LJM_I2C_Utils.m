classdef LJM_I2C_Utils
	% LabJack I2C Utilities Object
	properties
		ljm % LabJack LJM Library reference
		constants % LJM Library's constants.
		handle % The handle to the open LabJack device.
		slave_address % 7-bit I2C Slave Address
		sda_num % The SDA pin number
		scl_num % The SCL pin number
		options % The integer used for I2C Options
		speed_adj % The speed adjust

		enable_debug % A variable that can be set to true to print out debugging data
	end

	methods
		function obj=LJM_I2C_Utils(ljm, ljm_constants, handle)
			% Save references to the ljm library and the handle to the currently
			% open device.
			obj.ljm = ljm;
			obj.constants = ljm_constants;
			obj.handle = handle;
		end
		function configure(obj)
			% The T7 requires an un-shifted 7-bit slave address.
			slave_address = obj.slave_address;

			% Retrieve various I2C configuration parameters.
			sda_num = obj.sda_num;
			scl_num = obj.scl_num;
			options = obj.options.calculate();
			speed_adj = obj.speed_adj;

			% Configure the I2C slave address
			obj.ljm.eWriteName(obj.handle, 'I2C_SLAVE_ADDRESS', slave_address);
			
			% Configure the SDA pin number
			obj.ljm.eWriteName(obj.handle, 'I2C_SDA_DIONUM', sda_num);

			% Configure the SCL pin number
			obj.ljm.eWriteName(obj.handle, 'I2C_SCL_DIONUM', scl_num);

			% Configure the I2C Options
			obj.ljm.eWriteName(obj.handle, 'I2C_OPTIONS', options);

			% Configure the I2C bus speed
			obj.ljm.eWriteName(obj.handle, 'I2C_SPEED_THROTTLE', speed_adj);

			% Finished configuring the LabJack's I2C Bus
			if obj.enable_debug
				disp('Configured I2C Bus');
			end
		end

		function [readData]=read(obj, numBytesToRead)
			% Define variables needed for this operation
			rawReadData = NET.createArray('System.Byte', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);
			numBytesToWrite = 0;
			
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
			writeData = NET.createArray('System.Double', numWrite);
			rawReadData = NET.createArray('System.Double', numBytesToRead);
			readData = uint8.empty(0, numBytesToRead);

			% Define some arrays required to use LJM
			aNames = NET.createArray('System.String', 1);
			aWrites = NET.createArray('System.Int32', 1);
			aNumValues = NET.createArray('System.Int32', 1);

			% Transfer the user's values into the byte array.
			for n=1:numWrite
				writeData(n) = userWriteData(n);
			end

			% Clear the rawReadData array
			for n=1:numBytesToRead
				rawReadData(n) = 0;
			end
			
			% Configure the number of bytes need to be written.
			obj.ljm.eWriteName(obj.handle, 'I2C_NUM_BYTES_TX', numWrite);

			% Configure the number of bytes that need to be read.
			obj.ljm.eWriteName(obj.handle, 'I2C_NUM_BYTES_RX', numBytesToRead);

			% Send the data that needs to be written to the device.
			aNames(1) = 'I2C_WRITE_DATA';
			aWrites(1) = obj.constants.WRITE;
			aNumValues(1) = numWrite;
			obj.ljm.eNames(obj.handle, 1, aNames, aWrites, aNumValues, writeData, 0);

			% Perform the I2C request
			obj.ljm.eWriteName(obj.handle, 'I2C_GO', 1);

			% Get the data that was read during the read-segment of the I2C command.
			aNames(1) = 'I2C_READ_DATA';
			aWrites(1) = obj.constants.READ;
			aNumValues(1) = numBytesToRead;
			obj.ljm.eNames(obj.handle, 1, aNames, aWrites, aNumValues, rawReadData, 0);

			% Get the num acks that were received.
			[ljmError, numAcks] = obj.ljm.eReadName(obj.handle, 'I2C_ACKS', 0);

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