`timescale 1ns/1ps  
module tb_voting; 
reg clock; 
reg reset; 
reg mode; 
reg [3:0] admin_code; 
reg c1, c2, c3, c4; 
wire [7:0] leds; 
wire tamper_error; 
wire invalid_vote_flag; 
wire [3:0] winner_led; 
wire tie_flag; 
digitalVotingMachineFSM dut( 
 .clock(clock), 
 .reset(reset), 
 .mode(mode), 
 .admin_code(admin_code), 
 .cand1_button(c1), 
 .cand2_button(c2), 
 .cand3_button(c3), 
 .cand4_button(c4), 
 .leds(leds), 
 .tamper_error(tamper_error), 
 .invalid_vote_flag(invalid_vote_flag), 
 .winner_led(winner_led), 
 .tie_flag(tie_flag) 
); 
// Clock 
always #5 clock = ~clock; 
initial begin 
 $dumpfile("dump.vcd"); 
 $dumpvars(0, tb_voting); 
end 
// -------- TASKS -------- 
task vote1; begin c1=1; #120; c1=0; #50; end endtask 
task vote2; begin c2=1; #120; c2=0; #50; end endtask 
task vote3; begin c3=1; #120; c3=0; #50; end endtask 
task vote4; begin c4=1; #120; c4=0; #50; end endtask 
task invalid_vote; begin 
 c1=1; c2=1; 
 #120; 
 c1=0; c2=0; 
 #50; 
end endtask 
initial begin 
 clock=0; reset=1; mode=0; 
 admin_code=0; 
 c1=0; c2=0; c3=0; c4=0; 
 #20 reset=0; 
 // -------- NORMAL VOTING -------- 
 vote1; vote1; vote1; // c1 = 3 
 vote2; // c2 = 1 
 vote3; vote3; // c3 = 2 
 vote4; // c4 = 1 
 // -------- INVALID VOTE -------- 
 invalid_vote; 
 // -------- WRONG ADMIN -------- 
 #50; 
 mode=1; 
 vote1; 
 vote2; 
 vote3; 
 vote4; 
 admin_code=4'b0000; 
 #100; 
 // -------- CORRECT ADMIN (SHOW WINNER) -------- 
 admin_code=4'b1010; 
 #100; 
 
 mode=1; 
 admin_code=4'b1010; 
 vote1; 
 vote2; 
 vote3; 
 vote4; 
 #200; 
 $finish; 
end 
endmodule