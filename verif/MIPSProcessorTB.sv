module processor_tb;
	logic clk;
	logic reset;

processor L1(.clk(clk), .reset(reset));

initial begin

	clk = 1;		// 1
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 2
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 3
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 4
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 5
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 6
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 7
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 8
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 9
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 10
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 11
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 12
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 13
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 14
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 15
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 16
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 17
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 18
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 19
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 20
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 21
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 22
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 23
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 24
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;

	clk = 1;		// 25
	reset = 0;
	#100;

	clk = 0;
	reset = 0;
	#100;


/*
	clk = 0;
	reset = 1;		//Reset
	#100;

	clk = 0;
	reset = 0;
	#100;

*/
end
endmodule
