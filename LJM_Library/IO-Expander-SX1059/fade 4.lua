 --This is an example that uses the SX1509 I/O Expander on the I2C Bus on EIO4(SCL) and EIO5(SDA)
I2C_Utils= {}
function I2C_Utils.configure(self, isda, iscl, ispeed, ioptions, islave, idebug)--Returns nothing   
  self.sda = isda
  self.scl = iscl
  self.speed = ispeed
  self.options = ioptions
  self.slave = islave
  self.debugEn = idebug
  MB.W(5100, 0, self.sda)
  MB.W(5101, 0, self.scl)
  MB.W(5102, 0, self.speed)
  MB.W(5103, 0, self.options)
  MB.W(5104, 0, self.slave)
end
function I2C_Utils.data_read(self, inumBytesRX)--Returns an array of {numAcks, Array of {bytes returned}}   
  self.numBytesRX = inumBytesRX
  self.numBytesTX = 0
  MB.W(5108, 0, self.numBytesTX)
  MB.W(5109, 0, self.numBytesRX)
  MB.W(5110, 0, 1)
  dataRX = MB.RA(5160, 99, self.numBytesRX)
  numAcks = MB.R(5114, 1)
  return {numAcks, dataRX}
end
function I2C_Utils.data_write(self, idataTX)--Returns an array of {NumAcks, errorVal}   
  self.numBytesRX = 0
  self.dataTX = idataTX
  self.numBytesTX = table.getn(self.dataTX)
  MB.W(5108, 0, self.numBytesTX)
  MB.W(5109, 0, self.numBytesRX)
  errorVal = MB.WA(5120, 99, self.numBytesTX, self.dataTX)
  MB.W(5110, 0, 1)
  numAcks = MB.R(5114, 1)
  return {numAcks, errorVal}
end
function I2C_Utils.data_write_and_read(self, idataTX, inumBytesRX)--Returns an array of {numAcks, Array of {bytes returned}, errorVal}   
  self.dataTX = idataTX
  self.numBytesRX = inumBytesRX
  self.numBytesTX = table.getn(self.dataTX)

  MB.W(5108, 0, self.numBytesTX)
  MB.W(5109, 0, self.numBytesRX)
  errorVal = MB.WA(5120, 99, self.numBytesTX, self.dataTX)
  MB.W(5110, 0, 1)
  numAcks = MB.R(5114, 1)
  dataRX = MB.RA(5160, 99, self.numBytesRX)
  return {numAcks, dataRX, errorVal}
end
function I2C_Utils.calc_options(self, iresetAtStart, inoStopAtStarting, idisableStretching)--Returns a number 0-7    
  self.resetAtStart = iresetAtStart
  self.noStop = inoStopAtStarting
  self.disableStre = idisableStretching
  optionsVal = 0
  optionsVal = self.resetAtStart*1+self.noStop*2+self.disableStre*4
  return optionsVal
end
function I2C_Utils.find_all(self, ilower, iupper)--Returns an array of all valid addresses, in number form  
  validAddresses = {}
  origSlave = self.slave
  for i = ilower, iupper do
    slave = i
    MB.W(5104, 0, slave)
    self.numBytesTX = 0
    self.numBytesRX = 1
    MB.W(5108, 0, self.numBytesTX)
    MB.W(5109, 0, self.numBytesRX)
    MB.W(5110, 0, 1)
    numAcks = MB.R(5114, 1)
    
    if numAcks ~= 0 then
      table.insert(validAddresses, i)
      -- print("0x"..string.format("%x",slave).." found")
    end
    for j = 0, 1000 do
      --delay
    end
  end
  addrLen = table.getn(validAddresses)
  if addrLen == 0 then
    print("No valid addresses were found  over the range")
  end
  MB.W(5104, 0, origSlave)
  return validAddresses
end
function convert_16_bit(msb, lsb, conv)--Returns a number, adjusted using the conversion factor. Use 1 if not desired  
  res = 0
  if msb >= 128 then
    res = (-0x7FFF+((msb-128)*256+lsb))/conv
  else
    res = (msb*256+lsb)/conv
  end
  return -1*res
end

myI2C = I2C_Utils

SLAVE_ADDRESS = 0x3E
myI2C.configure(myI2C, 13, 12, 65516, 0, SLAVE_ADDRESS, 0)--configure the I2C Bus

addrs = myI2C.find_all(myI2C, 0, 127)
addrsLen = table.getn(addrs)
for i=1, addrsLen do--verify that the target device was found     
  if addrs[i] == SLAVE_ADDRESS then
    print("I2C Slave Detected")
    break
  end
end
--[[Below are the steps required to use the LED driver with the typical LED connection described §6.2 onf the datasheet:
- Disable input buffer (RegInputDisable)
- Disable pull-up (RegPullUp)
- Enable open drain (RegOpenDrain)
- Set direction to output (RegDir) – by default RegData is set high => LED OFF
- Enable oscillator (RegClock)   (0100 1000)
- Configure LED driver clock and mode if relevant (RegMisc)
- Enable LED driver operation (RegLEDDriverEnable)
- Configure LED driver parameters (RegTOn, RegIOn, RegOff, RegTRise, RegTFall)
- Set RegData bit low => LED driver started --]]
--init slave, config outputs
myI2C.data_write(myI2C, {0x01, 0xFF})--input buffer disable
myI2C.data_write(myI2C, {0x07, 0x00})--pull up disable
myI2C.data_write(myI2C, {0x0B, 0xFF})--open drain
myI2C.data_write(myI2C, {0x0F, 0x00})--output
myI2C.data_write(myI2C, {0x11, 0xFF})--all LED off (initially)
myI2C.data_write(myI2C, {0x1E, 0x4F})--config clock
myI2C.data_write(myI2C, {0x1F, 0x70})--RegMisc
myI2C.data_write(myI2C, {0x21, 0xFF})--enable LED Driver

--config LED output 3
myI2C.data_write(myI2C, {0x32, 0x00})--regTOn
myI2C.data_write(myI2C, {0x33, 0xFF})--regIOn(intensity)
myI2C.data_write(myI2C, {0x34, 0x00})--regOff
--config LED output 4
myI2C.data_write(myI2C, {0x35, 0x00})--regTOn
myI2C.data_write(myI2C, {0x36, 0xFF})--regIOn(intensity)
myI2C.data_write(myI2C, {0x37, 0x00})--regOff
--config LED output 5
myI2C.data_write(myI2C, {0x3A, 0x00})--regTOn
myI2C.data_write(myI2C, {0x3B, 0xFF})--regIOn(intensity)
myI2C.data_write(myI2C, {0x3C, 0x00})--regOff

LJ.IntervalConfig(0, 100)
stage = 0 --used to control program progress
myI2C.data_write(myI2C, {0x11, 255-2^4})--turn 4 on
i = 0
while true do
  if LJ.CheckInterval(0) then
    if i == 256 then
      i = 0
    else
      i = i+1
    end
    myI2C.data_write(myI2C, {0x36, i})--regIOn(intensity)
    print(i)
  end
end