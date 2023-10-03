//-----------------------------------------
// Project: MEM_ES3
// Purpose: Implement a counter and PWM module
// Author:  Andre
// Version: v0
//-----------------------------------------

module counter_pwm
#(
    W = 8
)
(
    input   logic                       rst_n,  // async reset
    input   logic                       clk,    // clock input
    input   logic                       en,     // count enable
    input   logic                       updn,   // updn=1 --> up, updn=0 --> dn
    input   logic [W-1:0]               thr,    // threshold for pwm generation
    input   logic [W-1:0]               per,    // counter and pwm period
    output  logic [W-1:0]               cnt,    // counter value
    output                              pwm     // pwm output
);

always_ff @( negedge rst_n or posedge clk ) begin : cnt_ff
    if (~rst_n) begin
        cnt <= '0;
    end
    else if (en & updn) begin
        cnt <= cnt + 1'b1;
    end
    else if (en & ~updn) begin
        cnt <= cnt - 1'b1;
    end
end

assign pwm = (cnt < thr) ? 1'b1 : 1'b0;



endmodule