# UD Driver I2C Abstraction Layers
These are the available I2C abstraction layers.  These are wrappers on the available [LJM Library](https://labjack.com/support/software/installers/ljm) and have the same platform restrictions as the available [LJM library example code](https://labjack.com/support/software/examples/ljm).

## Troubleshooting
If you are experiencing issues getting started with any of these wrappers you should start with the basic device examples found in these example code libraries.

## Supported Devices
<a href="https://labjack.com/products/t7"><img src="https://labjack.com/sites/default/files/T7-Pro_USB_Ethernet_WiFi_DAQ_Device.JPG" width="100px" height="75px" alt="LabJack T7/T7-Pro USB Ethernet, and WiFi DAQ Device" title="T7"></a>

## Device Datasheets
There is a lot of useful information in each of the devices datasheets relating to I2C.  The implemented I2C wrappers try to hide some of the complexities but in some cases it may be necessary to look for documentation about how I2C works on an individual LabJack device.
* [T7 Datasheet](https://labjack.com/support/datasheets/t7)

## I2C Datasheet Reference
There are some useful code snippits provided on on the devices I2C Serial Communication pages found in their datasheets.
* [T7 I2C Reference](https://labjack.com/support/datasheets/t7/digital-io/i2c)

## I2C Simulator
The [I2C Simulation tool](https://labjack.com/support/datasheets/t7/digital-io/i2c/simulation-tool) available on LabJack's website provides a visual example of the devices I2C options and provide a digital logic analyzer style visualization.