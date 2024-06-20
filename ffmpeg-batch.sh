#!/bin/bash
set -e

#Todo:
#	1. Make it possible for "*" to be valid input destination extension. The intented behaviour should be to use the same extension for the destination as is in the original file.

SIZE_COMPARISON=false
SAME_EXTENSION=false

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
else
	srcDir="$srcDir""/*.""$srcExt"
fi

if [[ $destExt == "*" ]]; then
	SAME_EXTENSION=true
fi

for filename in $srcDir; do

	basePath=${filename%.*}
	baseName=${basePath##*/}

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
