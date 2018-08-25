d2v = "__vid__"
aac = "__aud__"
wav = LeftStr(aac, FindStr(aac, "DELAY") + 5) + "0ms_aac.wav"

SetMTMode(2, 0)

### ÉtÉ@ÉCÉãì«Ç›çûÇ› ###
DGDecode_MPEG2Source(d2v)
AudioDub(last, WAVSource(wav))
