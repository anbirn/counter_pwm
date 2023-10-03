`timescale 10ns/10ns
module tb_counter_pwm();

// (1) DUT wiring
    localparam W = 5;
    logic                       rst_n;  // async reset
    logic                       clk;    // clock input
    logic                       en;     // count enable
    logic                       updn;   // updn=1 --> up, updn=0 --> dn
    logic [W-1:0]               thr;    // threshold for pwm generation
    logic [W-1:0]               per;    // counter and pwm period
    logic [W-1:0]               cnt;    // counter value
    logic                       pwm;    // pwm output

// (2) DUT instance
counter_pwm # (.W (5)) dut (.*);

// (2a) Covergroups
localparam cnt_max = 2**W -1;
localparam cnt_mid = 2**(W-1);
covergroup cnt_cov @ (posedge clk);
    option.per_instance = 1; // This allows each instance of the coverage group to be sampled separately
    coverpoint en;
    coverpoint updn;
    coverpoint thr {
        bins thr_zero = {'0};
        bins thr_max  = {cnt_max};
        bins thr_mid  = {cnt_mid};
        option.auto_bin_max = 10;
    }
    coverpoint per {
        bins per_zero = {'0};
        bins per_max  = {cnt_max};
        bins per_mid  = {cnt_mid};
        bins per_low[5]  = {['0 : cnt_mid]};
        bins per_high[5]  = {[cnt_mid : $]};
        option.auto_bin_max = 10;
    }
    coverpoint cnt {
        bins cnt_zero = {'0};
        bins cnt_max  = {cnt_max};
        bins cnt_mid  = {cnt_mid};
        bins cnt_low[5]  = {['0 : cnt_mid]};
        bins cnt_high[5]  = {[cnt_mid : $]};
        bins cnt_overflow = (cnt_max => '0);  // counter overflows
        bins cnt_underlow = (cnt_max => '0);  // counter underflows
    }

    // Cross coverage
    cross en, updn;
    cross thr, per;
endgroup

// (3) DUT stimuli
int             error_cnt   = 0;
logic           run_sim     = 1'b1;
logic [W-1:0]   cnt_temp    = '0;

cnt_cov cnt_cov_0 = new();

initial begin
    clk = 1'b0;
    while (run_sim) begin
        #10ns;
        clk = ~clk;
    end
end

initial begin
    $display("-------------------------------------");
    $display("tb_pwm_counter started");
    $display("-------------------------------------");
    // covergoup instance
    
    cnt_cov_0.start();

    rst_n   = 1'b0;
    en      = 1'b0;
    updn    = 1'b0;
    // --- Set per to all ones.
    per     = '1;
    thr     = '0;

    #10ns;
    // --- Check that the active low reset resets the counter to ‘0.
    assert (cnt == '0) else begin
        error_cnt++;
        $error ("cnt is not zero in POR");
    end
    #100ns;
    rst_n   = 1'b1;

    // --- Check that the counter is incremented when en == 1’b1 and down == 1’b0.
    en = 1'b0;
    #1us;
    @ (negedge clk);
    en      = 1'b1;
    updn    = 1'b1;
    repeat(10) begin
        cnt_temp = cnt;
        @ (negedge clk);
        assert (cnt > cnt_temp) else begin
            error_cnt++;
            $error("Counter does not increment. en=%d, updn =%d, cnt = %d", en, updn, cnt);
        end
    end
    // --- Check that the counter is decremented when en == 1’b1 and down == 1’b1.
    en = 1'b0;
    #1us;
    @ (negedge clk);
    en      = 1'b1;
    updn    = 1'b0;
    repeat(10) begin
        cnt_temp = cnt;
        @ (negedge clk);
        assert (cnt < cnt_temp) else begin
            error_cnt++;
            $error("Counter does not decrement. en=%d, updn =%d, cnt = %d", en, updn, cnt);
        end
    end
    // --- Increment the counter 50 times.
    en = 1'b0;
    #1us;
    @ (negedge clk);
    en      = 1'b1;
    updn    = 1'b1;
    cnt_temp = cnt;
    repeat(50) @ (negedge clk);
    // --- Decrement the counter 100 times.
    en = 1'b0;
    #1us;
    @ (negedge clk);
    en      = 1'b1;
    updn    = 1'b0;
    repeat(100) @ (negedge clk);
    // --- Check the PWM output for 
    // --- thr is all zeros
    en = 1'b0;
    #1us;
    @ (negedge clk);
    thr     = '0;
    en      = 1'b1;
    updn    = 1'b1;
    repeat(100) @ (negedge clk);
    // --- thr is all ones
    en = 1'b0;
    #1us;
    @ (negedge clk);
    thr     = '1;
    en      = 1'b1;
    updn    = 1'b1;
    repeat(100) @ (negedge clk);
    // --- thr is one
    en = 1'b0;
    #1us;
    @ (negedge clk);
    thr     = 1'b1;
    en      = 1'b1;
    updn    = 1'b1;
    repeat(100) @ (negedge clk);
    // --- thr is 5’b10000
    en = 1'b0;
    #1us;
    @ (negedge clk);
    thr     = 5'b10000;
    en      = 1'b1;
    updn    = 1'b1;
    repeat(100) @ (negedge clk);

    #1us;
    run_sim = 1'b0;
    $display("-------------------------------------");
    if (error_cnt == 0) begin
        $display("Pass: tb_pwm_counter finished w/o errors");
    end
    else begin
        $display("FAIL: tb_pwm_counter finished with %d errors", error_cnt);
    end
    cnt_cov_0.start();
    cnt_cov_0.get_coverage();
    $display("-------------------------------------");
end

endmodule