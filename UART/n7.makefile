SRC = ../clkUnit/clkUnit.vhd \
      ../UART/compteur16.vhd \
      RxUnit.vhd \
      testRxUnit.vhd

# for simulation:
TEST = testRxUnit
# duration (to adjust if necessary)
TIME = 12000ns
PLOT = output
