classdef BMP180_Cal
	% An object that stores and calculates the BMP180's calibration data.
	properties
		rawData % A reference to raw calibration data.
		
		% Various calibration values
		AC1
		AC2
		AC3
		AC4
		AC5
		AC6
		B1
		B2
		MB
		MC
		MD

		% define a variable that can be used to enable/disable auto-printing 
		% of results.
		print_results
	end
	methods
		function obj=BMP180_Cal(rawData)
			% Save the reference to the initialized I2C Utility.
			obj.rawData = rawData;
			obj.print_results = false;

			

			% An example of performing a bitwise or on two hex numbers:
			% dec2hex(bitor(bitshift(hex2dec('FF'),8),hex2dec('AB'))) == 'FFAB';

			% Example of using typecast:
			% typecast(uint16(bitor(bitshift(hex2dec('00'),8),hex2dec('AB'))), 'int16') = 171;
			% typecast(uint16(bitor(bitshift(hex2dec('FF'),8),hex2dec('AB'))), 'int16') = -85;

			% Parse AC1, a short.
			obj.AC1 = obj.parseData(rawData, 1, 2, 'int16');

			obj.AC2 = obj.parseData(rawData, 3, 4, 'int16');

			obj.AC3 = obj.parseData(rawData, 5, 6, 'int16');

			obj.AC4 = obj.parseData(rawData, 7, 8, 'uint16');

			obj.AC5 = obj.parseData(rawData, 9, 10, 'uint16');

			obj.AC6 = obj.parseData(rawData, 11, 12, 'uint16');

			obj.B1 = obj.parseData(rawData, 13, 14, 'int16');

			obj.B2 = obj.parseData(rawData, 15, 16, 'int16');

			obj.MB = obj.parseData(rawData, 17, 18, 'int16');

			obj.MC = obj.parseData(rawData, 19, 20, 'int16');

			obj.MD = obj.parseData(rawData, 21, 22, 'int16');
		end
		function parsedData = parseData(obj, rawData, iMSB, iLSB, typeStr)
			MSB = uint32(rawData(iMSB));
			LSB = uint32(rawData(iLSB));
			parsedData = typecast(uint16(bitor(bitshift(MSB,8), LSB)), typeStr);
			if strcmp(typeStr, 'int16')
				parsedData = int32(parsedData);
			else
				parsedData = uint32(parsedData);
			end

			
		end
		function printCalData(obj)
			% Print all calibration data bytes
			disp(' ');
			disp('BMP180 Raw Calibration Data:');
			numBytesRead = length(obj.rawData);
			for n=1:numBytesRead
				disp(strcat('Data: 0x', num2str(dec2hex(obj.rawData(n)))));
			end
			disp(' ');
		end
		function printCal(obj)
			disp(' ');
			disp('BMP180 Calibration Values:');
			disp(strcat('AC1:', num2str(obj.AC1)));
			disp(strcat('AC2:', num2str(obj.AC2)));
			disp(strcat('AC3:', num2str(obj.AC3)));
			disp(strcat('AC4:', num2str(obj.AC4)));
			disp(strcat('AC5:', num2str(obj.AC5)));
			disp(strcat('AC6:', num2str(obj.AC6)));
			disp(strcat('B1:', num2str(obj.B1)));
			disp(strcat('B2:', num2str(obj.B2)));
			disp(strcat('MB:', num2str(obj.MB)));
			disp(strcat('MC:', num2str(obj.MC)));
			disp(strcat('MD:', num2str(obj.MD)));
			disp(' ');
		end
		function loadDefaultCalibration(obj)
			disp('Loading default cal');
			obj.AC1 = 408;
			obj.AC2 = -72;
			obj.AC3 = -14383;
			obj.AC4 = 32741;
			obj.AC5 = 32757;
			obj.AC6 = 23153;
			obj.B1 = 6190;
			obj.B2 = 4;
			obj.MB = -32768;
			obj.MC = -8711;
			obj.MD = 2868;
		end
		function T = calculateTemperature(obj, UT, UP)
			% Algorithm for calculating temperature:
			% X1 = (UT - AC6) * AC5 / 2^15;
			% X2 = MC * 2^11 / (X1 + MD);
			% B5 = X1 + X2;
			% T = (B5 + 8) / 2^4;

			pX1 = uint32((UT - int32(obj.AC6)) * int32(obj.AC5));
			X1 = int32(bitshift(pX1, -15));
			X2 = obj.MC * 2^11 / (X1 + obj.MD);
			B5 = X1 + X2;
			T = (B5 + 8) / 2^4;

			% temp in 0.1 deg C, convert to 1 deg C
			T = T / 10;

			if obj.print_results
				disp(strcat('Temperature: ', num2str(T), 'C'));
			end
		end
		function pressure = calculatePressure(obj, UT, UP, iOSS)
			oss = uint32(iOSS);

			% Same calculation as for temperature:
			pX1 = uint32((UT - int32(obj.AC6)) * int32(obj.AC5));
			X1 = int32(bitshift(pX1, -15));
			X2 = obj.MC * 2^11 / (X1 + obj.MD);
			B5 = X1 + X2;
			T = (B5 + 8) / 2^4;

			% Algorithm for calculating pressure (mixed in with the conversion
			% to matlab compatible syntax)  ref. page 15 of BMP180 datasheet:
			% B6 = B5 - 4000
			B6 = B5 - 4000;

			% X1 = (B2 * (B6 * B6 / 2^12)) / 2^11
			% X2 = AC2 * B6 / 2^11
			% X3 = X1 + X2
			X1 = (obj.B2 * (B6 * B6 / 2^12)) / 2^11;
			X2 = obj.AC2 * B6 / 2^11;
			X3 = X1 + X2;

			% B3 = (((AC1 * 4 + X3) << oss) + 2)/4
			pB3 = int32(bitshift(uint32(obj.AC1 * 4 + X3), oss));
			B3 = int32(bitshift(uint32(pB3 + 2),-2));

			% X1 = AC3 * B6 / 2^13
			% X2 = (B1 * (B6 * B6/2^12))/2^15
			% X3 = ((X1 + X2) + 2) / 2^2
			X1 = int32(bitshift(uint32(obj.AC3 * B6), -13));
			pX2 = int32(bitshift(uint32(B6^2),-12));
			X2 = int32(bitshift(uint32(obj.B1 * pX2), -16));
			X3 = int32(bitshift(uint32((X1 + X2) + 2), -2));

			% B4 = AC4 *(unsigned long)(X3 + 32768) / 2^15
			% B7 = ((unsigned long)UP - B3) * 50000 >> oss)
			pB4 = (obj.AC4)*uint32(X3 + 32768);
			B4 = uint32(bitshift(pB4, -15));
			pB7 = uint32(uint32(int32(UP) - B3));
			B7 = pB7 * uint32(bitshift(50000, -double(oss)));
			
			% if(B7 < 0x80000000) {p = (B7 * 2)/B4}
			% else { p = (B7/B4)*2}
			p = 0;
			if B7 < hex2dec('80000000')
				p = bitshift(B7, 1) / B4;
			else
				p = bitshift((B7 / B4), 1);
			end

			% X1 = (p/2^8)*(p/2^8)
			% X1 = (X1 * 3038)/2^16
			% X2 = (-7357 * p)/2^16
			% p = p + (X1+X2+3791)/2^4
			X1 = bitshift(p, -8) * bitshift(p, -8);
			X1 = int32(bitshift(X1 * 3038, -16));
			X2 = int32((-7357 * int32(p))/int32(2^16));
			p = int32(p) + (X1+X2+3791)/2^4;

			% pressure in Pa
			pressure_Pa = p;

			% convert pressure in Pa to kPa
			pressure_kPa = double(p)/1000;

			% Use conversion values found on this page:
			% http://www.endmemo.com/sconvert/kpainhg.php
			% to calculate pressure in other common units.
			pressure_inHg = pressure_kPa * 0.295301;
			pressure_mbar = pressure_kPa * 10;
			pressure_mmHg = pressure_kPa * 7.500617;

			if obj.print_results
				disp(strcat('Pressure: ', num2str(pressure_Pa), 'Pa'));
				disp(strcat('Pressure: ', num2str(pressure_kPa), 'kPa'));
				disp(strcat('Pressure: ', num2str(pressure_inHg), 'inHg'));
				disp(strcat('Pressure: ', num2str(pressure_mbar), 'mbar'));
				disp(strcat('Pressure: ', num2str(pressure_mmHg), 'mmHg'));
			end

			% Return pressre in the desired unit.
			pressure = pressure_kPa;
		end
	end
end