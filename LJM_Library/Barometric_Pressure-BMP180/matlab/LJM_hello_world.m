function result = LJM_hello_world()
	% This function is designed to verify that the the BMP180 acceelrometer is
	% properly connected to the LabJack device.  Essentially, it reads the 
	% Chip-id register from the I2C sensor and makes sure that it received the 
	% proper number of ack bits.

	try
		clc % Clear the MATLAB command window
		clear % Clear the MATLAB variables

		% Make the LJM .NET assembly visible in MATLAB
		ljmAsm = NET.addAssembly('LabJack.LJM');
		ljmType = ljmAsm.AssemblyHandle.GetType('LabJack.LJM');
		ljmConstantsType = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');

		% Create an object to nested class LabJack.LJM.CONSTANTS
		LJM_CONSTANTS = System.Activator.CreateInstance(ljmConstantsType);
		LJM = System.Activator.CreateInstance(ljmType);




	catch e
		showErrorMessage(e)
	end
end

function showErrorMessage(e)
	% showErrorMessage Displays the UD or .NET error from a MATLAB exception.
	if(isa(e, 'NET.NetException'))
		eNet = e.ExceptionObject;
		if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
			disp(['UD Error: ' char(eNet.ToString())]);
		else
			disp(['.NET Error: ' char(eNet.ToString())]);
		end
	else
		disp(e);
	end
	disp(getReport(e));
end

