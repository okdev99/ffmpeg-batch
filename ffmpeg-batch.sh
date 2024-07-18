#!/bin/bash

#	ffmpeg-batch is bash script for ffmpeg batch jobs, with some added functionality.
#   Copyright (C) 2024  Otto Kuusniemi
#
#   This program is free software: you can redistribute it and/or modify
# 	it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#	Developer contact: okdev99@gmail.com

size_comparison=false
same_extension=false
all_files_in_source=false
move_all_files=false
ffmpeg_supported_extensions=("str" "aa" "aac" "aax" "ac3" "acm" "adf" "adp" "dtk" "ads" "ss2" "adx" "aea" "afc" "aix" "al" "ape" "apl" "mac" "aptx" "aptxhd" "aqt" "ast" "obu" "avi" "avr" "avs" "avs2" "avs3" "bfstm" "bcstm" "binka" "bit" "bitpacked" "bmv" "brstm" "cdg" "cdxl" "xl" "c2" "302" "daud" "dfpwm" "dav" "dss" "dts" "dtshd" "dv" "dif" "cdata" "eac3" "paf" "fap" "flm" "flac" "flv" "fsb" "fwse" "g722" "722" "tco" "rco" "g723_1" "g729" "genh" "gsm" "h261" "h26l" "h264" "264" "avc" "hca" "hevc" "h265" "265" "idf" "ifv" "cgi" "ipu" "sf" "ircam" "ivr" "kux" "669" "amf" "ams" "dbm" "digi" "dmf" "dsm" "dtm" "far" "gdm" "ice" "imf" "it" "j2b" "m15" "mdl" "med" "mmcmp" "mms" "mo3" "mod" "mptm" "mt2" "mtm" "nst" "okt" "plm" "ppm" "psm" "pt36" "sptm" "s3m" "sfx" "sfx2" "st26" "stk" "stm" "stp" "ult" "umx" "wow" "xm" "xpk" "dat" "lvf" "m4v" "mkv" "mk3d" "mka" "mks" "webm" "mca" "mcc" "mjpg" "mjpeg" "mpo" "j2k" "mlp" "mods" "moflex" "mov" "mp4" "m4a" "3gp" "3g2" "mj2" "psp" "m4b" "ism" "ismv" "isma" "f4v" "avif" "mp2" "mp3" "m2a" "mpa" "mpc" "mpl2" "sub" "msf" "mtaf" "ul" "musx" "mvi" "mxg" "v" "nist" "sph" "nsp" "nut" "ogg" "oma" "omg" "aa3" "pjs" "pvf" "yuv" "cif" "qcif" "rgb" "rt" "rsd" "rsd" "rso" "sw" "sb" "smi" "sami" "sbc" "msbc" "sbg" "scc" "sdr2" "sds" "sdx" "ser" "sga" "shn" "vb" "son" "imx" "sln" "stl" "sub" "sub" "sup" "svag" "svs" "tak" "thd" "tta" "ans" "art" "asc" "diz" "ice" "nfo" "vt" "ty" "ty+" "uw" "ub" "v210" "yuv10" "vag" "vc1" "rcv" "viv" "idx" "vpk" "txt" "vqf" "vql" "vqe" "vtt" "wsd" "xmv" "xvag" "yop" "y4m")

while getopts ":hsmi:o:" opt; do
	case $opt in
		h)	echo "Usage: $0 [-h] [-s] [-m] [-i args] [-o args] src_ext dest_ext src_dir dest_dir"
			echo ""
			echo "  -h		show this help text"
			echo "  -s		compare the size difference of the original and formatted file and delete the larger file"
			echo "  -m		move all files with the src_ext from the source folder to the destination folder, will only work if -s option is active"
			echo "  -i <args>	The input arguments for ffmpeg"
			echo "  -o <args>	The output arguments fo ffmpeg"
			echo "  src_ext	source extension of the targeted files"
			echo "  dest_ext	destination extension of the formatted files"
			echo "  src_dir	source directory"
			echo "  dest_dir	destination directory"
			echo ""
			echo "To use wildcard * as an extension, you either need to escape it \* or use quotes. Using the * wildcard as the output extension, will make the program use the same extension as is in the original file."
			echo "When exiting the ffmpeg conversion and the -s option is set then use keyboard interrupt (ctrl + c) to stop ffmpeg, since otherwise the script won't recognise that ffmpeg exited prematurely and comparison should not happen."
			exit 0
			;;
		s)	size_comparison=true
			;;
		m)	move_all_files=true
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

src_ext=$1 #source extension
dest_ext=$2 #destination extension

src_dir=$3 #source directory (path)
dest_dir=$4 #destination directory (path)

if [[ $src_ext == "*" ]]; then
	src_dir="$src_dir""/*"
	all_files_in_source=true
else
	src_dir="$src_dir""/*.""$src_ext"
fi

if [[ $dest_ext == "*" ]]; then
	same_extension=true
fi

for filename in $src_dir; do

	if $all_files_in_source && [[ ! $(echo "${ffmpeg_supported_extensions[@]}" | grep -Fw "${filename##*.}") ]]; then
		continue
	fi

	base_path=${filename%.*}
	base_name=${base_path##*/}

	if $same_extension; then
		dest_ext=${filename##*.}
	fi

	dest_filename="$dest_dir"/"$base_name"."$dest_ext"

	ffmpeg $inOpts -i "$filename" $outOpts "$dest_filename"

	exit_code=$?
	if [ $exit_code != 0 ]; then
		echo "Ffmpeg did not exit normally."
		echo "Exit code: $exit_code"
		exit 1
	fi

	if $size_comparison; then
		src_size=$(stat -c %s "$filename")
		dest_size=$(stat -c %s "$dest_filename")

		if [[ $src_size -gt $dest_size ]]; then
			rm "$filename"
		else
			rm "$dest_filename"
		fi
	fi
done

if $move_all_files && $size_comparison; then
	mv "$src_dir" "$dest_dir"
fi
