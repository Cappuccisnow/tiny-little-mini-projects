include test.list

export MODELSIM = modelsim.ini

all: clean build run check_log

build: clean
	mkdir -p log
	mkdir -p wave
	vlib work
	vlog -suppress 12110 -f compile.f

run:
	vsim.exe -suppress 12110 -l log/$(TEST_NAME).log -voptargs=+acc -debugDB -c ${TB_NAME} +TESTNAME=$(TEST_NAME) -do "log -r /*; run -all;"
	@mv vsim.wlf wave/$(TEST_NAME).wlf
	@mv vsim.dbg wave/$(TEST_NAME).dbg

check_log:
	@if ! grep -q "Error:" log/$(TEST_NAME).log; then \
		echo "#Simulation for $(TEST_NAME) PASSED."; \
	else \
		echo "#Simulation for $(TEST_NAME) FAILED."; \
	fi;

waveform:
	vsim.exe -i -view wave/$(TEST_NAME).wlf -do wave.do &

clean:
	rm -rf work
	rm -rf *.log
	rm -rf *wlf*
	rm -rf *.ucdb
	rm -rf regress_report.list
	rm -rf *.txt
	rm -rf summary.ucdb
	rm -rf html
	rm -rf coverage

TESTS = tdr_test tcr_test tsr_test null_addr \
        countup_forkjoin_pclk2 countup_forkjoin_pclk4 countup_forkjoin_pclk8 countup_forkjoin_pclk16 \
        countdw_forkjoin_pclk2 countdw_forkjoin_pclk4 countdw_forkjoin_pclk8 countdw_forkjoin_pclk16 \
        countup_pause_countup_pclk2 countdw_pause_countdw_pclk2 \
        countup_reset_countdw_pclk2 countdw_reset_countup_pclk2 \
        countup_reset_load_countdw_pclk2 \
        fake_overflow fake_underflow

regress_core:
	for i in ${TESTS}; do \
	echo $$i ; \
	$(MAKE) "TEST_NAME=$$i"; \
	done
	$(MAKE) report

report:
	@rm -f regress_report.list
	@for i in ${TESTS}; do \
	    echo -n $$i " : " >> regress_report.list; \
	    sed -n -e '/PASSED/p' log/$$i.log >> regress_report.list ; \
	    sed -n -e '/FAILED/p' log/$$i.log >> regress_report.list ; \
	done
	@cat regress_report.list

run_cov:
	mkdir -p coverage
	vlog.exe -suppress 12110 -coveropt 3 +cover=bcestfx -f compile.f
	vsim.exe -suppress 12110 -coverage -l log/cov_log.log -c ${TB_NAME} +TESTNAME=$(TEST_NAME) -novopt -assertdebug -do "coverage save -onexit coverage/${TEST_NAME}.ucdb; log -r /*; run -all"

gencov:
	vcover.exe merge summary.ucdb $(TESTS:%=coverage/%.ucdb)
	vcover.exe report summary.ucdb -file coverage/summary_rp.txt
	vcover.exe report -zeros -details -code bcestfx -All -codeAll summary.ucdb -file coverage/details_rp.txt
	vcover.exe report -html -details -verbose summary.ucdb -htmldir html

regress_cov:
	for i in ${TESTS}; do \
	echo $$i ; \
	$(MAKE) run_cov "TEST_NAME=$$i"; \
	done
	$(MAKE) gencov