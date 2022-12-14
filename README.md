# Scripts to correct for *B*-matrix overflow
Matlab scripts to read *b*-values and *b*-vectors from Siemens raw data (twix) files and DICOMs which work even for very large *b*-values.

The scripts account for an integer overflow situation that can occur when *b*-values of more than about 16,000 s/mm<sup>2</sup> are used.
This is not usually achievable with Siemens product diffusion sequences as they seem to be limited to a maximum *b*-value of 10,000 s/mm<sup>2</sup>.
However some user sequences (especially those installed on Connectom scanners) override this limitation in order to make best use of the possibilities of the scanner.
*b*-values above about 49,000 s/mm<sup>2</sup> will still have problems with integer overflow which these scripts will not be able to correct for.

For *b*-values from around 16,000 to 30,000 s/mm<sup>2</sup> the main effect of this bug seems to be just a flip of the polarity of the affected vectors.
This means that diffusion metrics are largely unaffected because conventional diffusion encoding does not encode polarity.
However using the corrected vectors should improve eddy-current correction (using e.g. [eddy](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy)) and thus improve data quality.

## Usage
### Read from folder containing DICOM files
```matlab
readBvecsFromDicom('input_dicom_folder/', 'output_folder/', 'output_name');
```
will read in all the DICOM files in the input folder `input_dicom_folder` and write out the *b*-vectors and *b*-values to `output_folder/output_name.bvec` and `output_folder/output_name.bval`, respectively.

Notes:
- The input folder must only contain DICOM files. 
- The DICOM files in the input folder must correspond to only one acquisition, otherwise the *b*-vectors and *b*-values from multiple acquisitions would be concatenated.
- If there are multiple files per volume (e.g. because the mosaic output option was not used on the scanner) then there will be one *b*-vector and *b*-value per image (slice) rather than per volume in the output files.
- Acquisition order is not (currently) checked; it is assumed that this matches the order of the files returned by running [`dir`](https://mathworks.com/help/matlab/ref/dir.html) on the input folder.
- The Siemens CSA DICOM fields `B_value`, `B_matrix`, and `DiffusionGradientDirection` must be present in the DICOM files.
- Due to differences in the definition of NIfTi and DICOM image spaces, the polarity of the output vectors may need to be flipped to use them to process NIfTi-converted data. This should be carefully checked by the user, e.g. by using [`dwigradcheck`](https://mrtrix.readthedocs.io/en/latest/reference/commands/dwigradcheck.html) from [MRtrix3](https://mrtrix.readthedocs.io/en/latest/index.html) or through [visual inspection of the output vector orientations from a DTI fit](http://camino.cs.ucl.ac.uk/index.php?n=Tutorials.DTI#dt_fit).

Optionally a 3×3 transformation matrix may be supplied which will rotate/flip the *b*-vectors before saving them.
As an example, the following code would flip the second component of the *b*-vectors:
```matlab
T = diag([1,-1,1]);
readBvecsFromDicom('input_dicom_folder/', 'output_folder/', 'output_name', T);
```

### Read from twix file
```matlab
readBvecsFromTwix('input_twix_folder/', 'input_twix_file.dat', 'output_folder/');
```
will read in the twix file `input_twix_folder/input_twix_file.dat` and write out the *b*-vectors and *b*-values of the last acquired line in each repetition to `output_folder/input_twix_file.bvec` and `output_folder/input_twix_file.bval`, respectively.

Notes:
- [mapVBVD](https://github.com/pehses/mapVBVD) is used to read the twix file (see [Dependencies](#dependencies) below).
- This script assumes that different diffusion encodings are indexed by the "repetition" index.
- A transformation matrix may be supplied in the same way as in the DICOM example.

## Installation
This toolbox can be installed using git. 
First navigate to an appropriate directory and then run:
```
git clone https://github.com/lukeje/correctBmatrixOverflow
```
The folder `correctBmatrixOverflow` should then be added to your [Matlab path](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html).

Alternatively the code can be downloaded as a [zip file](https://github.com/lukeje/correctBmatrixOverflow/archive/refs/heads/main.zip).
After unzipping the code to an appropriate directory, the folder `correctBmatrixOverflow-main` should then be added to your [Matlab path](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html).

## Dependencies
`readBvecsFromDicom` requires the Matlab [image processing toolbox](https://mathworks.com/help/images/index.html).

`readBvecsFromTwix` requires [mapVBVD](https://github.com/pehses/mapVBVD) to be on the [Matlab path](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) in order to read *b*-values and *b*-vectors from Siemens twix files.

## Current status
These scripts have only been tested on data from a Siemens Connectom scanner with software version VD11, where they were found to be able to correct the *b*-vectors measured at a *b*-value of 30,450 s/mm<sup>2</sup>.
Different software versions and sequences may differ in the information contained in the twix and DICOM headers, and therefore not work.
It is the responsibility of the user to check that the results of using these scripts are sensible.
