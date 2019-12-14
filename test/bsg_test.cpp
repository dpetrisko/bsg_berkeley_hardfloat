#include <iostream>
#include <stdlib.h>

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vtestbench.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(VM_TRACE);

    Vtestbench *tb = new Vtestbench;

#if VM_TRACE
    VerilatedVcdC* wf = new VerilatedVcdC;
    tb->trace(wf, 10);
    wf->open("dump.vcd");
#endif

//while (!Verilated::gotFinish()) {
        tb->clk_i = 1;
        tb->reset_i = 1;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->reset_i = 0;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
        tb->eval();
        tb->clk_i = ~tb->clk_i;
//    } 
    
    exit(EXIT_SUCCESS);
}
