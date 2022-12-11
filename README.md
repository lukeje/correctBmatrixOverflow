# Scripts to correct for *B*-matrix overflow
Matlab scripts to read *b*-values and *b*-vectors from Siemens raw data (twix) files and DICOMs which work even for very large *b*-values.

The scripts account for an integer overflow situation that can occur when *b*-values of more than about 16,000 s/mm<sup>2</sup> are used.
This is not usually achievable with Siemens product diffusion sequences as they seem to be limited to a maximum *b*-value of 10,000 s/mm<sup>2</sup>.
However some user sequences (especially those installed on Connectom scanners) override this limitation in order to make best use of the possibilities of the scanner.
*b*-values above about 49,000 s/mm<sup>2</sup> will still have problems with integer overflow which these scripts will not be able to correct.

## Usage

## Installation
This toolbox can be installed using git. 
First navigate to an appropriate directory and then run:
```
git clone https://github.com/lukeje/correctBmatrixOverflow
```
The folder `correctBmatrixOverflow` should then be added to your [Matlab path](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html).

## Dependencies
This toolbox requires [mapVBVD](https://github.com/pehses/mapVBVD) to be on the  [Matlab path](https://mathworks.com/help/matlab/matlab_env/add-remove-or-reorder-folders-on-the-search-path.html) in order to read *b*-values and *b*-vectors from Siemens twix files.

## Current status
These scripts have only been tested on data from a Siemens Connectom scanner with software version VD11 where they were found to be able to correct the *b*-vectors measured at a *b*-value of 30,450 s/mm<sup>2</sup>.
It is the responsibility of the user to check that the results of using these scripts are sensible.
