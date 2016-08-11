from labjack import ljm
from labjack.ljm import *
import time, math
'''
Wire the SX1509 accordingly:
 3  -> Resistor(70 Ohm) -> LED cathode(-) -- LED anode (+) -> 3.3V
 4  -> Resistor(70 Ohm) -> LED cathode(-) -- LED anode (+) -> 3.3V
 5  -> Resistor(70 Ohm) -> LED cathode(-) -- LED anode (+) -> 3.3V
 13 -> Resistor(70 Ohm) -> LED cathode(-) -- LED anode (+) -> 3.3V
 14 -> Resistor(70 Ohm) -> LED cathode(-) -- LED anode (+) -> 3.3V

 8  -> Resistor(10 KOhm) -> 3.3V
 8  -> Pushbutton -> GND
 9  -> Resistor(10 KOhm) -> 3.3V
 9  -> Pushbutton -> GND
'''
##Open first found LabJack
handle = openS("T7", "Ethernet", "470010108")
info = getHandleInfo(handle)

#change to change rate
delay = .2 #seconds

def writeVal(val, pinOn):
    string = "{0:b}".format(val)
    if 1==0:
        print("0b"+(8-len(string))*"0"+string+" ("+str(val)+"), Inputs: "+str(readInputs()[0])+str(readInputs()[1]))
    else:
        print("On: "+pinOn+((5-len(pinOn))*" ")+"Inputs: "+str(readInputs()[0])+"  "+str(readInputs()[1]))
    eWriteAddress(handle, 46080, 2, val%256)#chan A, lower half of value
    eWriteAddress(handle, 46082, 2, val//256)#chan B, upper half of value
def readInputs():
    dataIn = [1, 1]
    dataInRaw = eReadAddress(handle, 46090, 2)
    if dataInRaw%2 == 1:
        dataIn[0] = 0
    if (dataInRaw//2)%2 == 1:
        dataIn[1] = 0
    return dataIn
#init direction
eWriteAddress(handle, 46084, 2, 0b11111111)#chan A
eWriteAddress(handle, 46086, 2, 0b11111100)#Chan B, input on 8 and 9
#init pullup
eWriteAddress(handle, 46092, 2, 0b11111111)#chan A
eWriteAddress(handle, 46094, 2, 0b11111100)#Chan B, pull-up on 8 and 9
#REMEMBER: 0 turns the LED on, 1 turns the LED off, consistent with the SX1509 Datasheet
while True:
    for i in range(0, 16):#turn on each individually
        val = (2**16-1)-2**i
        writeVal(val, str(i))
        time.sleep(delay)
    writeVal((2**16-1), "None")#turn all off
    time.sleep(delay)
    writeVal(0, "All")#turn all on
    time.sleep(delay)
    writeVal((2**16-1), "None")#turn all off
    time.sleep(delay)

