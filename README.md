# NematodeMovementAnalysis_v1
A pipeline to extract and analyze body postures from recordings of crawling C. elegans worms.

  ## Introduction
  This is a compilation of MATLAB scripts to identify individual C. elegans worms in recordings and analyze the posture dynamics.
  This script has been used in the publication "The First of Us: Ophiocordyceps use a novel scramblase-binding peptide to manipulate zombie ants" by WC Beckerson et al.
  The pipeline includes the following steps:
  1) crop input file to region of interest specified by user
  2) identify the static background
  3) identify all moving objects
  4) associate objects across frames by spatial proximity
  5) extract time intervals, in which an object is tracked continuously, and link to worm identity
  6) extract midline (skeleton) of the worm
  7) merge all data into one mat-file, which in particular contains the skeleton points from tail to head and the ratio of worm area divided by circumference length for all worms and all time points


  ## Tutorial
  The tutorial illustrates the use of the whole pipeline. We provide example data of WT C. elegans worms (to be precise: young adult worms of the CGC1 strain, previously fed with RosettaTM 2 bacteria transformed with the empty pET-22b vector), which can be found here: ??? (44GB). The example data constitutes 1min recording of multiple worms on an NGM plate as tiff files of 5120x5120 pixels with a frame rate of 30fps.

  First, the user specifies the region of worm movement in every recording and the images are cut and saved as h5-files.
  The inputfolder is a folder with subfolders of tiff-files, where each subfolder corresponds to a recording.
  The h5-files have the same name as the subfolders plus the region of interest and are saved in the outputfolder.
  It is also the first tiff image copied as a reference.
  Further input is an intensity threshold to identify objects and a rate at which the movement is inspected.
  ```
  Crop2PathTiff2H5(inputfolder, outputfolder, imagethreshold, inspectionrate);
  ```
  Next, the background is extracted by taking the 93% quantile intesity for every pixel as the worm is darker then the background (similar to the median but takeing into account that the worm might sit still for 93% of the recording).
  The sampinterval specifies a sub-sampling, such that not the whole data set needs to be loaded (especially if the worm does not move much between frames).
  ```
  [imagebg,diffimage,inputfile]=ExtractBackground(outputpath,dataid, sampinterval);
  ```
  Afterwards, all moving objects are extracted via background subtraction. Small objects are removed. Objects are identified between frames by spatial proximity. If the worm body temporarily splits in two due to tracking errors, this is corrected. Time intervals where the object shows a large size are removed as these instances typically two touching worms or a worm in contact with a dirt particle. Time intervals of continuous tracking are identified. Short intervals are removed and intervals showing the same worm are linked by user input. For each continuous tracking interval a h5-file containing the recording cropped to the worm body. The midline of the worm (i.e. skeleton) is extracted. Finally, the skeleton data is combined in one file for all the worms and all the time points.
  

  ## Other scripts
  Besides the main pipeline, we also provide additional scripts.
  * SaveTiffAsH5.m : allows to convert a specified folder of tiff-files into a h5 files.

