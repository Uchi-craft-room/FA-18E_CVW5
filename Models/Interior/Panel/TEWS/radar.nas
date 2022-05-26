# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Can be set by user code.
# + level-lbs       - OUTPUT ONLY property, do not try to set
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity 
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script
# + out-of-fuel       - boolean, set by this code.

# ==================================== timer stuff ===========================================

# set the update period

UPDATE_PERIOD = 0.3;

# set the timer for the selected function

registerTimer = func {
	
    settimer(arg[0], UPDATE_PERIOD);

} # end function 

# ================================== TACAN  ===================================


range_control_node = props.globals.getNode("instrumentation/radar/range-control", 1);
range_node = props.globals.getNode("instrumentation/radar/range", 1);
wx_range_node = props.globals.getNode("instrumentation/wxradar/range", 1);
x_shift_node=  props.globals.getNode("instrumentation/tacan/display/x-shift", 1 );
x_shift_scaled_node=  props.globals.getNode("instrumentation/tacan/display/x-shift-scaled",1);
y_shift_node=  props.globals.getNode("instrumentation/tacan/display/y-shift", 1 );
y_shift_scaled_node=  props.globals.getNode("instrumentation/tacan/display/y-shift-scaled",1);
display_control_node = props.globals.getNode("instrumentation/display-unit/control", 1);
radar_control_node = props.globals.getNode("instrumentation/radar/mode-control", 1);
radar_range_node = props.globals.getNode("instrumentation/radar/radar-range", 1);
range_tanker0_node = props.globals.getNode("ai/models/tanker[0]/radar/range-nm", 1);
range_tanker1_node = props.globals.getNode("ai/models/tanker[1]/radar/range-nm", 1);
range_tanker2_node = props.globals.getNode("ai/models/tanker[2]/radar/range-nm", 1);
range_tanker3_node = props.globals.getNode("ai/models/tanker[3]/radar/range-nm", 1);
range_tanker4_node = props.globals.getNode("ai/models/tanker[4]/radar/range-nm", 1);
range_tanker0_shift_node = props.globals.getNode("ai/models/tanker[0]/radar/range-nm-shift", 1);
range_tanker1_shift_node = props.globals.getNode("ai/models/tanker[1]/radar/range-nm-shift", 1);
range_tanker2_shift_node = props.globals.getNode("ai/models/tanker[2]/radar/range-nm-shift", 1);
range_tanker3_shift_node = props.globals.getNode("ai/models/tanker[3]/radar/range-nm-shift", 1);
range_tanker4_shift_node = props.globals.getNode("ai/models/tanker[4]/radar/range-nm-shift", 1);
range_multiplayer0_node = props.globals.getNode("ai/models/multiplayer[0]/radar/range-nm", 1);
range_multiplayer1_node = props.globals.getNode("ai/models/multiplayer[1]/radar/range-nm", 1);
range_multiplayer2_node = props.globals.getNode("ai/models/multiplayer[2]/radar/range-nm", 1);
range_multiplayer3_node = props.globals.getNode("ai/models/multiplayer[3]/radar/range-nm", 1);
range_multiplayer4_node = props.globals.getNode("ai/models/multiplayer[4]/radar/range-nm", 1);
range_multiplayer0_shift_node = props.globals.getNode("ai/models/multiplayer[0]/radar/range-nm-shift", 1);
range_multiplayer1_shift_node = props.globals.getNode("ai/models/multiplayer[1]/radar/range-nm-shift", 1);
range_multiplayer2_shift_node = props.globals.getNode("ai/models/multiplayer[2]/radar/range-nm-shift", 1);
range_multiplayer3_shift_node = props.globals.getNode("ai/models/multiplayer[3]/radar/range-nm-shift", 1);
range_multiplayer4_shift_node = props.globals.getNode("ai/models/multiplayer[4]/radar/range-nm-shift", 1);

range_control_node.setIntValue(3); 
range_node.setIntValue(40); 
wx_range_node.setIntValue(40); 
x_shift_node.setDoubleValue(0);
x_shift_scaled_node.setDoubleValue(0);
y_shift_node.setDoubleValue(0);
y_shift_scaled_node.setDoubleValue(0);
display_control_node.setIntValue(1);
radar_control_node.setIntValue(1);
radar_range_node.setDoubleValue(0.00255);
range_tanker0_node.setDoubleValue(0);
range_tanker1_node.setDoubleValue(0);
range_tanker2_node.setDoubleValue(0);
range_tanker3_node.setDoubleValue(0);
range_tanker4_node.setDoubleValue(0);
range_tanker0_shift_node.setDoubleValue(0);
range_tanker1_shift_node.setDoubleValue(0);
range_tanker2_shift_node.setDoubleValue(0);
range_tanker3_shift_node.setDoubleValue(0);
range_tanker4_shift_node.setDoubleValue(0);
range_multiplayer0_node.setDoubleValue(0);
range_multiplayer1_node.setDoubleValue(0);
range_multiplayer2_node.setDoubleValue(0);
range_multiplayer3_node.setDoubleValue(0);
range_multiplayer4_node.setDoubleValue(0);
range_multiplayer0_shift_node.setDoubleValue(0);
range_multiplayer1_shift_node.setDoubleValue(0);
range_multiplayer2_shift_node.setDoubleValue(0);
range_multiplayer3_shift_node.setDoubleValue(0);
range_multiplayer4_shift_node.setDoubleValue(0);

var scale = 2.55;	

# Lib functions
pow2 = func(e) { return e ? 2 * pow2(e - 1) : 1 } # calculates 2^e


adjustRange = func{

		range = range_node.getValue();
		range_control = range_control_node.getValue();

		range = 5 * pow2( range_control );

#  	print ( "range " , range);


		range_node.setIntValue( range );
		wx_range_node.setIntValue( range );

    scale = 1.275 * pow2 ( 7 - range_control ) * 0.1275;
	  scale = sprintf( "%2.3f" , scale );

#		print ( "scale " , scale );

} # end function adjustRange

scaleShift = func {

	x_shift_scaled_node.setDoubleValue( x_shift_node.getValue() * scale );
	y_shift_scaled_node.setDoubleValue( y_shift_node.getValue() * scale );
        radar_range_node.setDoubleValue( 0.102 / range_node.getValue() );
        range_tanker0_shift_node.setDoubleValue( radar_range_node.getValue() * range_tanker0_node.getValue() );
        range_tanker1_shift_node.setDoubleValue( radar_range_node.getValue() * range_tanker1_node.getValue() );
        range_tanker2_shift_node.setDoubleValue( radar_range_node.getValue() * range_tanker2_node.getValue() );
        range_tanker3_shift_node.setDoubleValue( radar_range_node.getValue() * range_tanker3_node.getValue() );
        range_tanker4_shift_node.setDoubleValue( radar_range_node.getValue() * range_tanker4_node.getValue() );
        range_multiplayer0_shift_node.setDoubleValue( radar_range_node.getValue() * range_multiplayer0_node.getValue() );
        range_multiplayer1_shift_node.setDoubleValue( radar_range_node.getValue() * range_multiplayer1_node.getValue() );
        range_multiplayer2_shift_node.setDoubleValue( radar_range_node.getValue() * range_multiplayer2_node.getValue() );
        range_multiplayer3_shift_node.setDoubleValue( radar_range_node.getValue() * range_multiplayer3_node.getValue() );
        range_multiplayer4_shift_node.setDoubleValue( radar_range_node.getValue() * range_multiplayer4_node.getValue() );

#	print ( "x-shift-scaled " , x_shift_scaled_node.getValue() );
#	print ( "y-shift-scaled " , y_shift_scaled_node.getValue() );
	registerTimer( scaleShift );
						
} # end func scaleshift


scaleShift();	

setlistener( range_control_node , adjustRange );


