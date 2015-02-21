
# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
  PCW_USE_S_AXI_HP0 1
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
  S_AXI_HP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:1.0 adc_0 {} {
  adc_clk_p adc_clk_p_i
  adc_clk_n adc_clk_n_i
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK adc_0/adc_clk
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26 DOUT_WIDTH 1
} {
  Din cntr_0/Q
  Dout led_o
}

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 96
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_1 {
  DIN_WIDTH 96 DIN_FROM 0 DIN_TO 0 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_2 {
  DIN_WIDTH 96 DIN_FROM 1 DIN_TO 1 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_3 {
  DIN_WIDTH 96 DIN_FROM 2 DIN_TO 2 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_4 {
  DIN_WIDTH 96 DIN_FROM 3 DIN_TO 3 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_5 {
  DIN_WIDTH 96 DIN_FROM 61 DIN_TO 32 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_6 {
  DIN_WIDTH 96 DIN_FROM 95 DIN_TO 64 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_0 {} {
  S_AXIS adc_0/M_AXIS
  s_axis_aclk adc_0/adc_clk
  s_axis_aresetn const_1/dout
  m_axis_aclk ps_0/FCLK_CLK0
  m_axis_aresetn slice_1/Dout
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
  TDATA_REMAP {tdata[30:16],49'b0000000000000000000000000000000000000000000000000}
} {
  S_AXIS fifo_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_0 {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_5/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_2/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_0 {
  INPUT_WIDTH.VALUE_SRC USER
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 32
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN subset_0/M_AXIS
  S_AXIS_PHASE phase_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[63:32]}
  M01_TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS cordic_0/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 625
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler:7.2 fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-2.03115602043062e-08, -1.75387293914111e-08, 1.97896944026886e-08, 2.06322753595244e-08, -1.78040997144769e-08, -2.07030381467756e-08, 1.56349908148677e-08, 1.66420078697555e-08, -1.52928482821028e-08, -7.89358069717853e-09, 1.94394773320395e-08, -5.22358018336472e-09, -3.11934015441871e-08, 2.12136728615565e-08, 5.38052194362665e-08, -3.71694096566803e-08, -9.02164433114091e-08, 4.86435624063121e-08, 1.42512581967825e-07, -4.96821948009307e-08, -2.1132020985417e-07, 3.30384366144739e-08, 2.95162453949494e-07, 9.33018884539749e-09, -3.89972924419326e-07, -8.56658708099943e-08, 4.88608291364297e-07, 2.03482425357269e-07, -5.80667157105929e-07, -3.68529546751985e-07, 6.52559649805626e-07, 5.83630773542386e-07, -6.87953445072171e-07, -8.47551293306803e-07, 6.68565064850542e-07, 1.15393646068631e-06, -5.75371546040187e-07, -1.49050294382088e-06, 3.90170023684841e-07, 1.83857511744557e-06, -9.7453727199105e-08, -2.17313326632123e-06, -3.13559873279461e-07, 2.46341902514303e-06, 8.46843607202556e-07, -2.67424709439889e-06, -1.49777727897409e-06, 2.76768723873562e-06, 2.25127092857369e-06, -2.70593935375202e-06, -3.08107313989004e-06, 2.45415407158134e-06, 3.94940812973279e-06, -1.9838648442822e-06, -4.80768626205267e-06, 1.27642738307513e-06, 5.59814728195552e-06, -3.26392825497272e-07, -6.25668667249843e-06, -8.55725574859433e-07, 6.71660065239718e-06, 2.24144193848828e-06, -6.91323457136144e-06, -3.78346311960228e-06, 6.7891687370197e-06, 5.41615300871163e-06, -6.29975177197789e-06, -7.0576324384827e-06, 5.41839417233341e-06, 8.61332777874209e-06, -4.14169814226581e-06, -9.9820203574478e-06, 2.49203221903955e-06, 1.10614462512671e-05, -5.20487664972716e-07, -1.17567434616586e-05, -1.69355977874233e-06, 1.19885737864821e-05, 4.04473435129754e-06, -1.17014453070948e-05, -6.40663788413163e-06, 1.08710167242824e-05, 8.63898398480893e-06, -9.51016157357053e-06, -1.05971348918011e-05, 7.67265616529076e-06, 1.21432572681955e-05, -5.45410554796969e-06, -1.31586826535385e-05, 2.98928958955595e-06, 1.35562469978553e-05, -4.45988915825038e-07, -1.3291976263641e-05, -1.98538483677775e-06, 1.23736045334628e-05, 4.10319210058827e-06, -1.08698043699573e-05, -5.71364589384342e-06, 8.91011798691642e-06, 6.64701380343249e-06, -6.68366622558743e-06, -6.77681642523509e-06, 4.4312252206257e-06, 6.03765248119095e-06, -2.43214444623213e-06, -4.44113858349159e-06, 9.85381082309479e-07, 2.08732165572289e-06, -3.86325493127037e-07, 8.29193480468008e-07, 8.99999509958956e-07, -4.02024710385876e-06, -2.7328033037332e-06, 7.11260913223422e-06, 6.00414786150105e-06, -9.6651085257256e-06, -1.07210252224024e-05, 1.11929055383741e-05, 1.67547103591971e-05, -1.12048234352777e-05, -2.38335609878165e-05, 9.23535182023914e-06, 3.15329770082165e-05, -4.89175165541472e-06, -3.92850729906735e-05, -2.10308790428718e-06, 4.63977689257494e-05, 1.18685537460337e-05, -5.20871214590021e-05, -2.43305002765033e-05, 5.55205893249099e-05, 3.91935646661833e-05, -5.58712334471161e-05, -5.5926277000836e-05, 5.23791913483458e-05, 7.37608953636952e-05, -4.44178395224679e-05, -9.17111060063501e-05, 3.15591930685297e-05, 0.000108607494387188, -1.36350727639037e-05, -0.000123153383036505, -9.21778092488399e-06, 0.000133985216474973, 3.65086338968293e-05, -0.0001397710984134, -6.73897071566799e-05, 0.000139294428844287, 0.000100657615187957, -0.000131553141678139, -0.000134786169179309, 0.000115853961620467, 0.000167984243294682, -9.18983232913651e-05, -0.000198280328389934, 5.9850289448277e-05, 0.000223628420225299, -2.03817967120981e-05, -0.000242032064492077, -2.53120572606057e-05, 0.000251678453271239, 7.5530453201601e-05, -0.000251076211800282, -0.000128121311626401, 0.000239185414286973, 0.000180567901855202, -0.000215543455823558, -0.000230134461553295, 0.000180325799011365, 0.000273990910683941, -0.00013442600962168, -0.000309409380206916, 7.94545868591684e-05, 0.000333948551832308, -1.77014518721478e-05, -0.000345642606343547, -4.79543287591371e-05, 0.000343175335318934, 0.000114183193414246, -0.000326029059726142, -0.000177391208517272, 0.000294591955692595, 0.000233943263452063, -0.000250213751391021, -0.000280413889570795, 0.000195197599412337, 0.000313848433555052, -0.000132723952872185, -0.000332020621921106, 6.66946487769863e-05, 0.000333641337709712, -1.55762252323927e-06, -0.000318601982472993, -5.80308532994455e-05, 0.000288046276772937, 0.000107492189542248, -0.000244441408023109, -0.000142691499618312, 0.00019153502996167, 0.000160305087790495, -0.000134216896561448, -0.00015817542267496, 7.82782559326821e-05, 0.000135623131544179, -3.00779100591924e-05, -9.36934044629877e-05, -3.87674501704915e-06, 3.53089943284759e-05, 1.74123907978447e-05, 3.46886619995338e-05, -5.214542310414e-06, -0.000109629494204786, -3.66404534742113e-05, 0.000181228708986298, 0.000110128078639576, -0.000240044071919333, -0.000214937705576646, 0.000275864131169019, 0.000348009129866286, -0.000278421870769888, -0.000503359474055481, 0.000238104900199416, 0.000672025951132768, -0.000146743396374782, -0.00084220082689621, -1.5844741381903e-06, 0.000999567797118046, 0.000209773004337725, -0.00112784952723778, -0.000476991377229634, 0.00120955516330423, 0.000798116703120563, -0.00122691173076574, -0.00116335184733358, 0.00116294351767081, 0.00155807123449109, -0.00100266099469199, -0.00196296589324868, 0.000734192450011299, 0.00235426002157621, -0.000350245196997969, -0.00270467384457216, -0.000151001775112082, 0.00298423722773132, 0.000764817019653386, -0.00316159356251411, -0.00147916271158551, 0.00320550766139835, 0.00227422019652227, -0.00308656092345958, -0.00312225596742777, 0.00277896470948447, 0.00398786347701215, -0.00226242034251438, -0.00482860958282298, 0.00152393660803666, 0.00559608611151118, -0.0005595213775971, -0.00623735315729268, -0.000624335878724284, 0.00669673012553972, 0.00200938733334572, -0.00691816319968799, -0.00356527573331151, 0.00684693276423034, 0.00524844662544814, -0.00643275747110054, -0.00700266342091709, 0.00563204997872242, 0.00875941888806824, -0.00441037215047652, -0.0104388593765703, 0.00274469845655566, 0.0119510705578314, -0.000625392977860017, -0.0131976097151478, -0.00194219330115925, 0.0140731118173325, 0.00493656849117708, -0.0144667368361932, -0.00831943321095768, 0.0142631149229189, 0.0120355039540035, -0.0133422589437578, -0.0160127594461778, 0.0115773495431226, 0.0201616933259473, -0.00883199815259797, -0.0243782093560389, 0.00494746038144003, 0.0285400285005772, 0.000274025688544358, -0.0325042420856099, -0.0071049338419233, 0.0360971382566302, 0.0159610497068542, -0.0390878889136193, -0.027542835447625, 0.0411187693886639, 0.0431540839308694, -0.0415016745679629, -0.0655157757608116, 0.0385160296512945, 0.10124049451623, -0.0262370608166573, -0.170479974752058, -0.0279831055653722, 0.358670850828495, 0.57258607418619, 0.358670850828495, -0.0279831055653722, -0.170479974752058, -0.0262370608166573, 0.10124049451623, 0.0385160296512945, -0.0655157757608115, -0.0415016745679629, 0.0431540839308693, 0.0411187693886638, -0.0275428354476251, -0.0390878889136193, 0.0159610497068543, 0.0360971382566302, -0.00710493384192334, -0.0325042420856099, 0.000274025688544387, 0.0285400285005772, 0.00494746038144, -0.0243782093560389, -0.00883199815259792, 0.0201616933259473, 0.0115773495431226, -0.0160127594461778, -0.0133422589437578, 0.0120355039540035, 0.0142631149229189, -0.00831943321095768, -0.0144667368361932, 0.00493656849117708, 0.0140731118173325, -0.00194219330115925, -0.0131976097151478, -0.00062539297786002, 0.0119510705578314, 0.00274469845655566, -0.0104388593765703, -0.00441037215047652, 0.00875941888806823, 0.00563204997872243, -0.00700266342091708, -0.00643275747110055, 0.00524844662544815, 0.00684693276423035, -0.00356527573331151, -0.006918163199688, 0.00200938733334573, 0.00669673012553972, -0.000624335878724301, -0.00623735315729268, -0.000559521377597102, 0.00559608611151119, 0.00152393660803666, -0.00482860958282299, -0.00226242034251439, 0.00398786347701215, 0.00277896470948449, -0.00312225596742777, -0.0030865609234596, 0.00227422019652227, 0.00320550766139837, -0.00147916271158551, -0.00316159356251415, 0.000764817019653386, 0.00298423722773134, -0.000151001775112086, -0.00270467384457218, -0.00035024519699797, 0.00235426002157621, 0.000734192450011303, -0.00196296589324869, -0.00100266099469199, 0.0015580712344911, 0.00116294351767082, -0.00116335184733357, -0.00122691173076574, 0.000798116703120568, 0.00120955516330423, -0.000476991377229631, -0.00112784952723778, 0.00020977300433773, 0.000999567797118045, -1.58447413819618e-06, -0.000842200826896208, -0.000146743396374786, 0.000672025951132768, 0.000238104900199411, -0.000503359474055481, -0.00027842187076989, 0.000348009129866284, 0.000275864131169012, -0.000214937705576645, -0.00024004407191933, 0.000110128078639575, 0.000181228708986285, -3.66404534742113e-05, -0.000109629494204786, -5.21454231041332e-06, 3.46886619995328e-05, 1.74123907978446e-05, 3.53089943284712e-05, -3.87674501704883e-06, -9.36934044629926e-05, -3.00779100591914e-05, 0.000135623131544184, 7.82782559326812e-05, -0.000158175422674956, -0.000134216896561448, 0.000160305087790494, 0.000191535029961669, -0.000142691499618303, -0.000244441408023109, 0.000107492189542248, 0.000288046276772936, -5.80308532994433e-05, -0.000318601982472991, -1.55762252323883e-06, 0.000333641337709712, 6.66946487769878e-05, -0.000332020621921105, -0.000132723952872189, 0.000313848433555052, 0.000195197599412339, -0.000280413889570796, -0.000250213751391025, 0.000233943263452063, 0.0002945919556926, -0.000177391208517272, -0.000326029059726147, 0.000114183193414244, 0.000343175335318934, -4.79543287591364e-05, -0.000345642606343547, -1.77014518721477e-05, 0.000333948551832306, 7.94545868591687e-05, -0.000309409380206917, -0.000134426009621679, 0.00027399091068394, 0.000180325799011365, -0.000230134461553296, -0.000215543455823559, 0.000180567901855204, 0.000239185414286973, -0.000128121311626404, -0.000251076211800281, 7.55304532016002e-05, 0.000251678453271239, -2.53120572606071e-05, -0.000242032064492077, -2.03817967120965e-05, 0.000223628420225299, 5.98502894482789e-05, -0.000198280328389934, -9.18983232913671e-05, 0.000167984243294682, 0.000115853961620465, -0.000134786169179309, -0.00013155314167814, 0.000100657615187957, 0.000139294428844286, -6.73897071566808e-05, -0.0001397710984134, 3.65086338968297e-05, 0.000133985216474974, -9.21778092488442e-06, -0.000123153383036506, -1.36350727639035e-05, 0.000108607494387188, 3.15591930685297e-05, -9.17111060063494e-05, -4.44178395224681e-05, 7.37608953636964e-05, 5.23791913483455e-05, -5.59262770008369e-05, -5.58712334471159e-05, 3.91935646661802e-05, 5.55205893249099e-05, -2.43305002765021e-05, -5.20871214590019e-05, 1.18685537460332e-05, 4.63977689257491e-05, -2.1030879042873e-06, -3.92850729906734e-05, -4.89175165541453e-06, 3.15329770082162e-05, 9.23535182023802e-06, -2.38335609878164e-05, -1.12048234352775e-05, 1.67547103591972e-05, 1.11929055383713e-05, -1.07210252224024e-05, -9.66510852572193e-06, 6.00414786150074e-06, 7.11260913223396e-06, -2.7328033037333e-06, -4.02024710385772e-06, 8.99999509959229e-07, 8.2919348046719e-07, -3.86325493127123e-07, 2.0873216557222e-06, 9.85381082309679e-07, -4.44113858349067e-06, -2.43214444623244e-06, 6.03765248119041e-06, 4.43122522062583e-06, -6.77681642523496e-06, -6.68366622558766e-06, 6.6470138034324e-06, 8.91011798691619e-06, -5.7136458938431e-06, -1.08698043699574e-05, 4.10319210058805e-06, 1.23736045334626e-05, -1.98538483677754e-06, -1.32919762636409e-05, -4.45988915825105e-07, 1.35562469978552e-05, 2.98928958955552e-06, -1.31586826535384e-05, -5.45410554796921e-06, 1.21432572681957e-05, 7.6726561652905e-06, -1.05971348918011e-05, -9.51016157357015e-06, 8.63898398480881e-06, 1.08710167242827e-05, -6.40663788413157e-06, -1.17014453070948e-05, 4.04473435129748e-06, 1.19885737864821e-05, -1.69355977874223e-06, -1.17567434616587e-05, -5.20487664972689e-07, 1.10614462512674e-05, 2.49203221903964e-06, -9.98202035744796e-06, -4.14169814226596e-06, 8.61332777874239e-06, 5.41839417233343e-06, -7.05763243848281e-06, -6.29975177197785e-06, 5.4161530087116e-06, 6.78916873701973e-06, -3.78346311960255e-06, -6.91323457136147e-06, 2.24144193848809e-06, 6.71660065239719e-06, -8.55725574859456e-07, -6.25668667249845e-06, -3.26392825497604e-07, 5.59814728195552e-06, 1.27642738307537e-06, -4.80768626205266e-06, -1.98386484428226e-06, 3.94940812973279e-06, 2.45415407158128e-06, -3.08107313989006e-06, -2.70593935375206e-06, 2.25127092857372e-06, 2.76768723873562e-06, -1.49777727897411e-06, -2.6742470943989e-06, 8.46843607202565e-07, 2.46341902514303e-06, -3.13559873279473e-07, -2.17313326632106e-06, -9.74537271990938e-08, 1.83857511744554e-06, 3.90170023684817e-07, -1.49050294382088e-06, -5.75371546040182e-07, 1.15393646068633e-06, 6.6856506485055e-07, -8.47551293306804e-07, -6.87953445072166e-07, 5.83630773542373e-07, 6.5255964980563e-07, -3.68529546751977e-07, -5.80667157105937e-07, 2.03482425357261e-07, 4.88608291364295e-07, -8.56658708099976e-08, -3.89972924419324e-07, 9.33018884539704e-09, 2.95162453949496e-07, 3.30384366144441e-08, -2.1132020985417e-07, -4.96821948009223e-08, 1.42512581967823e-07, 4.86435624063157e-08, -9.02164433114098e-08, -3.71694096566706e-08, 5.38052194362697e-08, 2.12136728615564e-08, -3.11934015441839e-08, -5.22358018337902e-09, 1.94394773320359e-08, -7.8935806971707e-09, -1.52928482821013e-08, 1.66420078697533e-08, 1.56349908148654e-08, -2.07030381467789e-08, -1.78040997144756e-08, 2.06322753595229e-08, 1.978969440269e-08, -1.75387293914112e-08, -2.03115602043054e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_PATHS 2
  RATESPECIFICATION Input_Sample_Period
  SAMPLEPERIOD 625
  OUTPUT_ROUNDING_MODE Truncate_LSBs
  OUTPUT_WIDTH 32
} {
  S_AXIS_DATA comb_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 64
  CNTR_WIDTH 32
  CONTINUOUS TRUE
} {
  S_AXIS fir_0/M_AXIS_DATA
  cfg_data slice_6/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_3/Dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_2 {
  CONST_WIDTH 32
  CONST_VAL 503316480
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer:1.0 writer_0 {
  ADDR_WIDTH 9
} {
  S_AXIS pktzr_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  cfg_data const_2/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data writer_0/sts_data
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
