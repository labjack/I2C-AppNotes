# I2C-AppNotes
This is a git repository for LabJack's I2C driver/library wrappers and sensor specific examples.  

## Requirements
This repository contains code that requires the LabJack [LJM Library](https://labjack.com/support/software/installers/ljm) or the LabJack [UD Library/Driver](https://labjack.com/support/software/installers/ud) to already be installed.  In some cases there are further requirements such as a languages driver wrapper.  These can be found on LabJack's [Example Code/Wrappers](https://labjack.com/support/software/examples) webpage.

## Driver Documentation
Documentation for the LJM and UD libraries that are heavily used in these examples and I2C wrappers can be found below:
* [LJM Library Docs](https://labjack.com/support/software/api/ljm)
* [UD Library Docs](https://labjack.com/support/software/installers/ud)

## Device Datasheets
There is a lot of useful information in each of the devices datasheets relating to I2C.  The implemented I2C wrappers try to hide some of the complexities but in some cases it may be necessary to look for documentation about how I2C works on an individual LabJack device.
* [T7 Datasheet](https://labjack.com/support/datasheets/t7)
* [U3 Datasheet](https://labjack.com/support/datasheets/u3)
* [U6 Datasheet](https://labjack.com/support/datasheets/u6)
* [UE9 Datasheet](https://labjack.com/support/datasheets/ue9)

##Directory Structure
* The [LJM_Library_Abstraction_Layers](https://github.com/labjack/I2C-AppNotes/tree/master/LJM_Library_Abstraction_Layers) folder contains language specific I2C wrappers that use the LJM driver and are therefore compatible with the T7.
* The [UD_Driver_Abstraction_Layers](https://github.com/labjack/I2C-AppNotes/tree/master/UD_Driver_Abstraction_Layers) folder contains language specific I2C wrappers that use the UD driver and are therefore compatible with the U3, U6, and UE9.
* There are several other folders titled [sensor type]-[part number] that contain sensor specific example data.

## LJM Driver I2C Wrappers
###Supported Devices:
<a href="https://labjack.com/products/t7"><img src="https://labjack.com/sites/default/files/T7-Pro_USB_Ethernet_WiFi_DAQ_Device.JPG" width="100px" height="75px" alt="LabJack T7/T7-Pro USB Ethernet, and WiFi DAQ Device" title="T7"></a>
###Available Wrappers:
* None Yet...

## UD Driver I2C Wrappers
###Supported Devices:
<a href="https://labjack.com/products/u3"><img src="https://labjack.com/sites/default/files/U3HV_white_shadow.JPG" width="100px" height="75px" alt="LabJack U3-LV/U3-HV USB DAQ Device" title="U3"></a>
<a href="https://labjack.com/products/u6"><img src="https://labjack.com/sites/default/files/U6_0.jpg" width="100px" height="75px" alt="LabJack U6/U6-Pro USB DAQ Device" title="U6"></a>
<a href="https://labjack.com/products/ue9"><img src="https://labjack.com/sites/default/files/UE9.JPG" width="100px" height="75px" alt="LabJack UE9/UE9-Pro USB and Ethernet DAQ Device" title="UE9"></a>
###Available Wrappers:
* LabVIEW
* Working on matlab
