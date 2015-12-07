These MATLAb .m files abstract the direct usage of LabJacks UD Library that is used to communicate with the U3, U6, and UE9 devices when using the devices I2C functionality.  These files don't require that you have previously downloaded the available [MATLAB Examples](https://labjack.com/support/software/examples/ud/matlab) however it is highly recomended to download and try the basic MATLAB examples first.  I2C is an advanced feature and is harder to debug than many of the other LabJack device features.

These MATLAB .m files were created in MATLAB 2009a and may not be applicable to earlier or later versions of MATLAB.  See LabJack's [MATLAB Examples](https://labjack.com/support/software/examples/ud/matlab) page for more details.

## Using the MATLAB I2C Abstraction Layer
The example code snippits below outline how to use the I2C Abstraction layer for MATLAB.  For more usage details and example code look in the sensor directories and look at the LabJack's available [MATLAB Examples](https://labjack.com/support/software/examples/ud/matlab).

### Including the LJUD Library & Opening a Device.
```matlab
clc %Clear the MATLAB command window
clear %Clear the MATLAB variables

% Any matlab application that wants to interface with a U3, U6, or UE9 and the
% UD Driver needs to include the UD .NET assembly.
% Make the UD .NET assembly visible in MATLAB
ljasm = NET.addAssembly('LJUDDotNet');
ljudObj = LabJack.LabJackUD.LJUD;

% Before using a device, the device must be opened.  This is a similar concept
% to to most File I/O and TCP communication.  The UD Library can open a U3, U6, or UE9.
% Open the first found LabJack U6.
[ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);
```

### Initializing the I2C Utility
```matlab
% Initialize the I2C Utility.
i2cUtils = I2C_Utils(ljudObj, ljhandle);

% Define variables for various I2C attributes.
% This is the I2C sensors 7-bit slave address found in its datasheet.
% The MATLAB I2C_Utils wrapper will shift this number automatically.
i2cUtils.slave_address = hex2dec('53');

% These are the SDA and SCL pin numbers.
i2cUtils.sda_num = 6;
i2cUtils.scl_num = 7;

% Define a variable for the I2C Options:
%  1. reset_at_start
%  2. no_stop_when_restarting
%  3. enable_clock_stretching
i2cUtils.options = I2C_Options(false, false, false);

% Set the I2C Bus speed.  0 indicates "fastest".
i2cUtils.speed_adj = 0;

% Perform Device I/O to configure the LabJack's I2C Bus
i2cUtils.configure();
```

### Executing I2C commands.
```matlab
% We are now ready to perform various I2C read and write commands.

% Function: read
% Arguments:
% 1. numBytesToRead, the number of bytes to read during the read command.
% Returned Data:
% 1. readData, the data read during the read command.
numBytesToRead = 1;
[readData] = read(numBytesToRead);

% Function: write
% Arguments:
% 1. writeData, the array of bites to be written during the write command.
writeData = [0];
write(writeData);

% Function: writeAndGetAcks
% Arguments:
% 1. writeData, the array of bites to be written during the write command.
% Returned Data:
% 1. numAcks, the number of ack bits received during the read command.
writeData = [0];
[numAcks] = writeAndGetAcks(writeData);

% Function: writeAndRead
% Arguments:
% 1. writeData, the array of bites to be written during the write command.
% 2. numBytesToRead, the number of bytes to read during the read command.
% Returned Data:
% 1. readData, the data read during the read command.
writeData = [0];
numBytesToRead = 1;
[readData] = writeAndRead(writeData, numBytesToRead);

% Function: writeGetAcksAndRead
% Arguments:
% 1. writeData, the array of bites to be written during the write command.
% 2. numBytesToRead, the number of bytes to read during the read command.
% Returned Data:
% 1. numAcks, the number of ack bits received during the read command.
% 2. readData, the data read during the read command.
writeData = [0];
numBytesToRead = 1;
[numAcks, readData] = writeGetAcksAndRead(writeData, numBytesToRead);
```