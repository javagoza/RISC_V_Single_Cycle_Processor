`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 07/28/2025 08:00:00 AM
// Design Name: 3-to-1 Multiplexer
// Module Name: mux3
// Project Name:
// Target Devices:
// Tool Versions: Vivado
// Description: 3-to-1 Multiplexer (Data Selector)
//              Parameterized width multiplexer that selects between three inputs
//              based on a 2-bit control signal.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module mux3 #(
    parameter WIDTH = 8 // Parameterized data width - default 8 bits
                        // Can be instantiated with any desired width
                        // e.g., mux3 #(32) for 32-bit data paths
)(
    input logic [WIDTH-1:0] d0, // Data input 0 - selected when s = 2'b00
    input logic [WIDTH-1:0] d1, // Data input 1 - selected when s = 2'b01
    input logic [WIDTH-1:0] d2, // Data input 2 - selected when s = 2'b10
    input logic [1:0] s,        // 2-bit Select signal (control input)
                                // 2'b00: output = d0
                                // 2'b01: output = d1
                                // 2'b10: output = d2
                                // Other values (e.g., 2'b11) will default to 2'bxx
    output logic [WIDTH-1:0] y  // Output - selected input data
);

    always_comb begin
        case (s)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = 2'bxx;
        endcase
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Usage Example:
//
// Selecting one of three register values:
// mux3 #(32) reg_select_mux(
//     .d0(reg_read_data1),
//     .d1(reg_read_data2),
//     .d2(reg_read_data3),
//     .s(RegSelectCtrl), // 2-bit control signal
//     .y(selected_reg_value)
// );
//
// General purpose data routing:
// mux3 #(16) data_router(
//     .d0(sensor_data_a),
//     .d1(network_packet_data),
//     .d2(user_input_data),
//     .s(DataSourceSelect),
//     .y(processed_data_input)
// );
//////////////////////////////////////////////////////////////////////////////////