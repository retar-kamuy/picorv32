#include "test_picorv32.h"
#include "verilated_vcd_sc.h"

// SC_MODULE_EXPORT(test_picorv32);

int sc_main(int argc, char** argv)	{
	printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
	printf("Recommended: Verilator 4.0 or later.\n");

	Verilated::commandArgs(argc, argv);
	test_picorv32* test = new test_picorv32("test_picorv32");

	// Tracing (vcd)
	VerilatedVcdSc* tfp = NULL;
	const char* flag_vcd = Verilated::commandArgsPlusMatch("vcd");
	if(flag_vcd && 0 == strcmp(flag_vcd, "+vcd"))	{
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdSc;
		test->top->trace(tfp, 99);
		tfp->open("testbench.vcd");
	}

	// Tracing (data bus, see showtrace.py)
	FILE *trace_fd = NULL;
	const char* flag_trace = Verilated::commandArgsPlusMatch("trace");
	if(flag_trace && 0 == strcmp(flag_trace, "+trace"))	{
		trace_fd = fopen("testbench.trace", "w");
	}

	int t = 0;
	while(!Verilated::gotFinish())	{
		if(t > 200)
			test->resetn = 1;
		sc_start(1, SC_NS);
		if(tfp) tfp->dump(t);
		if (trace_fd && test->clk && test->top->trace_valid) fprintf(trace_fd, "%9.9lx\n", test->top->trace_data);
		t += 5;
	}

	if(tfp) tfp->close();

	printf("done, time = %d\n", sc_time_stamp());
	delete test;
	return 0;
}

// void test_picorv32::thread(void)   {
// 	a.write(0);
// 	b.write(0);
// 	wait(10, SC_NS);
// 	cout << "time = " << sc_time_stamp()
// 		 << "sum = " << sum.read() << ", carry = " << carry.read() << endl;
// 
// 	a.write(0);
// 	b.write(1);
// 	wait(10, SC_NS);
// 	cout << "time = " << sc_time_stamp()
// 		 << "sum = " << sum.read() << ", carry = " << carry.read() << endl;
// 
// 	a.write(1);
// 	b.write(0);
// 	wait(10, SC_NS);
// 	cout << "time = " << sc_time_stamp()
// 		 << "sum = " << sum.read() << ", carry = " << carry.read() << endl;
// 
// 	a.write(1);
// 	b.write(1);
// 	wait(10, SC_NS);
// 	cout << "time = " << sc_time_stamp()
// 		 << "sum = " << sum.read() << ", carry = " << carry.read() << endl;
// 	wait(10, SC_NS);
// 	sc_stop();
// }
