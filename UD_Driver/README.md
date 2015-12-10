# I2C-AppNotes/UD_Library
This section of the I2C-AppNotes git repository contains I2C code related to the LabJack [UD Library](https://labjack.com/support/software/installers/ud).

## Requirements
This repository contains code that requires the LabJack [UD Library/Driver](https://labjack.com/support/software/installers/ud) to already be installed.  In some cases there are further requirements such as a languages driver wrapper.  These can be found on LabJack's [Example Code/Wrappers](https://labjack.com/support/software/examples) webpage.

## Driver Documentation
Documentation for the UD Library that are heavily used in these examples and I2C wrappers can be found below:
* [UD Library Docs](https://labjack.com/support/software/installers/ud)

## Device Datasheets
There is a lot of useful information in each of the devices datasheets relating to I2C.  The implemented I2C wrappers try to hide some of the complexities but in some cases it may be necessary to look for documentation about how I2C works on an individual LabJack device.
* [U3 Datasheet](https://labjack.com/support/datasheets/u3)
* [U6 Datasheet](https://labjack.com/support/datasheets/u6)
* [UE9 Datasheet](https://labjack.com/support/datasheets/ue9)

##Directory Structure
* The [I2C_Abstraction_Layers](https://github.com/labjack/I2C-AppNotes/tree/master/UD_Driver/I2C_Abstraction_Layers) folder contains the language specific I2C abstraction layer to assist users with using I2C sensors on UD Driver compatible devices.
* There are several other folders titled [sensor type]-[part number] that contain sensor specific example code.

## UD Driver I2C Wrappers
###Supported Devices
<a href="https://labjack.com/products/u3"><img src="https://labjack.com/sites/default/files/U3HV_white_shadow.JPG" width="100px" height="75px" alt="LabJack U3-LV/U3-HV USB DAQ Device" title="U3"></a>
<a href="https://labjack.com/products/u6"><img src="https://labjack.com/sites/default/files/U6_0.jpg" width="100px" height="75px" alt="LabJack U6/U6-Pro USB DAQ Device" title="U6"></a>
<a href="https://labjack.com/products/ue9"><img src="https://labjack.com/sites/default/files/UE9.JPG" width="100px" height="75px" alt="LabJack UE9/UE9-Pro USB and Ethernet DAQ Device" title="UE9"></a>
###Available Wrappers
* LabVIEW
* MATLAB
