## Getting Started:
1. Clone, Fork, or [download](https://github.com/labjack/I2C-AppNotes/archive/master.zip) and extract the I2C-AppNotes git repository.
2. Add the I2C-AppNotes folder (and subfolders) directory to your path using matlabs [pathtool](http://www.mathworks.com/help/matlab/ref/pathtool.html).  In MATLAB's command window type:
  ```matlab
  pathtool
  ```

3. Configure what device is going to be opened:

  ```matlab
  % Open the first found LabJack U3.
  disp('Opening U3');
  [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U3,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);

  % Open the first found LabJack U6.
  disp('Opening U6');
  [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U6,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);

  % Open the first found LabJack UE9.
  disp('Opening UE9');
  [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.UE9,LabJack.LabJackUD.CONNECTION.USB,'0',true,0);
  ```

4. Run the "verify_hardware" script:
  In MATLAB's command window type:

  ```matlab
  UD_BMP180_verify_hardware()
  ```

  The response should be:

  ```
  Opening U6
  BMP180 is properly connected for I2C communication.
  Num acks received:1
  Chip-id Result: 0x55
  ```

5. Run the "demo" script:
  In MATLAB's command window type:
  ```matlab
  UD_BMP180_demo()
  ```

  The response should be:
  ```
  Opening U6
  UT:20686
  UP:272168
  Temperature:24C
  Pressure:82173Pa
  Pressure:82.173kPa
  Pressure:24.2658inHg
  Pressure:821.73mbar
  Pressure:616.3482mmHg
  ```