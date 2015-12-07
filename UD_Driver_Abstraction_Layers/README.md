# UD Driver I2C Abstraction Layers
These are the available I2C abstraction layers.  These are wrappers on the available [UD Library](https://labjack.com/support/software/installers/ud) and have the same platform restrictions as the available [UD library example code](https://labjack.com/support/software/examples/ud).

## Troubleshooting
If you are experiencing issues getting started with any of these wrappers you should start with the basic device examples found in these example code libraries.

## Supported Devices:
<a href="https://labjack.com/products/u3"><img src="https://labjack.com/sites/default/files/U3HV_white_shadow.JPG" width="100px" height="75px" alt="LabJack U3-LV/U3-HV USB DAQ Device" title="U3"></a>
<a href="https://labjack.com/products/u6"><img src="https://labjack.com/sites/default/files/U6_0.jpg" width="100px" height="75px" alt="LabJack U6/U6-Pro USB DAQ Device" title="U6"></a>
<a href="https://labjack.com/products/ue9"><img src="https://labjack.com/sites/default/files/UE9.JPG" width="100px" height="75px" alt="LabJack UE9/UE9-Pro USB and Ethernet DAQ Device" title="UE9"></a>

## Device Datasheets
There is a lot of useful information in each of the devices datasheets relating to I2C.  The implemented I2C wrappers try to hide some of the complexities but in some cases it may be necessary to look for documentation about how I2C works on an individual LabJack device.
* [U3 Datasheet](https://labjack.com/support/datasheets/u3)
* [U6 Datasheet](https://labjack.com/support/datasheets/u6)
* [UE9 Datasheet](https://labjack.com/support/datasheets/ue9)

## I2C Related High-Level Driver Reference
There are some useful code snippits provided on on the devices I2C Serial Communication pages found in their datasheets.
* [U3 High-Level Driver Reference](https://labjack.com/support/datasheets/u3/high-level-driver/example-pseudocode/i2c)
* [U6 High-Level Driver Reference](https://labjack.com/support/datasheets/u6/high-level-driver/example-pseudocode/i2c)
* [UE9 High-Level Driver Reference](https://labjack.com/support/datasheets/ue9/high-level-driver/example-pseudocode/i2c)

## I2C Related Low-Level Functions
There are some useful code snippits provided on on the devices Low-Level Functions/I2C pages found in their datasheets.
* [U3 Low-Level Function Reference](https://labjack.com/support/datasheets/u3/low-level-function-reference/i2c)
* [U6 Low-Level Function Reference](https://labjack.com/support/datasheets/u6/low-level-function-reference/i2c)
* [UE9 Low-Level Function Reference](https://labjack.com/support/datasheets/ue9/low-level-function-reference/control-functions/i2c)