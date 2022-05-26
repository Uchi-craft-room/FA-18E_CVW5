# set the timer for the selected function

var UPDATE_PERIOD = 0;
var freq = 0;
var formatted = 0;

var digit1 = 0;
var digit2 = 0;
var digit3 = 0;
var digit4 = 0;
var digit5 = 0;

var gps_display = [];

var instrumenttimer = func {
    settimer(func {
        radiodisplay();
	instrumenttimer()
    }, UPDATE_PERIOD);
}

# =============================== end timer stuff ===========================================

# ==================== Radio Frequency Display =========================
var displaysegments = func (radio, selected) {
    var freq=getprop("/instrumentation/"~radio~"/frequencies/"~selected~"-mhz");
    var formatted=sprintf("%.02f",freq);

    digit1=substr(formatted,0,1);
    digit2=substr(formatted,1,1);
    digit3=substr(formatted,2,1);
    digit4=substr(formatted,4,1);
    digit5=substr(formatted,5,1);

    setprop("instrumentation/"~radio~"/"~selected~"/digit1",digit1);
    setprop("instrumentation/"~radio~"/"~selected~"/digit2",digit2);
    setprop("instrumentation/"~radio~"/"~selected~"/digit3",digit3);
    setprop("instrumentation/"~radio~"/"~selected~"/digit4",digit4);
    setprop("instrumentation/"~radio~"/"~selected~"/digit5",digit5);
}

var radiodisplay = func() {
    displaysegments ("nav[0]", "selected");
    displaysegments ("nav[0]", "standby");

    displaysegments ("comm[0]", "selected");
    displaysegments ("comm[0]", "standby");

    displaysegments ("comm[1]", "selected");
    displaysegments ("comm[1]", "standby");
}

####################### Initialise ##############################################

initialize = func {

    ### Initialise Radios ###
    props.globals.getNode("/instrumentation/uhf/commvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kns80/navvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kx155a/commvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kx155a/navvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kt-70/inputs/func-knob", 1).setDoubleValue(0);
    props.globals.getNode("/instrumentation/dme/switch-position", 1).setDoubleValue(0);

    instrumenttimer();
    # Finished Initialising
    print ("Instruments : initialised");
    var initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/fdm-initialized",initialize);


######################### JFS READY ############################################

props.globals.getNode("/controls/APU/ready", 0).setDoubleValue(0.0);
setlistener("/controls/APU/fire-switch",func{interpolate("/controls/APU/ready",1,10)});

######################### N1 RPM ##########################################

setlistener("/engines/engine[0]/n1",func{interpolate("/instrumentation/rpm/engine-rh",getprop("/engines/engine[0]/n1")/2+50,1)});
setlistener("/engines/engine[1]/n1",func{interpolate("/instrumentation/rpm/engine-lh",getprop("/engines/engine[1]/n1")/2+50,1)});

######################### REFUEL HATCH ############################################

props.globals.getNode("/consumables/fuel/slip-way-door", 0).setIntValue(0);
props.globals.getNode("/consumables/fuel/refuel-hatch-pos", 0).setDoubleValue(0.0);

setlistener("/consumables/fuel/slip-way-door",func{interpolate("/consumables/fuel/refuel-hatch-pos",getprop("/consumables/fuel/slip-way-door"),2)});


#########################  SWITCH SETTING ############################################

setprop("/controls/switches/taxi-lights",0);
props.globals.getNode("/instrumentation/fuelgauge/selector",0).setIntValue(1);
setprop("instrumentation/fric-knob",0.01);

#########################  FUEL TANK SETTING ############################################

props.globals.getNode("/consumables/fuel/ext-tank-ctr-selected",0).setIntValue(1);
props.globals.getNode("/consumables/fuel/ext-tank-wing-selected",0).setIntValue(1);

#
setlistener("/consumables/fuel/tank/level-lbs",func{interpolate("/consumables/fuel/total-internal-fuel-lbs",getprop("/consumables/fuel/tank/level-lbs")+getprop("/consumables/fuel/tank[1]/level-lbs")+getprop("/consumables/fuel/tank[2]/level-lbs")+getprop("/consumables/fuel/tank[3]/level-lbs")+getprop("/consumables/fuel/tank[4]/level-lbs"),1)});


#
setlistener("/consumables/fuel/tank[5]/selected",func(em){
       var epty = em.getValue();
       setprop("/consumables/fuel/tank-selector",epty);
});

#
setlistener("/consumables/fuel/tank-selector", func(sw){
       var pos0 = sw.getValue()*7;
       var pos3 = sw.getValue()+sw.getValue()+3;
       var pos4 = sw.getValue()+sw.getValue()+4;
       setprop("/consumables/fuel/tank["~pos0~"]/selected",1);
       setprop("/consumables/fuel/tank["~pos3~"]/selected",1);
       setprop("/consumables/fuel/tank["~pos4~"]/selected",1);
});

#FEED TANK
setlistener("/consumables/fuel/tank[0]/selected",func(tn){
       var tnk1 = 1 - tn.getValue() + getprop("/consumables/fuel/tank-selector")*6;
       var tnk2 = 2 - tn.getValue()*2 + getprop("/consumables/fuel/tank-selector")*5;
       setprop("/consumables/fuel/tank-lower1",tnk1);
       setprop("/consumables/fuel/tank-lower2",tnk2);
});


setlistener("/consumables/fuel/tank-lower1", func(la){
       var pos1 = la.getValue();
       setprop("/consumables/fuel/tank["~pos1~"]/selected",1);
});

setlistener("/consumables/fuel/tank-lower2", func(lb){
       var pos2 = lb.getValue();
       setprop("/consumables/fuel/tank["~pos2~"]/selected",1);
});
#
setprop("/consumables/fuel/tank[0]/selected",0);
setprop("/consumables/fuel/tank[1]/selected",0);
setprop("/consumables/fuel/tank[2]/selected",0);
setprop("/consumables/fuel/tank[3]/selected",0);
setprop("/consumables/fuel/tank[4]/selected",0);

######################### CANOPY PARAMETOR ##########################################
#splash
setlistener("/engines/engine[0]/n1",func{
             interpolate("/environment/aircraft-effects/splash-vector-x",getprop("/velocities/airspeed-kt")*-0.005,1)});
props.globals.getNode("/environment/aircraft-effects/splash-vector-y", 0).setIntValue(0.01);
props.globals.getNode("/environment/aircraft-effects/splash-vector-z", 0).setIntValue(-1);

#TAT

setlistener("/engines/engine[0]/n1",func{
             interpolate("/environment/total-air-temperature-degc",getprop("/environment/temperature-degc")+ ((getprop("/environment/temperature-degc")+ 273) * 0.2 * (getprop("/velocities/mach") * getprop("/velocities/mach"))),5)});

#frost
setprop("/environment/windowheat-level", 1);
setlistener("/engines/engine[0]/n1",func{
             interpolate("/environment/aircraft-effects/frost-level",(getprop("/environment/total-air-temperature-degc")+10)*getprop("/environment/windowheat-level")*-0.03,1)});
setlistener("/controls/anti-ice/window-heat",func{
             interpolate("/environment/windowheat-level",1-getprop("/controls/anti-ice/window-heat")*0.9,10)});

######################### HUD NAV BEARING ############################################

props.globals.getNode("/instrumentation/nav/nav-needle-error-deg", 0).setDoubleValue(0.0);

setlistener("/engines/engine[0]/n1",func{interpolate("/instrumentation/nav/nav-needle-error-deg",getprop("/instrumentation/nav/heading-deg")-getprop("/orientation/heading-deg"),0.01)});

######################### HUD TACAN BEARING ############################################

props.globals.getNode("/instrumentation/tacan/tacan-needle-error-deg", 0).setDoubleValue(0.0);

setlistener("/engines/engine[0]/n1",func{interpolate("instrumentation/tacan/tacan-needle-error-deg",getprop("/instrumentation/tacan/indicated-bearing-true-deg")-getprop("/orientation/heading-deg"),0.01)});


######################### LAUNCHBAR RETRUCT ############################################

setlistener("/gear/launchbar/strop",func{interpolate("/controls/gear/launchbar",0,0.1)});

######################### EGT degf to degc ############################################

props.globals.getNode("/engines/engine[0]/egt-degc", 0).setDoubleValue(0.0);
props.globals.getNode("/engines/engine[1]/egt-degc", 0).setDoubleValue(0.0);
setlistener("/engines/engine[0]/n1",func{interpolate("/engines/engine[0]/egt-degc",getprop("/engines/engine[0]/egt-degf")/1.8-32/1.8,0.01)});
setlistener("/engines/engine[1]/n1",func{interpolate("/engines/engine[1]/egt-degc",getprop("/engines/engine[1]/egt-degf")/1.8-32/1.8,0.01)});
