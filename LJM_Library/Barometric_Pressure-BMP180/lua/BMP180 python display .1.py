from labjack import ljm
from labjack.ljm import *
import time, math
'''
Uses the BMP180 connected on the I2C bus and a Lua script writing data to USER_RAM registers
'''
##Open first found LabJack
handle = openS("ANY", "USB", "ANY")
info = getHandleInfo(handle)
calAddrs = []
calTypes = []
for i in range(0, 11):
    calAddrs.append(46022+i*2)
    calTypes.append(3)
calConst = eReadAddresses(handle, 11, calAddrs, calTypes)#0 indexed
AC1 = calConst[0]
AC2 = calConst[1]
AC3 = calConst[2]
AC4 = calConst[3]
AC5 = calConst[4]
AC6 = calConst[5]
B1 = calConst[6]
B2 = calConst[7]
MB = calConst[8]
MC = calConst[9]
MD = calConst[10]
while True:
    UT = eReadAddress(handle, 46018, 3)
    UP = eReadAddress(handle, 46020, 3)
    
    X1 = (UT-AC6)*AC5/2**15
    X2 = MC*(2**11)/(X1+MD)
    B5 = X1 + X2
    Tc = ((B5+8)/2**4)/10
    Tf = (Tc*(9.0/5))+32
    

    B6 = B5-400
    X1 = (B2*(B6*B6/(2*12)))/2**11
    X2 = AC2*B6/2**11
    X3 = X1+X2
    B3 = ((AC1*4+X3)+2)/4
    X1 = AC3*B6/2**13
    X2 = (B1*(B6*B6/2**12))/2**16
    X3 = ((X1+X2)+2)/4
    B4 = AC4*(X3+32768)/2**15#UNSIGNED LONG?
    B7 = (UP-B3)*(50000)
    if B7 < 0x80000000:
        P = (B7*2)/B4
    else:
        P = (B7/B4)*2
    X1 = (P/2**8)*(P/2**8)
    X1 = (X1*3038)/2**16
    X2 = (-7357*P)/2**16
    Ppa = P+(X1+X2+3791)/2**4
    Patm =  9.86923E-06*Ppa

    print("Temp :"+str(Tf)+"F ("+str(Tc)+"C)  Pressure: "+str(Patm))
    time.sleep(1)
    
