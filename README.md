# correctBmatrixOverflow
Matlab scripts to read b-values and b-vectors from Siemens raw data (twix) files and DICOMs.

The scripts account for an integer overflow situation that can occur when b-values of more than about 16,000 s/mm<sup>2</sup> are used.
This is not usually achievable with Siemens product diffusion sequences as they seem to be limited to a maximum b-value of 10,000 s/mm<sup>2</sup>.
However some user sequences (especially those installed on Connectom scanners) override this limitation in order to make best use of the possibilities of the scanner.
b-values above about 49,000 s/mm<sup>2</sup> will still have problems with integer overflow which these scripts will not be able to correct.

These scripts have only been tested on data from a Siemens Connectom scanner with software version VD11 where they were found to be able to correct the b-vectors measured at a b-value of 30,450 s/mm<sup>2</sup>.
