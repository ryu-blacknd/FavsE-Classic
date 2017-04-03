# Default
SetFilterMTMode("DEFAULT_MT_MODE",     MT_SERIALIZED)

# Source
SetFilterMTMode("MPEG2source",         MT_NICE_FILTER)
SetFilterMTMode("DGDecode_mpeg2source",MT_NICE_FILTER)

# rgtools
SetFilterMTMode("removegrain",         MT_NICE_FILTER)
SetFilterMTMode("repair",              MT_NICE_FILTER)
SetFilterMTMode("verticalcleaner",     MT_NICE_FILTER)
SetFilterMTMode("clense",              MT_NICE_FILTER)

# masktools2
SetFilterMTMode("mt_invert",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_binarize",         MT_MULTI_INSTANCE)
SetFilterMTMode("mt_inflate",          MT_MULTI_INSTANCE)
SetFilterMTMode("mt_deflate",          MT_MULTI_INSTANCE)
SetFilterMTMode("mt_inpand",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_expand",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lut",              MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lutxy",            MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lutxyz",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_luts",             MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lutf",             MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lutsx",            MT_MULTI_INSTANCE)
SetFilterMTMode("mt_lutspa",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_merge",            MT_MULTI_INSTANCE)
SetFilterMTMode("mt_logic",            MT_MULTI_INSTANCE)
SetFilterMTMode("mt_convolution",      MT_MULTI_INSTANCE)
SetFilterMTMode("mt_mappedblur",       MT_MULTI_INSTANCE)
SetFilterMTMode("mt_makediff",         MT_MULTI_INSTANCE)
SetFilterMTMode("mt_average",          MT_MULTI_INSTANCE)
SetFilterMTMode("mt_adddiff",          MT_MULTI_INSTANCE)
SetFilterMTMode("mt_clamp",            MT_MULTI_INSTANCE)
SetFilterMTMode("mt_motion",           MT_MULTI_INSTANCE)
SetFilterMTMode("mt_edge",             MT_MULTI_INSTANCE)
SetFilterMTMode("mt_hysteresis",       MT_MULTI_INSTANCE)

# DeInterlace & IT
SetFilterMTMode("TDeint",              MT_MULTI_INSTANCE)
SetFilterMTMode("TFM",                 MT_MULTI_INSTANCE)
SetFilterMTMode("TDecimate",           MT_SERIALIZED)     #1 gave error, 2 was slower than 3
SetFilterMTMode("Vinverse",            MT_MULTI_INSTANCE)
SetFilterMTMode("TMM2",                MT_NICE_FILTER)
SetFilterMTMode("nnedi3",              MT_MULTI_INSTANCE)
SetFilterMTMode("nnedi3_rpow2",        MT_NICE_FILTER)
SetFilterMTMode("nnedi3ocl",           MT_MULTI_INSTANCE)
SetFilterMTMode("yadifmod2",           MT_NICE_FILTER)

# DeNoise
SetFilterMTMode("TNLMeans",            MT_MULTI_INSTANCE)
SetFilterMTMode("FFT3DFilter",         MT_MULTI_INSTANCE)
SetFilterMTMode("hqdn3d",              MT_MULTI_INSTANCE)

# Logo
SetFilterMTMode("EraseLOGO",           MT_MULTI_INSTANCE)
SetFilterMTMode("AddLOGO",             MT_MULTI_INSTANCE)
SetFilterMTMode("EraseLogoMod",        MT_MULTI_INSTANCE)

# Subtitle
SetFilterMTMode("SupTitle",            MT_MULTI_INSTANCE)
SetFilterMTMode("VobSub",              MT_MULTI_INSTANCE)

# avstp
if (FunctionExists("avstp_set_threads")) {
    avstp_set_threads(0, 1)
}
