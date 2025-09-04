# NematodeMovementAnalysis_v1
A pipeline to extract and analyze body postures from recordings of crawling C. elegans worms.

  ## Introduction
  This is a compilation of MATLAB scripts to identify individual C. elegans worms in recordings and analyze the posture dynamics.
  This script has been used in the publication "The First of Us: Ophiocordyceps use a novel scramblase-binding peptide to manipulate zombie ants" by WC Beckerson et al.
  The pipeline includes the following steps:
  1) crop input file to region of interest specified by user
  2)


  ## Tutorial
  The tutorial illustrates the use of the whole pipeline. We provide example data of WT C. elegans worms (to be precise: young adult worms of the CGC1 strain, previously fed with RosettaTM 2 bacteria transformed with the empty pET-22b vector), which can be found here: ??? (44GB). The example data constitutes 1min recording of multiple worms on an NGM plate as tiff files of 5120x5120 pixels with a frame rate of 30fps.

  First, the user specifies the region of worm movement in every file and the images are cut and saved as h5-files.
  The inputfolder is the a folder with subfolders of tiff-files corresponding to each measurement.
  The h5-files have the same name as the subfolders plus the region of interest and are saved in the outputfolder.
  It is also the first tiff image copied as a reference.
  Further input is an intensity threshold to identify objects and a frame rate at which the movement is inspected.
  ```
  Crop2PathTiff2H5(inputfolder, outputfolder, imagethreshold, inspectionrate)
  ```

  

  ## Other scripts
  Besides the main pipeline, we also provide additional scripts.
  * SaveTiffAsH5.m : allows to convert a specified folder of tiff-files into a h5 files.

