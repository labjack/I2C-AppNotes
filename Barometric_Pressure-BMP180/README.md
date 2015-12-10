##BMP180 Barometric Pressure Sensor - I2C Mode
This I2C example is directed toward the [Sparkfun BMP180 Barometric Pressure Sensor Breakout](https://www.sparkfun.com/products/11824).

<a href="https://www.sparkfun.com/products/11824"><img src="https://cdn.sparkfun.com//assets/parts/8/1/8/0/11824-01.jpg" width="213.75px" height="213.75px" alt="Sparkfun BMP180 Barometric Pressure Sensor Breakout" title="Sparkfun BMP180 Barometric Pressure Sensor Breakout"></a>

## Directory Structure
* [utils](https://github.com/labjack/I2C-AppNotes/tree/master/Accelerometer-ADXL345/utils) Directory:
  This folder contains language specific utilities to assist in collecting or parsing data from the BMP180 sensor.

## Example Code:
* Example code for the BMP180 Barometric Pressure Sensor that works for the UD devices:

  <a href="https://labjack.com/products/u3"><img src="https://labjack.com/sites/default/files/U3HV_white_shadow.JPG" width="100px" height="75px" alt="LabJack U3-LV/U3-HV USB DAQ Device" title="U3"></a>
  <a href="https://labjack.com/products/u6"><img src="https://labjack.com/sites/default/files/U6_0.jpg" width="100px" height="75px" alt="LabJack U6/U6-Pro USB DAQ Device" title="U6"></a>
  <a href="https://labjack.com/products/ue9"><img src="https://labjack.com/sites/default/files/UE9.JPG" width="100px" height="75px" alt="LabJack UE9/UE9-Pro USB and Ethernet DAQ Device" title="UE9"></a>
  
   can be found in the [/UD_Driver/Barometric_Pressure-BMP180](https://github.com/labjack/I2C-AppNotes/tree/master/UD_Driver/Barometric_Pressure-BMP180) directory.
* Example code for the BMP180 Barometric Pressure Sensor that works for compatible LJM devices:

  <a href="https://labjack.com/products/t7"><img src="https://labjack.com/sites/default/files/T7-Pro_USB_Ethernet_WiFi_DAQ_Device.JPG" width="100px" height="75px" alt="LabJack T7/T7-Pro USB, Ethernet, and WiFi DAQ Device" title="T7"></a>
  
  can be found in the [/LJM_Library/Barometric_Pressure-BMP180](https://github.com/labjack/I2C-AppNotes/tree/master/LJM_Library/Barometric_Pressure-BMP180) directory.

##Connecting the Sensor:
1. This sensor requires a 1.8V to 3.6V supply voltage so we will use LabJacks LJTick-LVDigitalIO tick with the switch selecting the 3.3V logic level.
  
  <a href="https://labjack.com/accessories/ljtick-lvdigitalio"><img src="https://labjack.com/sites/default/files/LJTick-LVDigitalIO_1_white.JPG" width="100px" height="75px" alt="LJTick-LVDigitalIO" title="LJTick-LVDigitalIO"></a>

2. Looking at Sparkfun's breakout board [schematic](http://cdn.sparkfun.com/datasheets/Sensors/Pressure/BMP180%20breakout.pdf) it is clear that pull-up resistors are already installed on the SDA and SCL lines so they will not need to be installed.  According to the schematic they can be easily removed by getting rid of the short on SJ1.

3. Verifing the connection by looking at the datasheet for the BMP180 you will find an typical application circuit diagram (Figure 2, page 10).  It shows there being no other wires that need to be connected for this sensor to work properly.  Page 18 of the datasheet mentions a register titled "Chip-id" whose
register is 0xD0.  The value is fixed to 0x55 and can be used to check whether communication is functioning.

##Configuring the LabJack I2C Bus:
1. The 7-bit Slave Address is 0x53. This information is found in the datasheet on page 20.  It states that the 8-bit address used for reads is 0xEF and the 8-bit address for writes is 0xEE.  Therefore the 7-bit address is 0b1110111 or 0x77.


2. Most of the included examples will connect the sensor's SCL line to pin 7 (FIO7) of the LabJack device.

3. Most of the included examples will connect the sensor's SDA line to pin 6 (FIO6) of the LabJack device.

4. Looking at the datasheet for the BMP180 you will find a breif-overview with what basic communications with this sensor look like.  
  Figure 8 of the BMP180's datasheet shows an example write command:

  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Barometric_Pressure-BMP180/Figure-8_I2C-write-request.JPG" width="100%" alt="BMP180 Example I2C Write Command" title="I2C Write Command">

  Figure 9 of the BMP180's datasheet shows an example read command:

  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Barometric_Pressure-BMP180/Figure-9_I2C-read-request.JPG" width="100%" alt="BMP180 Example I2C Write Command" title="I2C Write Command">

  This sensor supports single and multi-byte reads/writes.  One important thing to keep in mind is what happens when trying to read data.  Look at figure 9.  Inbetween the write and read commands there is text indicating a "Restart" condition needs to occur.  It doesn't specifically mention that there needs to be a "stop" condition.  It does however not display a "start" condition being required.  Essentially, these diagrams indicate that we don't need to enable any of the I2C settings: 
  1. Reset at start
  2. No stop when restarting
  3. Enable clock stretching
  If communication isn't working properly the "No stop when restarting" option may need to be enabled.

5. We don't need to adjust the I2C clock speed because the sensor supports up to 400kHz data transfer modes.

##Communicating with the Sensor:
1. Look at the LabJack [I2C-Simulator](https://labjack.com/content/i2c-simulator) tool. This basic online tool will let you visualize the data being sent over the I2C data bus during various write and read commands.  It also helps visualize what some of the I2C Options are. An example read & write command for this sensor at slave address 0x77 to read the Chip ID looks like:
  
  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Barometric_Pressure-BMP180/I2C_Simulator_Example_Read_Chip_ID.JPG" width="100%" alt="BMP180 Example I2C Read & Write Command" title="I2C Read & Write Command">
