This I2C example is directed toward the [Sparkfun ADXL345 Accelerometer](https://www.sparkfun.com/products/9836)

##Directory Structure
* There are several [language]-utils folders that provide helpful abstractions to the I2C library.
* The UD_Devices directory contains the examples for the ADXL345 Accelerometer implemented in a variety of languages targeting the LabJack devices:
  * ![LabJack U3-LV/U3-HV USB DAQ Device](https://labjack.com/products/u3)
  * [![LabJack U6/U6 USB DAQ Device](https://labjack.com/sites/default/files/2-U6.jpg)](https://labjack.com/products/u6)
  * ![LabJack UE9/UE9-Pro USB and Ethernet DAQ Device](https://labjack.com/products/ue9)

##Connecting the Sensor:
1. This sensor requires a 2.0V to 3.6V supply voltage so we will use LabJacks LJTick-LVDigitalIO tick with the switch selecting the 3.3V logic level.

2. Looking at Sparkfun's breakout board schematic it is clear that no pull-up resistors are installed on the SDA and SCL lines so they will need to be installed.  It essentially just breaks out the part's IO lines and leaves the rest to the integrator.

3. Looking at the datasheet for the ADXL345 you will find an I2C Connection Diagram (Figure 8).  It instructs the implementer to add a short to the !CS line and VCC and a short between the SDO/ALT ADDRESS (pin 12) line and GND so that the 7-bit I2C address becomes 0x53.

##Configuring the LabJack I2C Bus:
1. The 7-bit Slave Address is 0x53.

2. Most of the included examples will connect the sensor's SCL line to pin 7 (FIO7) of the LabJack device.

3. Most of the included examples will connect the sensor's SDA line to pin 6 (FIO6) of the LabJack device.

4. Looking at the datasheet for the ADXL345 you will find a breif-overview with what basic communications with this sensor look like.  The sensor supports single and multi-byte reads/writes.  One important thing to keep in mind is what happens when trying to read data.  Look at the "Single-Byte Read" command.  Inbetween the write and read commands there is a "Start 1" block indicating that there needs to be either a restart or a stop followed by a start.  These diagrams indicate that we don't need to enable the I2C settings: 
  1. Reset at start
  2. No top when restarting
  3. Enable clock stretching

5. We don't need to adjust the I2C clock speed because the sensor supports up to 400kHz data transfer modes.

##Communicating with the Sensor:
1. This sensor doesn't need any time inbetween the I2C write and read commands to process the user's request.  Therefore, when we are reading data from the device we can use the function calls to write and then immediately read back data from the device.
