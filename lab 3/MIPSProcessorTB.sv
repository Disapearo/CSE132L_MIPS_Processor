module processor_tb;
	logic ref_clk;
	logic reset;

processor L1(.ref_clk(ref_clk), .reset(reset));

initial begin

	ref_clk = 1;		// 1
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 2
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 3
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 4
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 5
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 6
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 7
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 8
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 9
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 10
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 11
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 12
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 13
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 14
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 15
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 16
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 17
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;		// 18
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

/*
	ref_clk = 0;
	reset = 1;		//Reset
	#100;

	ref_clk = 0;
	reset = 0;
	#100;

	ref_clk = 1;
	reset = 0;
	#100;

	ref_clk = 0;
	reset = 1;		//Reset
	#100;

	ref_clk = 1;
	reset = 1;		//Reset
	#100;

	ref_clk = 0;
	reset = 0;
	#100;
*/
end
endmodule
