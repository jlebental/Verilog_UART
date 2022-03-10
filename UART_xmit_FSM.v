`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2022 12:22:13 PM
// Design Name: 
// Module Name: UART_xmit_FSM
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


module UART_xmit_FSM #(parameter idle = 2'b00, start = 2'b01, 
                                    data = 2'b10, endState = 2'b11)
                         (input wire CLK, RST, dataValid,
                          input wire [7:0] letter_in,
                          output reg out);
    //state and next state don't need to be outputs
    reg [1:0] state, next_state;
    reg [2:0] bit_counter;
    reg [7:0] held_word;
    
    //first block controls state transitions
    always @(posedge CLK)   //just removed posedge RST, asynch reset ability
    begin
        if(RST) 
        begin
            state <= idle;
            bit_counter <= 3'b000;
        end
        else    state <= next_state;
        if(state == data)   bit_counter <= bit_counter + 1;
    end
    
    //second block controls next state logic, bit counter and held word control signals
    always @(state or bit_counter or dataValid)
    begin
        case(state)
            idle:       
                if(dataValid)   next_state = start;
                else            next_state = idle;
            start:      next_state = data;
            data:       
                if(bit_counter == 3'b111)   next_state = endState;
                else                        next_state = data;
            endState:   
            if(dataValid)   next_state = start;
            else            next_state = idle;
        endcase    
    end
    
    //third block controls the output
    always @(state or bit_counter or dataValid)
    begin
        case(state)
            idle:       
            begin
                out = 1'bZ;
                if(dataValid) held_word = letter_in;
            end
            start:      
            begin
                out = 1'b0;
                //bit_counter = 3'b000;
            end
            data:       
            begin
                out = held_word[bit_counter];
            end
            endState:   
            begin
                out = 1'b1;
                //bit_counter = 3'bXXX;
                if(dataValid) held_word = letter_in;
            end
        endcase
    end
endmodule

