## Getting Started:
1. Clone, Fork, or [download](https://github.com/labjack/I2C-AppNotes/archive/master.zip) and extract the I2C-AppNotes git repository.
2. Add the I2C-AppNotes folder (and subfolders) to your path using matlabs [pathtool](http://www.mathworks.com/help/matlab/ref/pathtool.html).  In MATLAB's command window type:
  ```matlab
  pathtool
  ```

3. Edit the LJM_BMP180_verify_hardware.m and LJM_BMP180_demo.m files to configure what device is going to be opened:

  ```matlab
  %Open first found LabJack
  ljhandle=0;
  [ljmError, ljhandle] = LJM.OpenS('LJM_dtT7', 'LJM_ctUSB', 'ANY', ljhandle);
  showDeviceInfo(ljhandle);
  ```

4. Run the "verify_hardware" script:
  In MATLAB's command window type:

  ```matlab
  LJM_BMP180_verify_hardware()
  ```

  The response should be:

  ```
  Opened a LabJack with Device type: 7, Connection type: 1,
  Serial number: 470011479, IP address: 0.0.0.0, Port: 0,
  Max bytes per MB: 64
  BMP180 is properly connected for I2C communication.
  Num acks received:3
  Chip-id Result: 0x55
  ```

5. Run the "demo" script:
  In MATLAB's command window type:
  ```matlab
  LJM_BMP180_demo()
  ```

  The response should be:
  ```
  Opened a LabJack with Device type: 7, Connection type: 1,
  Serial number: 470011479, IP address: 0.0.0.0, Port: 0,
  Max bytes per MB: 64
  UT:20743
  UP:271957
  Temperature:24C
  Pressure:82178Pa
  Pressure:82.178kPa
  Pressure:24.2672inHg
  Pressure:821.78mbar
  Pressure:616.3857mmHg
  ```