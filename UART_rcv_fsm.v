`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/23/2022 12:30:01 PM
// Design Name: 
// Module Name: UART_rcv_fsm
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


module UART_rcv_fsm #(parameter idle = 2'b00, start = 2'b01,
                                data = 2'b10, stop = 2'b11)
                     (input wire CLK, RST, ser_in,
                      output reg [7:0] par_out,
                      output reg data_valid_out);
    reg [1:0] state, next_state;
    reg [3:0] CLK_counter;
    reg [7:0] found_word;
    
    always @(posedge CLK)
    begin
        if(RST)                 //this RST has to go.
        begin
            state <= idle;
            CLK_counter = 4'b0000;
        end
        else    state <= next_state;
        if(state == data)   CLK_counter = CLK_counter + 1;
    end
    
    //I've seperated the negedge and the posedge procedural block to eliminate ambiguous clock signals
    
//    always @(negedge CLK)
//    begin
//        if(RST) state <= idle;
//        else    state <= next_state;
//        if(state == data)   CLK_counter = CLK_counter + 1;
//    end
    
    always @(state or CLK_counter or ser_in)
    begin
        case(state)
            idle:   if(ser_in)  next_state = idle;
                    else        next_state = start;
            start:  if(!ser_in) next_state = data;
                    else        next_state = idle;
            data:
                    if(CLK_counter == 15)   next_state = stop;
                    else                    next_state = data;
            stop:   next_state = idle;      // This old code doesn't match the diagram.     //if(ser_in)  next_state = idle; else next_state = start;
                    //we go straight to IDLE state since the stop bit of the transmission
                    // data frame will be read as one for two state updates in this reciever.
                    //idle is the best place to await a 0 bit.                        
        endcase
    end
    
    always @(state or CLK_counter or ser_in)
    begin
        case(state)
            idle:   data_valid_out = 1'b0;  //must halt transmissions from idle state
            start:  
            begin
                    par_out = 8'bXXXXXXXX;
                    found_word = 8'b00000000;
                    //CLK_counter = 4'b0000;
            end
            data:
            begin
                case (CLK_counter)
                    4'b0001: found_word[CLK_counter / 2] = ser_in;//make a case for all 8 even numbers to 16
                    4'b0011: found_word[CLK_counter / 2] = ser_in;
                    4'b0101: found_word[CLK_counter / 2] = ser_in;
                    4'b0111: found_word[CLK_counter / 2] = ser_in;
                    4'b1001: found_word[CLK_counter / 2] = ser_in;
                    4'b1011: found_word[CLK_counter / 2] = ser_in;
                    4'b1101: found_word[CLK_counter / 2] = ser_in;
                    4'b1111: found_word[CLK_counter / 2] = ser_in;
                    default: found_word = found_word;               //odd case
                endcase
                //if(CLK_counter % 2) found_word[CLK_counter / 2] = ser_in;       //% won't work
            end
            stop:   
            begin
                par_out = found_word;
                found_word = 8'bXXXXXXXX;
                //CLK_counter = 4'bXXXX;
                data_valid_out = 1'b1;
            end
        endcase
    end
endmodule
