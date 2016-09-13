# Source
SetFilterMtMode("AviSource",           MT_SERIALIZED)
SetFilterMtMode("DirectShowSource",    MT_SERIALIZED)
SetFilterMTMode("MPEG2source",         MT_NICE_FILTER)
SetFilterMTMode("DGSource",            MT_SERIALIZED)
SetFilterMTMode("DGsourceIM",          MT_SERIALIZED)
SetFilterMTMode("DGDecode_mpeg2source",MT_NICE_FILTER)
SetFilterMTMode("LWLibavVideoSource",  MT_SERIALIZED)
SetFilterMTMode("LWLibavAudioSource",  MT_SERIALIZED)
SetFilterMtMode("AudioDub",            MT_SERIALIZED)

# rgtools
SetFilterMTMode("removegrain",         MT_NICE_FILTER)
SetFilterMTMode("repair",              MT_NICE_FILTER)
SetFilterMTMode("verticalcleaner",     MT_NICE_FILTER)
SetFilterMTMode("clense",              MT_NICE_FILTER)

# medianblur
SetFilterMTMode("medianblur",          MT_MULTI_INSTANCE)
SetFilterMTMode("medianblurtemporal",  MT_MULTI_INSTANCE)

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
SetFilterMTMode("TDecimate",           MT_SERIALIZED)
SetFilterMTMode("Vinverse",            MT_MULTI_INSTANCE)
SetFilterMTMode("TMM2",                MT_NICE_FILTER)
SetFilterMTMode("nnedi3",              MT_MULTI_INSTANCE)
SetFilterMTMode("nnedi3_rpow2",        MT_NICE_FILTER)
SetFilterMTMode("nnedi3ocl",           MT_MULTI_INSTANCE)

# DeNoise
SetFilterMTMode("TNLMeans",            MT_MULTI_INSTANCE)
SetFilterMTMode("FFT3DFilter",         MT_MULTI_INSTANCE)
SetFilterMTMode("hqdn3d",              MT_MULTI_INSTANCE)

# Logo
SetFilterMTMode("EraseLOGO",           MT_MULTI_INSTANCE)
SetFilterMTMode("EraseLogoMod",        MT_MULTI_INSTANCE)

# -- MVTools（大変怪しい） --
SetFilterMTMode("MSuper",              MT_SERIALIZED)
SetFilterMTMode("MAnalyse",            MT_SERIALIZED)
SetFilterMTMode("MFlowInter",          MT_SERIALIZED)
SetFilterMTMode("MFlowBlur",           MT_SERIALIZED)
SetFilterMTMode("MRecalculate",        MT_SERIALIZED)
SetFilterMTMode("MDegrain1",           MT_SERIALIZED) # mode2の方がかなり速いけど動作が怪しいような
SetFilterMTMode("MDegrain2",           MT_SERIALIZED)
SetFilterMTMode("MDegrain3",           MT_SERIALIZED)
