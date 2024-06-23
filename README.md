<h1>Ffmpeg batch job script with added functionality.</h1>

<p>A quite a simple program for ffmpeg batch jobs, with some added functionality.</p>

<p>Added functions include size difference mode, where the size of the newly created file(s) is compared to the originals size and the larger file is deleted.</p>

<p>While using "*" as an input extension the program will iterate over any files in the source folder, while ignoring all files which are not compatible ffmpeg. If you were to use "*" as an output extension, then the program will not change the file extension.</p>


<p>Here is the help prompt from the program.</p>
<p>Usage: ffmpeg-batch [-h] [-s] [-i] [-o] srcExt destExt srcDir destDir

  -h		show this help text
  -s		compare the size difference of the original and formatted file and delete the larger file
  -i <args>	The input arguments for ffmpeg
  -o <args>	The output arguments fo ffmpeg
  srcExt	source extension of the targeted files
  destExt	destination extension of the formatted files
  srcDir	source directory
  destDir	destination directory

To use wildcard '*' as an extension, you either need to escape it '\*' or use quotes. Using the '*' wildcard as the output extension, will make the program use the same extension as is in the original file.</p>
