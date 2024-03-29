# correctBmatrixOverflow changelog
This changelog uses [semantic versioning](https://semver.org/)

## [v0.7.0]
Read bvecs from MRD files converted from Siemens diffusion sequences

## [v0.6.1]
Bugfix because Matlab gives the transpose of the sform/qform.
Only important if pixel dimensions are not all equal.

## [v0.6.0]
- ensure output from DICOM images is in acquisition order
- provide convenience function `transformForNifti` to calculate the required transform to take *b*-vectors from scanner space to NIfTI space

## [v0.5.0]
- Breaking change: `readBvecsFromTwix` now only takes one file argument.
Replace calls using the previous format `readBvecsFromTwix(infolder,infile,outfolder)` with `readBvecsFromTwix(fullfile(infolder,infile),outfolder)`
- Option to provide twix object from mapVBVD rather than a filename to `readBvecsFromTwix`

## [v0.4.0]
Added mapVBVD as a submodule

## [v0.3.0]
- also output nominal *b*-values

## [v0.2.0]
- added ability to apply a transformation before saving *b*-vectors
- removed default DICOM output basename
- increased output precision

## [v0.1.0]
Initial public release
