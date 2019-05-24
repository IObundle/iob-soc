 //DIRECT ACCESS to RIU (logical nibble order) 
 28'h???2???: begin 
   riu_addr_cal = io_address[5:0]; 
   riu_nibble = io_address[NIBBLE_CNT_WIDTH+6:6]; 
 end 
//========================================//
//===========Address ODELAYS=============//
//========================================//

28'h0010800: begin //c0_ddr4_odt[0] IO_L1N_T0L_N1_DBC_44
  riu_addr_cal = 6'hC;
  riu_nibble = 'h0;
end

28'h0010040: begin //c0_ddr4_act_n IO_L7N_T1L_N1_QBC_AD13N_44
  riu_addr_cal = 6'hC;
  riu_nibble = 'h2;
end

28'h0010010: begin //c0_ddr4_adr[0] IO_L14P_T2L_N2_GC_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h4;
end

28'h0010011: begin //c0_ddr4_adr[1] IO_L14N_T2L_N3_GC_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h4;
end

28'h0010012: begin //c0_ddr4_adr[2] IO_L15P_T2L_N4_AD11P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h4;
end

28'h0010013: begin //c0_ddr4_adr[3] IO_L15N_T2L_N5_AD11N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h4;
end

28'h0010014: begin //c0_ddr4_adr[4] IO_L17P_T2U_N8_AD10P_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h5;
end

28'h0010015: begin //c0_ddr4_adr[5] IO_L17N_T2U_N9_AD10N_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h5;
end

28'h0010016: begin //c0_ddr4_adr[6] IO_L18P_T2U_N10_AD2P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h5;
end

28'h0010017: begin //c0_ddr4_adr[7] IO_L18N_T2U_N11_AD2N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h5;
end

28'h0010018: begin //c0_ddr4_adr[8] IO_T2U_N12_44
  riu_addr_cal = 6'h11;
  riu_nibble = 'h5;
end

28'h0010019: begin //c0_ddr4_adr[9] IO_L19P_T3L_N0_DBC_AD9P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h6;
end

28'h001001A: begin //c0_ddr4_adr[10] IO_L19N_T3L_N1_DBC_AD9N_44
  riu_addr_cal = 6'hC;
  riu_nibble = 'h6;
end

28'h001001B: begin //c0_ddr4_adr[11] IO_L20P_T3L_N2_AD1P_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h6;
end

28'h001001C: begin //c0_ddr4_adr[12] IO_L20N_T3L_N3_AD1N_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h6;
end

28'h001001D: begin //c0_ddr4_adr[13] IO_L21P_T3L_N4_AD8P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h6;
end

28'h001001E: begin //c0_ddr4_adr[14] IO_L21N_T3L_N5_AD8N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h6;
end

28'h001001F: begin //c0_ddr4_adr[15] IO_L22P_T3U_N6_DBC_AD0P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h7;
end

28'h0010020: begin //c0_ddr4_adr[16] IO_L22N_T3U_N7_DBC_AD0N_44
  riu_addr_cal = 6'hC;
  riu_nibble = 'h7;
end

28'h0010080: begin //c0_ddr4_ba[0] IO_L23P_T3U_N8_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h7;
end

28'h0010081: begin //c0_ddr4_ba[1] IO_L23N_T3U_N9_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h7;
end

28'h0010100: begin //c0_ddr4_bg[0] IO_L24P_T3U_N10_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h7;
end

28'h0010400: begin //c0_ddr4_cs_n[0] IO_L24N_T3U_N11_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h7;
end

28'h0010200: begin //c0_ddr4_cke[0] IO_T3U_N12_44
  riu_addr_cal = 6'h11;
  riu_nibble = 'h7;
end

//========================================//
//===========Address IDELAYS=============//
//========================================//

//========================================//
//===========Clock ODELAYS=============//
//========================================//

28'h0006100: begin //c0_ddr4_ck_t[0] IO_L16P_T2U_N6_QBC_AD3P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h5;
end

//========================================//
//===========Clock IDELAYS=============//
//========================================//

//========================================//
//===========Data ODELAYS=============//
//========================================//

28'h0004100: begin //c0_ddr4_dq[0] IO_L2P_T0L_N2_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h0;
end

28'h0004101: begin //c0_ddr4_dq[1] IO_L2N_T0L_N3_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h0;
end

28'h0004102: begin //c0_ddr4_dq[2] IO_L3P_T0L_N4_AD15P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h0;
end

28'h0004103: begin //c0_ddr4_dq[3] IO_L3N_T0L_N5_AD15N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h0;
end

28'h0004104: begin //c0_ddr4_dq[4] IO_L5P_T0U_N8_AD14P_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h1;
end

28'h0004105: begin //c0_ddr4_dq[5] IO_L5N_T0U_N9_AD14N_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h1;
end

28'h0004106: begin //c0_ddr4_dq[6] IO_L6P_T0U_N10_AD6P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h1;
end

28'h0004107: begin //c0_ddr4_dq[7] IO_L6N_T0U_N11_AD6N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h1;
end

28'h0004108: begin //c0_ddr4_dq[8] IO_L8P_T1L_N2_AD5P_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h2;
end

28'h0004109: begin //c0_ddr4_dq[9] IO_L8N_T1L_N3_AD5N_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h2;
end

28'h000410A: begin //c0_ddr4_dq[10] IO_L9P_T1L_N4_AD12P_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h2;
end

28'h000410B: begin //c0_ddr4_dq[11] IO_L9N_T1L_N5_AD12N_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h2;
end

28'h000410C: begin //c0_ddr4_dq[12] IO_L11P_T1U_N8_GC_44
  riu_addr_cal = 6'hD;
  riu_nibble = 'h3;
end

28'h000410D: begin //c0_ddr4_dq[13] IO_L11N_T1U_N9_GC_44
  riu_addr_cal = 6'hE;
  riu_nibble = 'h3;
end

28'h000410E: begin //c0_ddr4_dq[14] IO_L12P_T1U_N10_GC_44
  riu_addr_cal = 6'hF;
  riu_nibble = 'h3;
end

28'h000410F: begin //c0_ddr4_dq[15] IO_L12N_T1U_N11_GC_44
  riu_addr_cal = 6'h10;
  riu_nibble = 'h3;
end

28'h0004110: begin //c0_ddr4_dq[16] IO_L2P_T0L_N2_45
  riu_addr_cal = 6'hD;
  riu_nibble = 'h8;
end

28'h0004111: begin //c0_ddr4_dq[17] IO_L2N_T0L_N3_45
  riu_addr_cal = 6'hE;
  riu_nibble = 'h8;
end

28'h0004112: begin //c0_ddr4_dq[18] IO_L3P_T0L_N4_AD15P_45
  riu_addr_cal = 6'hF;
  riu_nibble = 'h8;
end

28'h0004113: begin //c0_ddr4_dq[19] IO_L3N_T0L_N5_AD15N_45
  riu_addr_cal = 6'h10;
  riu_nibble = 'h8;
end

28'h0004114: begin //c0_ddr4_dq[20] IO_L5P_T0U_N8_AD14P_45
  riu_addr_cal = 6'hD;
  riu_nibble = 'h9;
end

28'h0004115: begin //c0_ddr4_dq[21] IO_L5N_T0U_N9_AD14N_45
  riu_addr_cal = 6'hE;
  riu_nibble = 'h9;
end

28'h0004116: begin //c0_ddr4_dq[22] IO_L6P_T0U_N10_AD6P_45
  riu_addr_cal = 6'hF;
  riu_nibble = 'h9;
end

28'h0004117: begin //c0_ddr4_dq[23] IO_L6N_T0U_N11_AD6N_45
  riu_addr_cal = 6'h10;
  riu_nibble = 'h9;
end

28'h0004118: begin //c0_ddr4_dq[24] IO_L8P_T1L_N2_AD5P_45
  riu_addr_cal = 6'hD;
  riu_nibble = 'ha;
end

28'h0004119: begin //c0_ddr4_dq[25] IO_L8N_T1L_N3_AD5N_45
  riu_addr_cal = 6'hE;
  riu_nibble = 'ha;
end

28'h000411A: begin //c0_ddr4_dq[26] IO_L9P_T1L_N4_AD12P_45
  riu_addr_cal = 6'hF;
  riu_nibble = 'ha;
end

28'h000411B: begin //c0_ddr4_dq[27] IO_L9N_T1L_N5_AD12N_45
  riu_addr_cal = 6'h10;
  riu_nibble = 'ha;
end

28'h000411C: begin //c0_ddr4_dq[28] IO_L11P_T1U_N8_GC_45
  riu_addr_cal = 6'hD;
  riu_nibble = 'hb;
end

28'h000411D: begin //c0_ddr4_dq[29] IO_L11N_T1U_N9_GC_45
  riu_addr_cal = 6'hE;
  riu_nibble = 'hb;
end

28'h000411E: begin //c0_ddr4_dq[30] IO_L12P_T1U_N10_GC_45
  riu_addr_cal = 6'hF;
  riu_nibble = 'hb;
end

28'h000411F: begin //c0_ddr4_dq[31] IO_L12N_T1U_N11_GC_45
  riu_addr_cal = 6'h10;
  riu_nibble = 'hb;
end

//========================================//
//===========Data IDELAYS=============//
//========================================//

28'h0004200: begin //c0_ddr4_dq[0] IO_L2P_T0L_N2_44
  riu_addr_cal = 6'h14;
  riu_nibble = 'h0;
end

28'h0004201: begin //c0_ddr4_dq[1] IO_L2N_T0L_N3_44
  riu_addr_cal = 6'h15;
  riu_nibble = 'h0;
end

28'h0004202: begin //c0_ddr4_dq[2] IO_L3P_T0L_N4_AD15P_44
  riu_addr_cal = 6'h16;
  riu_nibble = 'h0;
end

28'h0004203: begin //c0_ddr4_dq[3] IO_L3N_T0L_N5_AD15N_44
  riu_addr_cal = 6'h17;
  riu_nibble = 'h0;
end

28'h0004204: begin //c0_ddr4_dq[4] IO_L5P_T0U_N8_AD14P_44
  riu_addr_cal = 6'h14;
  riu_nibble = 'h1;
end

28'h0004205: begin //c0_ddr4_dq[5] IO_L5N_T0U_N9_AD14N_44
  riu_addr_cal = 6'h15;
  riu_nibble = 'h1;
end

28'h0004206: begin //c0_ddr4_dq[6] IO_L6P_T0U_N10_AD6P_44
  riu_addr_cal = 6'h16;
  riu_nibble = 'h1;
end

28'h0004207: begin //c0_ddr4_dq[7] IO_L6N_T0U_N11_AD6N_44
  riu_addr_cal = 6'h17;
  riu_nibble = 'h1;
end

28'h0004208: begin //c0_ddr4_dq[8] IO_L8P_T1L_N2_AD5P_44
  riu_addr_cal = 6'h14;
  riu_nibble = 'h2;
end

28'h0004209: begin //c0_ddr4_dq[9] IO_L8N_T1L_N3_AD5N_44
  riu_addr_cal = 6'h15;
  riu_nibble = 'h2;
end

28'h000420A: begin //c0_ddr4_dq[10] IO_L9P_T1L_N4_AD12P_44
  riu_addr_cal = 6'h16;
  riu_nibble = 'h2;
end

28'h000420B: begin //c0_ddr4_dq[11] IO_L9N_T1L_N5_AD12N_44
  riu_addr_cal = 6'h17;
  riu_nibble = 'h2;
end

28'h000420C: begin //c0_ddr4_dq[12] IO_L11P_T1U_N8_GC_44
  riu_addr_cal = 6'h14;
  riu_nibble = 'h3;
end

28'h000420D: begin //c0_ddr4_dq[13] IO_L11N_T1U_N9_GC_44
  riu_addr_cal = 6'h15;
  riu_nibble = 'h3;
end

28'h000420E: begin //c0_ddr4_dq[14] IO_L12P_T1U_N10_GC_44
  riu_addr_cal = 6'h16;
  riu_nibble = 'h3;
end

28'h000420F: begin //c0_ddr4_dq[15] IO_L12N_T1U_N11_GC_44
  riu_addr_cal = 6'h17;
  riu_nibble = 'h3;
end

28'h0004210: begin //c0_ddr4_dq[16] IO_L2P_T0L_N2_45
  riu_addr_cal = 6'h14;
  riu_nibble = 'h8;
end

28'h0004211: begin //c0_ddr4_dq[17] IO_L2N_T0L_N3_45
  riu_addr_cal = 6'h15;
  riu_nibble = 'h8;
end

28'h0004212: begin //c0_ddr4_dq[18] IO_L3P_T0L_N4_AD15P_45
  riu_addr_cal = 6'h16;
  riu_nibble = 'h8;
end

28'h0004213: begin //c0_ddr4_dq[19] IO_L3N_T0L_N5_AD15N_45
  riu_addr_cal = 6'h17;
  riu_nibble = 'h8;
end

28'h0004214: begin //c0_ddr4_dq[20] IO_L5P_T0U_N8_AD14P_45
  riu_addr_cal = 6'h14;
  riu_nibble = 'h9;
end

28'h0004215: begin //c0_ddr4_dq[21] IO_L5N_T0U_N9_AD14N_45
  riu_addr_cal = 6'h15;
  riu_nibble = 'h9;
end

28'h0004216: begin //c0_ddr4_dq[22] IO_L6P_T0U_N10_AD6P_45
  riu_addr_cal = 6'h16;
  riu_nibble = 'h9;
end

28'h0004217: begin //c0_ddr4_dq[23] IO_L6N_T0U_N11_AD6N_45
  riu_addr_cal = 6'h17;
  riu_nibble = 'h9;
end

28'h0004218: begin //c0_ddr4_dq[24] IO_L8P_T1L_N2_AD5P_45
  riu_addr_cal = 6'h14;
  riu_nibble = 'ha;
end

28'h0004219: begin //c0_ddr4_dq[25] IO_L8N_T1L_N3_AD5N_45
  riu_addr_cal = 6'h15;
  riu_nibble = 'ha;
end

28'h000421A: begin //c0_ddr4_dq[26] IO_L9P_T1L_N4_AD12P_45
  riu_addr_cal = 6'h16;
  riu_nibble = 'ha;
end

28'h000421B: begin //c0_ddr4_dq[27] IO_L9N_T1L_N5_AD12N_45
  riu_addr_cal = 6'h17;
  riu_nibble = 'ha;
end

28'h000421C: begin //c0_ddr4_dq[28] IO_L11P_T1U_N8_GC_45
  riu_addr_cal = 6'h14;
  riu_nibble = 'hb;
end

28'h000421D: begin //c0_ddr4_dq[29] IO_L11N_T1U_N9_GC_45
  riu_addr_cal = 6'h15;
  riu_nibble = 'hb;
end

28'h000421E: begin //c0_ddr4_dq[30] IO_L12P_T1U_N10_GC_45
  riu_addr_cal = 6'h16;
  riu_nibble = 'hb;
end

28'h000421F: begin //c0_ddr4_dq[31] IO_L12N_T1U_N11_GC_45
  riu_addr_cal = 6'h17;
  riu_nibble = 'hb;
end

//========================================//
//===========Mask ODELAYS=============//
//========================================//

28'h0004400: begin //c0_ddr4_dm_dbi_n[0] IO_L1P_T0L_N0_DBC_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h0;
end

28'h0004401: begin //c0_ddr4_dm_dbi_n[1] IO_L7P_T1L_N0_QBC_AD13P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h2;
end

28'h0004402: begin //c0_ddr4_dm_dbi_n[2] IO_L1P_T0L_N0_DBC_45
  riu_addr_cal = 6'hB;
  riu_nibble = 'h8;
end

28'h0004403: begin //c0_ddr4_dm_dbi_n[3] IO_L7P_T1L_N0_QBC_AD13P_45
  riu_addr_cal = 6'hB;
  riu_nibble = 'ha;
end

//========================================//
//===========Mask IDELAYS=============//
//========================================//

28'h0004800: begin //c0_ddr4_dm_dbi_n[0] IO_L1P_T0L_N0_DBC_44
  riu_addr_cal = 6'h12;
  riu_nibble = 'h0;
end

28'h0004801: begin //c0_ddr4_dm_dbi_n[1] IO_L7P_T1L_N0_QBC_AD13P_44
  riu_addr_cal = 6'h12;
  riu_nibble = 'h2;
end

28'h0004802: begin //c0_ddr4_dm_dbi_n[2] IO_L1P_T0L_N0_DBC_45
  riu_addr_cal = 6'h12;
  riu_nibble = 'h8;
end

28'h0004803: begin //c0_ddr4_dm_dbi_n[3] IO_L7P_T1L_N0_QBC_AD13P_45
  riu_addr_cal = 6'h12;
  riu_nibble = 'ha;
end

//========================================//
//===========Strobe ODELAYS=============//
//========================================//

28'h0008100: begin //c0_ddr4_dqs_t[0] IO_L4P_T0U_N6_DBC_AD7P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h1;
end

28'h0008101: begin //c0_ddr4_dqs_t[1] IO_L10P_T1U_N6_QBC_AD4P_44
  riu_addr_cal = 6'hB;
  riu_nibble = 'h3;
end

28'h0008102: begin //c0_ddr4_dqs_t[2] IO_L4P_T0U_N6_DBC_AD7P_45
  riu_addr_cal = 6'hB;
  riu_nibble = 'h9;
end

28'h0008103: begin //c0_ddr4_dqs_t[3] IO_L10P_T1U_N6_QBC_AD4P_45
  riu_addr_cal = 6'hB;
  riu_nibble = 'hb;
end

//========================================//
//===========Strobe IDELAYS=============//
//========================================//

28'h0008200: begin //c0_ddr4_dqs_t[0] IO_L4P_T0U_N6_DBC_AD7P_44
  riu_addr_cal = 6'h12;
  riu_nibble = 'h1;
end

28'h0008201: begin //c0_ddr4_dqs_t[1] IO_L10P_T1U_N6_QBC_AD4P_44
  riu_addr_cal = 6'h12;
  riu_nibble = 'h3;
end

28'h0008202: begin //c0_ddr4_dqs_t[2] IO_L4P_T0U_N6_DBC_AD7P_45
  riu_addr_cal = 6'h12;
  riu_nibble = 'h9;
end

28'h0008203: begin //c0_ddr4_dqs_t[3] IO_L10P_T1U_N6_QBC_AD4P_45
  riu_addr_cal = 6'h12;
  riu_nibble = 'hb;
end

