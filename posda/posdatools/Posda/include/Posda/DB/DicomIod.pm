#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DB::DicomIod;
use Posda::DB::Modules;

my $SopHandlers = {
  '1.2.840.10008.5.1.1.29' =>{
    name => 'Hardcopy Grayscale Image Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.1.30' =>{
    name => 'Hardcopy Color Image Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.11.2' => {
    name => 'Color Softcopy Presentation State Storage SOP Class',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.104.1' => {
    name => 'Encapsulated PDF Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.130' => {
    name => 'Enhanced PET Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.67' => {
    name => 'X-Ray Radiation Dose SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1' =>{
    name => 'Computed Radiography Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::CRImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.1' =>{
    name => 'Digital X-Ray Image Storage - For Presentation',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.1.1' =>{
    name => 'Digital X-Ray Image Storage - For Processing',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.2' =>{
    name => 'Digital Mammography X-Ray Image Storage - For Presentation',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.2.1' =>{
    name => 'Digital Mammography X-Ray Image Storage - For Processing',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.3' =>{
    name => 'Digital Intra-oral X-Ray Image Storage - For Presentation',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.1.3.1' =>{
    name => 'Digital Intra-oral X-Ray Image Storage - For Processing',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::DXImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.2' =>{
    name => 'CT Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::ImagePlane,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::CTImage,
      \&Posda::DB::Modules::ContrastBolus,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.3' =>{
    name => 'Ultrasound Multiframe Image Storage - Retired',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.3.1' =>{
    name => 'Ultrasound Multiframe Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.4' =>{
    name => 'MR Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::ImagePlane,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::ContrastBolus,
      \&Posda::DB::Modules::MRImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.4.1' =>{
    name => 'Enhanced MR Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.5' =>{
    name => 'Nuclear Medicine Image Storage - Retired',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.6' =>{
    name => 'Ultrasound Image Storage - Retired',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.6.1' =>{
    name => 'Ultrasound Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::USImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.7' =>{
    name => 'Secondary Capture Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.7.1' =>{
    name => 'Multiframe Single Bit Secondary Capture Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.7.2' =>{
    name => 'Multiframe Grayscale Byte Secondary Capture Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.7.3' =>{
    name => 'Multiframe Grayscale Word Secondary Capture Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.7.4' =>{
    name => 'Multiframe True Color Secondary Capture Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.8' =>{
    name => 'Standalone Overlay Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9' =>{
    name => 'Standalone Curve Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.1.1' =>{
    name => 'Twelve Lead ECG Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.1.2' =>{
    name => 'General ECG Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.1.3' =>{
    name => 'Ambulatory ECG Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::Waveform,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.2.1' =>{
    name => 'Hemodynamic Waveform Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::Waveform,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.3.1' =>{
    name => 'Cardiac Electrophysiology Waveform Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::Waveform,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.4.1' =>{
    name => 'Basic Voice Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Synchronization,
      \&Posda::DB::Modules::WaveformIdentification,
      \&Posda::DB::Modules::Waveform,
      \&Posda::DB::Modules::AcquisitionContext,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.10' =>{
    name => 'Standalone Modality LUT Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.11' =>{
    name => 'Standalone VOI LUT Storage',
    handlers => [
      \&Posda::DB::Modules::Retired,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.11.1' =>{
    name => 'Grayscale Softcopy Presentation State Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::PresentationState,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.12.1' =>{
    name => 'Xray Angiographic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.12.2' =>{
    name => 'Xray RadioFlouroscopic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.12.3' =>{
    name => 'Xray Angiographic Biplane Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.20' =>{
    name => 'Nuclear Medicine Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::ImagePlane,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66' =>{
    name => 'Raw DataStorage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66.1' =>{
    name => 'Spatial Registration Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SpatialRegistration,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66.2' =>{
    name => 'Spatial Fiducials Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SpatialFiducials,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66.3' =>{
    name => 'Deformable Spatial Registration Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SpatialRegistration,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66.4' =>{
    name => 'Segmentation Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::Segmentation,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.66.5' =>{
    name => 'Surface Segmentation Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SurfaceSegmentation,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.67' =>{
    name => 'Real World Mapping Values',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::RealWorldMapping,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.1.1' =>{
    name => 'Visible Light Endoscopic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.1.2' =>{
    name => 'Visible Light Microscopic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.1.3' =>{
    name => 'Visible Light Slide Coordinates Microscopic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.1.4' =>{
    name => 'Visible Light Photographic Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.11' =>{
    name => 'Basic Text SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::SRSeries,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Document,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.22' =>{
    name => 'Enhanced SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::SRSeries,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Document,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.33' =>{
    name => 'Comprehensive SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::SRSeries,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::Document,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.50' =>{
    name => 'Mammography CAD SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.59' =>{
    name => 'Key Object Selection Document Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::KeySeries,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::KeyObjectDocument,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.71' =>{
    name => 'Acquisition Context SR Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.128' =>{
    name => 'Positron Emission Tomography Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::ImagePlane,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::SlopeIntercept,
      \&Posda::DB::Modules::WindowLevel,
      \&Posda::DB::Modules::PetImage,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.129' =>{
    name => 'Standalone PET Curve Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.1' =>{
    name => 'RT Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::FrameOfReference,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.2' =>{
    name => 'RT Dose Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::ImagePixel,
      \&Posda::DB::Modules::ImagePlane,
      \&Posda::DB::Modules::FrameOfReference,
      \&Posda::DB::Modules::RTDose,
      \&Posda::DB::Modules::RTDvh,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.3' =>{
    name => 'RT Structure Set Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::StructureSet,
      \&Posda::DB::Modules::RoiContour,
      \&Posda::DB::Modules::RtRoiObservations,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.4' =>{
    name => 'RT Beams Treatment Record Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.5' =>{
    name => 'RT Plan Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
      \&Posda::DB::Modules::RtPlan,
      \&Posda::DB::Modules::RtPrescription,
      \&Posda::DB::Modules::RtToleranceTables,
      \&Posda::DB::Modules::RtPatientSetup,
      \&Posda::DB::Modules::RtFractionScheme,
      \&Posda::DB::Modules::RtBeams,
      \&Posda::DB::Modules::RtBrachy,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.8' =>{
    name => 'RT Ion Plan Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
#      \&Posda::DB::Modules::RtPlan,
#      \&Posda::DB::Modules::RtPrescription,
#      \&Posda::DB::Modules::RtToleranceTables,
#      \&Posda::DB::Modules::RtPatientSetup,
#      \&Posda::DB::Modules::RtFractionScheme,
#      \&Posda::DB::Modules::RtBeams,
#      \&Posda::DB::Modules::RtBrachy,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.6' =>{
    name => 'RT Brachy Treatment Record Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.481.7' =>{
    name => 'RT Treatment Summary Record Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.1' =>{
    name => 'Visible Light Image Storage - Trial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.77.2' =>{
    name => 'Visible Light Multiframe Image Storage - Trial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.9.1' =>{
    name => 'WaveformStorageTrial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.1' =>{
    name => 'TextSRStorageTrial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.2' =>{
    name => 'AudioSRStorageTrial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.3' =>{
    name => 'DetailSRStorageTrial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.88.4' =>{
    name => 'ComprehensiveSRStorageTrial',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.2.1' =>{
    name => 'Enhanced CT Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
  '1.2.840.10008.5.1.4.1.1.13.1.3' =>{
    name => 'Breast Tomosynthesis Image Storage',
    handlers => [
      \&Posda::DB::Modules::Patient,
      \&Posda::DB::Modules::Study,
      \&Posda::DB::Modules::Series,
      \&Posda::DB::Modules::Equipment,
    ],
  },
};
my $sop_common_parms = {
  spec_char_set => "(0008,0005)",
  sop_class => "(0008,0016)",
  sop_instance => "(0008,0018)",
  creation_date => "(0008,0012)",
  creation_time => "(0008,0013)",
  creator_uid => "(0008,0014)",
  related_general_sop_class => "(0008,001a)",
  orig_spec_sop_class => "(0008,001b)",
  offset_from_utc => "(0008,0201)",
  instance_number => "(0020,0013)",
  instance_status => "(0100,0410)",
  auth_date_time => "(0100,0420)",
  auth_comment => "(0100,0424)",
  auth_cert_num => "(0100,0426)",
};
my $ctp_params = {
  project_name => '(0013,"CTP",10)',
  trial_name => '(0013,"CTP",11)',
  site_name => '(0013,"CTP",12)',
  site_id => '(0013,"CTP",13)',
  file_visibility => '(0013,"CTP",14)',
  batch => '(0013,"CTP",15)',
  study_year => '(0013,"CTP",50)',
};
sub Import{
  my($db, $ds, $id, $sop_class, $desc, $ieid) = @_;
  my $ins_ctp = $db->prepare(
    "insert into ctp_file(\n" .
    "  file_id, project_name, trial_name, site_name, site_id,\n".
    "  file_visibility, batch, study_year\n".
    ") values (?, ?, ?, ?, ?, ?, ?, ?)"
  );
  my $ins_sop_common = $db->prepare(
    "insert into file_sop_common\n" .
    "  (file_id, sop_class_uid, sop_instance_uid,\n" .
    "   specific_character_set, creation_date, creation_time,\n" .
    "   creator_uid, related_general_sop_class, " .
    "      original_specialized_sop_class,\n" .
    "   offset_from_utc, instance_number, instance_status,\n" .
    "   auth_date_time, auth_comment, auth_cert_num)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?)"
  );
  my %ctp_parms;
  my @ctp_errors;
  for my $i (keys %$ctp_params){
    my $value = $ds->Get($ctp_params->{$i});
    $ctp_parms{$i} = $value;
  }
  if(
    (defined($ctp_parms{project_name}) && $ctp_parms{project_name} ne "") ||
    (defined($ctp_parms{trial_name}) && $ctp_parms{trial_name} ne "" ) ||
    (defined($ctp_parms{site_name}) && $ctp_parms{site_name} ne "") ||
    (defined($ctp_parms{site_id}) && $ctp_parms{site_id} ne "") ||
    (defined($ctp_parms{file_visibility}) 
      && $ctp_parms{file_visibility} ne "") ||
    (defined($ctp_parms{visibility}) && $ctp_parms{visibility} ne "")
  ){
    $ins_ctp->execute(
      $id, $ctp_parms{project_name}, $ctp_parms{trial_name},
      $ctp_parms{site_name}, $ctp_parms{site_id}, $ctp_parms{file_visibility},
      $ctp_parms{batch}, $ctp_parms{study_year}
    );
  }
  my %parms;
  my @errors;
  for my $i (keys %$sop_common_parms){
    my $value = $ds->ExtractElementBySig($sop_common_parms->{$i});
    $parms{$i} = $value;
  }
  if(ref($parms{spec_char_set}) eq "ARRAY"){
    $parms{spec_char_set} = join("\\", @{$parms{spec_char_set}});
  }
  if(
    defined($parms{creation_time}) && 
    $parms{creation_time} =~ /^(\d\d)(\d\d)(\d\d)$/
  ){
    $parms{creation_time} = "$1:$2:$3";
  } elsif (
    defined($parms{creation_time}) && 
    $parms{creation_time} =~ /^(\d\d)(\d\d)(\d\d)\.(\d+)$/
  ){
    $parms{creation_time} = "$1:$2:$3.$4";
  } elsif (defined $parms{creation_time}){
    push(@errors, "Illegal creation time: \"$parms{creation_time}\"");
    $parms{creation_time} = undef;
  }
  if(
    defined($parms{creation_date}) && 
    $parms{creation_date} =~ /^(\d\d\d\d)(\d\d)(\d\d)$/
  ){
    my $y = $1; my $m = $2; my $d = $3;
    if($m >0 && $m < 13 && $d > 0 && $d < 32){
      $parms{creation_date} = "$y/$m/$d";
    } else {
      push(@errors, "Illegal creation date: \"$parms{creation_date}\"");
      delete $parms{creation_date};
    }
  } elsif(defined $parms{creation_date}) {
    push(@errors, "Illegal creation date: $parms{creation_date}");
    delete $parms{creation_date};
  }
  if($parms{sop_class} =~ /\s/){
    push(@errors, "Sop class has a space: \"$parms{sop_class}\"");
    $sop_class = $parms{sop_class};
    $sop_class =~ s/\s//g;
    $parms{sop_class} = $sop_class;
    push(@errors, "substitution: \"$parms{sop_class}\"");
  }
  if(
    exists($parms{related_general_sop_class}) &&
    ref($parms{related_general_sop_class}) eq "ARRAY"
  ){
    $parms{related_general_sop_class} = 
      join("\\", @{$parms{related_general_sop_class}});
  }
  if(defined($parms{sop_class}) && defined($parms{sop_instance})){
    $ins_sop_common->execute(
      $id, $parms{sop_class}, $parms{sop_instance},
      $parms{spec_char_set}, $parms{creation_date}, $parms{creation_time},
      $parms{creator_uid}, $parms{related_general_sop_class},
      $parms{original_specialized_sop_class},
      $parms{offset_from_utc}, $parms{instance_number}, $parms{instance_status},
      $parms{auth_date_time}, $parms{auth_comment}, $parms{auth_cert_num}
    );
    if(
      exists($SopHandlers->{$sop_class}) &&
      exists($SopHandlers->{$sop_class}->{handlers})
    ){
      my $hist = { import_event_id => $ieid };
      for my $handler (@{$SopHandlers->{$sop_class}->{handlers}}){
        &$handler($db, $ds, $id, $hist, \@errors);
      }
    }
    if(exists $SopHandlers->{$sop_class}){
      unless(exists $SopHandlers->{$sop_class}->{handlers}){
        push(@errors,
          "No handlers for $SopHandlers->{$sop_class}->{name} ($sop_class)");
      }
    } else {
      push(@errors, "No handlers (or name) for \"$sop_class\"");
    }
  } else {
    unless($parms{sop_class}){
      push(@errors, "file $id has no SOP class");
    }
    unless($parms{sop_instance}){
      push(@errors, "file $id has no SOP instance");
    }
  }
  my $i_err = $db->prepare(
    "insert into dicom_process_errors(file_id, error_msg) values (?, ?)"
  );
  for my $i (@errors){
    $i_err->execute($id, $i);
  }
}
sub ProcessModules{
  my($db, $ds, $id, $sop_class) = @_;
  my @errors;
  if(
    exists($SopHandlers->{$sop_class}) &&
    exists($SopHandlers->{$sop_class}->{handlers})
  ){
    my $hist = { import_event_id => 1 };
    for my $handler (@{$SopHandlers->{$sop_class}->{handlers}}){
      &$handler($db, $ds, $id, $hist, \@errors);
    }
  }
  my $i_err = $db->prepare(
    "insert into dicom_process_errors(file_id, error_msg) values (?, ?)"
  );
  for my $i (@errors){
    $i_err->execute($id, $i);
  }
}
1;
