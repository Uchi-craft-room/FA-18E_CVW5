# TACAN
# ------------- 
var nav1_back = 0;
setlistener( "instrumentation/tacan/switch-position", func {nav1_freq_update();} );

var tc              = props.globals.getNode("instrumentation/tacan/");
var tc_sw_pos       = tc.getNode("switch-position");
var tc_freq         = tc.getNode("frequencies");
var tc_true_hdg     = props.globals.getNode("instrumentation/tacan/indicated-bearing-true-deg");
var tc_mag_hdg      = props.globals.getNode("sim/model/A-10/instrumentation/tacan/indicated-bearing-mag-deg");
var tcn_btn         = props.globals.getNode("instrumentation/tacan/switch-position");
var tcn_ident       = props.globals.getNode("instrumentation/tacan/ident");


var tacan_XYtoggle = func {
	var xy_sign = tc_freq.getNode("selected-channel[4]");
	var s = xy_sign.getValue();
	if ( s == "X" ) {
		xy_sign.setValue( "Y" );
	} else {
		xy_sign.setValue( "X" );
	}
}

var tacan_tenth_adjust = func {
	var tenths = getprop( "instrumentation/tacan/frequencies/selected-channel[2]" );
	var hundreds = getprop( "instrumentation/tacan/frequencies/selected-channel[1]" );
	var value = (10 * tenths) + (100 * hundreds);
	var adjust = arg[0];
	var new_value = value + adjust;
	var new_hundreds = int(new_value/100);
	var new_tenths = (new_value - (new_hundreds*100))/10;
	setprop( "instrumentation/tacan/frequencies/selected-channel[1]", new_hundreds );
	setprop( "instrumentation/tacan/frequencies/selected-channel[2]", new_tenths );
}
