`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2022 12:24:18 PM
// Design Name: 
// Module Name: CLK_Divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CLK_Divider #(parameter count = 13'b1010001011001)   //10417 is the proper value for the BAUD rate
                    (input wire CLK, RST,
                     output reg out);
    reg [13:0] counter_val;
    always @(posedge CLK,  posedge RST)
    begin
        if(RST)
        begin
            counter_val <= 0;
            out <= 1'b0;
        end
        else if(counter_val == count)
        begin
            counter_val <= 0;
            out <= 1'b1;
        end
        else
        begin
            counter_val <= counter_val + 1;
            out <= 1'b0;
        end
    end
endmodule
