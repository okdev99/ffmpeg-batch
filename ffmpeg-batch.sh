#!/bin/bash
set -e

#Todo:
#	1. Make it possible for "*" to be valid input destination extension. The intented behaviour should be to use the same extension for the destination as is in the original file.

SIZE_COMPARISON=false
SAME_EXTENSION=false
ALL_FILES_IN_SOURCE=false
FFMPEG_SUPPORTED_EXTENSIONS=("str" "aa" "aac" "aax" "ac3" "acm" "adf" "adp" "dtk" "ads" "ss2" "adx" "aea" "afc" "aix" "al" "ape" "apl" "mac" "aptx" "aptxhd" "aqt" "ast" "obu" "avi" "avr" "avs" "avs2" "avs3" "bfstm" "bcstm" "binka" "bit" "bitpacked" "bmv" "brstm" "cdg" "cdxl" "xl" "c2" "302" "daud" "dfpwm" "dav" "dss" "dts" "dtshd" "dv" "dif" "cdata" "eac3" "paf" "fap" "flm" "flac" "flv" "fsb" "fwse" "g722" "722" "tco" "rco" "g723_1" "g729" "genh" "gsm" "h261" "h26l" "h264" "264" "avc" "hca" "hevc" "h265" "265" "idf" "ifv" "cgi" "ipu" "sf" "ircam" "ivr" "kux" "669" "amf" "ams" "dbm" "digi" "dmf" "dsm" "dtm" "far" "gdm" "ice" "imf" "it" "j2b" "m15" "mdl" "med" "mmcmp" "mms" "mo3" "mod" "mptm" "mt2" "mtm" "nst" "okt" "plm" "ppm" "psm" "pt36" "sptm" "s3m" "sfx" "sfx2" "st26" "stk" "stm" "stp" "ult" "umx" "wow" "xm" "xpk" "dat" "lvf" "m4v" "mkv" "mk3d" "mka" "mks" "webm" "mca" "mcc" "mjpg" "mjpeg" "mpo" "j2k" "mlp" "mods" "moflex" "mov" "mp4" "m4a" "3gp" "3g2" "mj2" "psp" "m4b" "ism" "ismv" "isma" "f4v" "avif" "mp2" "mp3" "m2a" "mpa" "mpc" "mpl2" "sub" "msf" "mtaf" "ul" "musx" "mvi" "mxg" "v" "nist" "sph" "nsp" "nut" "ogg" "oma" "omg" "aa3" "pjs" "pvf" "yuv" "cif" "qcif" "rgb" "rt" "rsd" "rsd" "rso" "sw" "sb" "smi" "sami" "sbc" "msbc" "sbg" "scc" "sdr2" "sds" "sdx" "ser" "sga" "shn" "vb" "son" "imx" "sln" "stl" "sub" "sub" "sup" "svag" "svs" "tak" "thd" "tta" "ans" "art" "asc" "diz" "ice" "nfo" "vt" "ty" "ty+" "uw" "ub" "v210" "yuv10" "vag" "vc1" "rcv" "viv" "idx" "vpk" "txt" "vqf" "vql" "vqe" "vtt" "wsd" "xmv" "xvag" "yop" "y4m")

while getopts ":hsi:o:" opt; do
	case $opt in
		h)	echo "Usage: $0 [-h] [-s] [-i] [-o] srcExt destExt srcDir destDir"
			echo ""
			echo "  -h		show this help text"
			echo "  -s		compare the size difference of the original and formatted file and delete the larger file"
			echo "  -i <args>	The input arguments for ffmpeg"
			echo "  -o <args>	The output arguments fo ffmpeg"
			echo "  srcExt	source extension of the targeted files"
			echo "  destExt	destination extension of the formatted files"
			echo "  srcDir	source directory"
			echo "  destDir	destination directory"
			echo ""
			echo "To use wildcard '*' as an extension, you either need to escape it '\*' or use quotes. Using the '*' wildcard as the output extension, will make the program use the same extension as is in the original file."
			exit 0
			;;
		s)	SIZE_COMPARISON=true
			;;
		i)	inOpts=$OPTARG
			;;
		o)	outOpts=$OPTARG
			;;
		\?)	echo "Invalid option: -$OPTARG" 1>&2
			exit 1
			;;
		:)	echo "Option -$OPTARG requires an argument." 1>&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

srcExt=$1 #source extension
destExt=$2 #destination extension

srcDir=$3 #source directory (path)
destDir=$4 #destination directory (path)

if [[ $srcExt == "*" ]]; then
	srcDir="$srcDir""/*"
	ALL_FILES_IN_SOURCE=true
else
	srcDir="$srcDir""/*.""$srcExt"
fi

if [[ $destExt == "*" ]]; then
	SAME_EXTENSION=true
fi

for filename in $srcDir; do

	basePath=${filename%.*}
	baseName=${basePath##*/}

	if $ALL_FILES_IN_SOURCE; then
		for i in "${FFMPEG_SUPPORTED_EXTENSIONS[@]}"; do
			if [[ ! $i == ${filename##*.} ]]; then
				continue
			fi
		done
	fi

	if $SAME_EXTENSION; then
		destExt=${filename##*.}
	fi

	destFilename="$destDir"/"$baseName"."$destExt"

	ffmpeg $inOpts -i "$filename" $outOpts "$destFilename"

	if $SIZE_COMPARISON; then
		srcSize=$(stat -c %s "$filename")
		destSize=$(stat -c %s "$destFilename")

		if [[ $srcSize -gt $destSize ]]; then
			rm "$filename"
		else
			rm "$destFilename"
		fi
	fi
done
