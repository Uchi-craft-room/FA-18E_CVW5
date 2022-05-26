# =====
# WING FOLDING
# =====

props.globals.getNode("surface-positions/wing-fold", 0).setDoubleValue(0.0);
setlistener("controls/flight/wing-fold",func{interpolate("surface-positions/wing-fold",getprop("controls/flight/wing-fold"),3)});
