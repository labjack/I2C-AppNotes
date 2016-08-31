# I2C-AppNotes/LJM_Library
This section of the I2C-AppNotes git repository contains I2C code related to the LabJack [LJM Library](https://labjack.com/support/software/installers/ljm).

## Requirements
This section of the repository contains code that requires the LabJack [LJM Library](https://labjack.com/support/software/installers/ljm) to already be installed.  In some cases there are further requirements such as a languages driver wrapper.  These can be found on LabJack's [Example Code/Wrappers](https://labjack.com/support/software/examples) webpage.

## Driver Documentation
Documentation for the LJM library that is heavily used in these examples and I2C wrappers can be found below:
* [LJM Library Docs](https://labjack.com/support/software/api/ljm)

## Device Datasheets
There is a lot of useful information in each of the devices datasheets relating to I2C.  The implemented I2C wrappers try to hide some of the complexities but in some cases it may be necessary to look for documentation about how I2C works on an individual LabJack device.
* [I2C Section of the T7 Datasheet](https://labjack.com/support/datasheets/t7/digital-io/i2c)

##Directory Structure
* The [I2C_Abstraction_Layers](https://github.com/labjack/I2C-AppNotes/tree/master/LJM_Library/I2C_Abstraction_Layers) folder contains the language specific I2C abstraction layer to assist users with using I2C sensors on LJM library compatible device.
* There are several other folders titled [sensor type]-[part number] that contain sensor specific example code.

## LJM Library I2C Wrappers
###Supported Devices
<a href="https://labjack.com/products/t7"><img src="https://labjack.com/sites/default/files/T7-Pro_USB_Ethernet_WiFi_DAQ_Device.JPG" width="100px" height="75px" alt="LabJack T7/T7-Pro USB Ethernet, and WiFi DAQ Device" title="T7"></a>
###Available Wrappers
* Matlab
* LabVIEW
* Lua ([via Lua Scripting](https://labjack.com/support/datasheets/t7/scripting))
