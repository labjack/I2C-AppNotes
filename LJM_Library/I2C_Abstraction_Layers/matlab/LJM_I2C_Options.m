classdef LJM_I2C_Options
	% LabJack I2C Configuration options
	properties
		% https://labjack.com/support/datasheets/t7/digital-io/i2c
		reset_at_start
		no_stop_when_restarting
		disable_clock_stretching
	end

	methods
		function obj=LJM_I2C_Options(reset_at_start, no_stop_when_restarting, disable_clock_stretching)
			obj.reset_at_start = reset_at_start;
			obj.no_stop_when_restarting = no_stop_when_restarting;
			obj.disable_clock_stretching = disable_clock_stretching;
		end
		function options_val=calculate(obj)
			% This function calculates the options integer that needs to get
			% passed to the LJM Library to configure the LabJack's I2C bus.
			options_val = 0;

			% These conditional statements build the options bitmask.
			if obj.reset_at_start
				options_val = options_val + 1;
			end
			if obj.no_stop_when_restarting
				options_val = options_val + 2;
			end
			if obj.disable_clock_stretching
				options_val = options_val + 4;
			end
		end
	end
end