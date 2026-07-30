//////////////////////////////////////////////////////////////////////////////////
// SECURE DIGITAL VOTING MACHINE
// Subject: CS2074 – Computer Organization Laboratory
//
// Submitted By:
// Ayusmati Panda(124cs0034)
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08:34:39 04/09/2026
// Design Name:
// Module Name: digitalVotingMachineFSM
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
// ================= BUTTON CONTROL =================
module buttonControl(
input clock,
input reset,
input button,
output reg valid_vote
);
reg [3:0] counter;
always @(posedge clock) begin
if(reset)
counter <= 0;
else if(button && counter < 10)
counter <= counter + 1;
else if(!button)
counter <= 0;
end
always @(posedge clock) begin
if(reset)
valid_vote <= 0;
else if(counter == 10)
valid_vote <= 1;
else
valid_vote <= 0;
end
endmodule
// ================= VOTE LOGGER =================
module voteLogger(
input clock,
input reset,
input mode,
input cand1_vote_valid,
input cand2_vote_valid,
input cand3_vote_valid,
input cand4_vote_valid,
output reg [7:0] cand1_vote_recvd,
output reg [7:0] cand2_vote_recvd,
output reg [7:0] cand3_vote_recvd,
output reg [7:0] cand4_vote_recvd
);
always @(posedge clock) begin
if(reset) begin
cand1_vote_recvd <= 0;
cand2_vote_recvd <= 0;
cand3_vote_recvd <= 0;
cand4_vote_recvd <= 0;
end
else if(mode == 0) begin
if(cand1_vote_valid)
cand1_vote_recvd <= cand1_vote_recvd + 1;
else if(cand2_vote_valid)
cand2_vote_recvd <= cand2_vote_recvd + 1;
else if(cand3_vote_valid)
cand3_vote_recvd <= cand3_vote_recvd + 1;
else if(cand4_vote_valid)
cand4_vote_recvd <= cand4_vote_recvd + 1;
end
end
endmodule
// ================= MODE CONTROL =================
module modeControl(
input clock,
input reset,
input mode,
input cand1_button,
input cand2_button,
input cand3_button,
input cand4_button,
input [7:0] cand1_vote_recvd,
input [7:0] cand2_vote_recvd,
input [7:0] cand3_vote_recvd,
input [7:0] cand4_vote_recvd,
output reg [7:0] leds
);
always @(posedge clock or posedge reset) begin
if(reset)
leds <= 0;
else if(mode == 0)
leds <= 8'hFF; // voting indication
else begin
if(cand1_button)
leds <= cand1_vote_recvd;
else if(cand2_button)
leds <= cand2_vote_recvd;
else if(cand3_button)
leds <= cand3_vote_recvd;
else if(cand4_button)
leds <= cand4_vote_recvd;
else
leds <= 0;
end
end
endmodule
// ================= WINNER LOGIC =================
module winnerLogic(
input [7:0] c1, c2, c3, c4,
output reg [3:0] winner,
output reg tie
);
reg [7:0] max;
integer count;
always @(*) begin
// Find max
max = c1;
if(c2 > max) max = c2;
if(c3 > max) max = c3;
if(c4 > max) max = c4;
// Count how many equal to max
count = 0;
if(c1 == max) count = count + 1;
if(c2 == max) count = count + 1;
if(c3 == max) count = count + 1;
if(c4 == max) count = count + 1;
tie = (count > 1);
winner = 4'b0000;
if(count == 1) begin
if(c1 == max) winner = 4'b0001;
else if(c2 == max) winner = 4'b0010;
else if(c3 == max) winner = 4'b0100;
else if(c4 == max) winner = 4'b1000;
end
end
endmodule
// ================= TOP MODULE =================
module digitalVotingMachineFSM (
input clock,
input reset,
input mode,
input [3:0] admin_code,
input cand1_button,
input cand2_button,
input cand3_button,
input cand4_button,
output [7:0] leds,
output reg tamper_error,
output reg invalid_vote_flag,
output reg [3:0] winner_led,
output tie_flag
);
parameter ADMIN_PASS = 4'b1010;
reg admin_ok;
// -------- ADMIN AUTH --------
always @(posedge clock or posedge reset) begin
if(reset) begin
admin_ok <= 0;
tamper_error <= 0;
end
else if(mode) begin
if(admin_code == ADMIN_PASS) begin
admin_ok <= 1;
tamper_error <= 0;
end else begin
admin_ok <= 0;
tamper_error <= 1;
end
end
end
// -------- BUTTON SYNC --------
reg b1,b2,b3,b4;
always @(posedge clock) begin
b1<=cand1_button;
b2<=cand2_button;
b3<=cand3_button;
b4<=cand4_button;
end
// -------- INVALID DETECTION --------
wire [2:0] count = b1+b2+b3+b4;
wire single = (count==1);
always @(posedge clock)
invalid_vote_flag <= (count > 1);
// -------- DEBOUNCE --------
wire v1,v2,v3,v4;
buttonControl bc1(clock,reset,b1,v1);
buttonControl bc2(clock,reset,b2,v2);
buttonControl bc3(clock,reset,b3,v3);
buttonControl bc4(clock,reset,b4,v4);
// -------- LOGGER --------
wire [7:0] c1,c2,c3,c4;
voteLogger logger(
clock,reset,mode,
v1&single,v2&single,v3&single,v4&single,
c1,c2,c3,c4
);
// -------- WINNER CONTROL --------
wire [3:0] winner_raw;
wire tie_raw;
winnerLogic win(c1,c2,c3,c4,winner_raw,tie_raw);
// Show ONLY when admin is correct AND mode=1
assign tie_flag = (mode && admin_ok) ? tie_raw : 1'b0;
always @(*) begin
if(mode && admin_ok)
winner_led = winner_raw;
else
winner_led = 4'b0000;
end
// -------- DISPLAY --------
modeControl disp(
clock,reset,mode & admin_ok,
b1,b2,b3,b4,
c1,c2,c3,c4,
leds
);
endmodule