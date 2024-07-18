<h1>Ffmpeg batch job script with added functionality.</h1>

<p>A quite a simple bash program for ffmpeg batch jobs, with some added functionality.</p>
<p>Info on ffmpeg: https://ffmpeg.org/</p>

<p>Added functions include size difference mode, where the size of the newly created file(s) is compared to the originals size and the larger file is deleted.</p>

<p>While using * as an input extension the program will iterate over any files in the source folder, while ignoring all the files which are not compatible with ffmpeg. If you were to use * as an output extension, then the program will not change the file extension.</p>


<p>Here is the help prompt from the program.</p>

```
Usage: ffmpeg-batch [-h] [-s] [-m] [-i args] [-o args] src_ext dest_ext src_dir dest_dir

  -h		show this help text
  -s		compare the size difference of the original and formatted file and delete the larger file
  -m		move all files with the src_ext from the source folder to the destination folder, will only work if -s option is active
  -i <args>	The input arguments for ffmpeg
  -o <args>	The output arguments fo ffmpeg
  src_ext	source extension of the targeted files
  dest_ext	destination extension of the formatted files
  src_dir	source directory
  dest_dir	destination directory

To use wildcard * as an extension, you either need to escape it \* or use quotes. Using the * wildcard as the output extension, will make the program use the same extension as is in the original file.
When exiting the ffmpeg conversion and the -s option is set then use keyboard interrupt (ctrl + c) to stop ffmpeg, since otherwise the script won't recognise that ffmpeg exited prematurely and comparison should not happen.
```
