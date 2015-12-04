##ADXL345 Accelerometer - I2C Mode
This I2C example is directed toward the [Sparkfun ADXL345 Accelerometer](https://www.sparkfun.com/products/9836)

<a href="https://www.sparkfun.com/products/9836"><img src="https://cdn.sparkfun.com/assets/parts/3/9/0/2/09836-_01c.jpg" width="213.75px" height="213.75px" alt="Sparkfun ADXL345 Accelerometer" title="Sparkfun ADXL345 Accelerometer"></a>
##Directory Structure
* [language_name]-utils Directories:  
  These folders contain sensor-specific code that provide helpful tools for collecting and parsing data from the ADXL345 sensor.
* [UD_Devices](https://github.com/labjack/I2C-AppNotes/tree/master/Accelerometer-ADXL345/UD_Devices) Directory:  
  This directory contains the examples for the ADXL345 Accelerometer implemented in a variety of languages targeting the following LabJack devices:

  <a href="https://labjack.com/products/u3"><img src="https://labjack.com/sites/default/files/U3HV_white_shadow.JPG" width="100px" height="75px" alt="LabJack U3-LV/U3-HV USB DAQ Device" title="U3"></a>
  <a href="https://labjack.com/products/u6"><img src="https://labjack.com/sites/default/files/U6_0.jpg" width="100px" height="75px" alt="LabJack U6/U6-Pro USB DAQ Device" title="U6"></a>
  <a href="https://labjack.com/products/ue9"><img src="https://labjack.com/sites/default/files/UE9.JPG" width="100px" height="75px" alt="LabJack UE9/UE9-Pro USB and Ethernet DAQ Device" title="UE9"></a>

##Connecting the Sensor:
1. This sensor requires a 2.0V to 3.6V supply voltage so we will use LabJacks LJTick-LVDigitalIO tick with the switch selecting the 3.3V logic level.
  
  <a href="https://labjack.com/accessories/ljtick-lvdigitalio"><img src="https://labjack.com/sites/default/files/LJTick-LVDigitalIO_1_white.JPG" width="100px" height="75px" alt="LJTick-LVDigitalIO" title="LJTick-LVDigitalIO"></a>

2. Looking at Sparkfun's breakout board [schematic](http://cdn.sparkfun.com/datasheets/Sensors/Accelerometers/ADXL345_Breakout.pdf) it is clear that no pull-up resistors are installed on the SDA and SCL lines so they will need to be installed.  It essentially just breaks out the part's IO lines and leaves the rest to the integrator.

3. Looking at the datasheet for the ADXL345 you will find an I2C Connection Diagram (Figure 8).  It instructs the implementer to add a short to the !CS line and VCC and a short between the SDO/ALT ADDRESS (pin 12) line and GND so that the 7-bit I2C address becomes 0x53.
  
  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Accelerometer-ADXL345/ADXL345-I2C-Connection-Diagram.JPG" width="258px" height="173px" alt="ADXL345 I2C Device Connection Diagram" title="ADXL345 Wiring Diagram">

##Configuring the LabJack I2C Bus:
1. The 7-bit Slave Address is 0x53.  This information is found in the datasheet and was configured by shorting SDO/ALT ADDRESS (pin 12) line to GND.

2. Most of the included examples will connect the sensor's SCL line to pin 7 (FIO7) of the LabJack device.

3. Most of the included examples will connect the sensor's SDA line to pin 6 (FIO6) of the LabJack device.

4. Looking at the datasheet for the ADXL345 you will find a breif-overview with what basic communications with this sensor look like (Figure 9. I2C Device Addressing).

  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Accelerometer-ADXL345/ADXL345-I2C-Com-Diagram.JPG" width="100%" alt="ADXL345 I2C Device Addressing Diagram" title="Device Addressing Diagram">

  The sensor supports single and multi-byte reads/writes.  One important thing to keep in mind is what happens when trying to read data.  Look at the "Single-Byte Read" command.  Inbetween the write and read commands there is a "Start 1" block indicating that there needs to be either a restart or a stop followed by a start.  These diagrams indicate that we don't need to enable the I2C settings: 
  1. Reset at start
  2. No top when restarting
  3. Enable clock stretching

5. We don't need to adjust the I2C clock speed because the sensor supports up to 400kHz data transfer modes.

##Communicating with the Sensor:
1. Look at the LabJack [I2C-Simulator](https://labjack.com/content/i2c-simulator) tool. This basic online tool will let you visualize the data being sent over the I2C data bus during various write and read commands.  It also helps visualize what some of the I2C Options are. An example write command for this sensor at slave address 0x53 looks like:
  
  <img src="https://raw.githubusercontent.com/labjack/I2C-AppNotes/master/Accelerometer-ADXL345/I2C_Simulator_Example_Write.JPG" width="100%" alt="ADXl345 Example I2C Write Command" title="I2C Write Command">

2. This sensor doesn't need any time inbetween the I2C write and read commands to process the user's request. Therefore, when we are reading data from the device we can use the function calls to write and then immediately read back data from the device.

3. The ADXL345 accelerometer powers up into a low-power mode where most of its functionality is disabled.  In order to get any readings from this accelerometer it first needs to be configured.  In general we need to do the following:
  1. Configure the output data rate (Address 0x2C) for 800Hz (0x0D).
  2. Configure the power-saving features (0X2D) register to be in write mode (0x08).
  3. Configure the DATA_FORMAT (0x31) register for an appropriate range.
  4. Configure the sensor to bypass the FIFO by setting the FIFO_CTL (0x38) register to be (0x08).
4. Configuring the accelerometer is as simple as writing two bytes of data.  The first byte being the register's address and the second ++ being the data payload.
4. After doing this we can write one byte of data (address 0x32) and then read 6 bytes of data that will be the X, Y, and Z accelerometer data.