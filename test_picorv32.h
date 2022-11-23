#ifndef TEST_PICORV32_H_
#define TEST_PICORV32_H_

#include "Vpicorv32_wrapper.h"

class test_picorv32:
	public sc_core::sc_module	{
 public:
	sc_clock clk;

	sc_signal<bool> resetn;
	sc_signal<bool> trap;
	sc_signal<bool> trace_valid;
	sc_signal<vluint64_t> trace_data;

	Vpicorv32_wrapper* top;

	SC_HAS_PROCESS(test_picorv32);
	explicit test_picorv32(sc_core::sc_module_name name):
		clk("clk", 10, SC_NS, 0.5, 3, SC_NS, true)	{
		//top = new Vpicorv32_wrapper{"picorv32_wrapper", "Vpicorv32_wrapper", 0, NULL};
		top = new Vpicorv32_wrapper{"top"};
		top->clk(clk);
		top->resetn(resetn);
		top->trap(trap);
		top->trace_valid(trace_valid);
		top->trace_data(trace_data);

		//SC_THREAD(thread);
	}

	//void thread();

	~test_picorv32()	{
		delete top;
	}
};

#endif	// TEST_PICORV32_H_
