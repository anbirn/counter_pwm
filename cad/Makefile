# Define your source files and simulation top module
RTL = rtl.f
TB   = tb.f
TOP_MODULE = tb_counter_pwm

# Simulation options
SIM_OPTIONS = -timescale "1ns/10ps" -access +rc -sv -64bit

# XSIM executable
XSIM = xrun

# Coverage options
COV_OPTIONS = -coverage all 
COV_OPTIONS += -covoverwrite

# Simulation target

gui: 
	$(XSIM) -gui $(SIM_OPTIONS) \
    $(COV_OPTIONS) \
    -f $(RTL) \
    -f $(TB) \
    -top $(TOP_MODULE) \
    -input restore.tcl


sim: 
	$(XSIM) $(SIM_OPTIONS) \
	$(COV_OPTIONS) \
	-f $(RTL) \
	-f $(TB) \
	-top $(TOP_MODULE)

# Clean generated files
clean:
	rm -rf *.log *.history *.dat *.key *.pb *.svf xcelium.d .simvision/ waves.shm cov_work

.PHONY: sim clean

