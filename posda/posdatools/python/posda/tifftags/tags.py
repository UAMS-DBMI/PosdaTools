tags = (
                (11, 'ProcessingSoftware'),
                (254, 'NewSubfileType'),
                (255, 'SubfileType'),
                (256, 'ImageWidth'),
                (257, 'ImageLength'),
                (258, 'BitsPerSample'),
                (259, 'Compression'),
                (262, 'PhotometricInterpretation'),
                (263, 'Thresholding'),
                (264, 'CellWidth'),
                (265, 'CellLength'),
                (266, 'FillOrder'),
                (269, 'DocumentName'),
                (270, 'ImageDescription'),
                (271, 'Make'),
                (272, 'Model'),
                (273, 'StripOffsets'),
                (274, 'Orientation'),
                (277, 'SamplesPerPixel'),
                (278, 'RowsPerStrip'),
                (279, 'StripByteCounts'),
                (280, 'MinSampleValue'),
                (281, 'MaxSampleValue'),
                (282, 'XResolution'),
                (283, 'YResolution'),
                (284, 'PlanarConfiguration'),
                (285, 'PageName'),
                (286, 'XPosition'),
                (287, 'YPosition'),
                (288, 'FreeOffsets'),
                (289, 'FreeByteCounts'),
                (290, 'GrayResponseUnit'),
                (291, 'GrayResponseCurve'),
                (292, 'T4Options'),
                (293, 'T6Options'),
                (296, 'ResolutionUnit'),
                (297, 'PageNumber'),
                (300, 'ColorResponseUnit'),
                (301, 'TransferFunction'),
                (305, 'Software'),
                (306, 'DateTime'),
                (315, 'Artist'),
                (316, 'HostComputer'),
                (317, 'Predictor'),
                (318, 'WhitePoint'),
                (319, 'PrimaryChromaticities'),
                (320, 'ColorMap'),
                (321, 'HalftoneHints'),
                (322, 'TileWidth'),
                (323, 'TileLength'),
                (324, 'TileOffsets'),
                (325, 'TileByteCounts'),
                (326, 'BadFaxLines'),
                (327, 'CleanFaxData'),
                (328, 'ConsecutiveBadFaxLines'),
                (330, 'SubIFDs'),
                (332, 'InkSet'),
                (333, 'InkNames'),
                (334, 'NumberOfInks'),
                (336, 'DotRange'),
                (337, 'TargetPrinter'),
                (338, 'ExtraSamples'),
                (339, 'SampleFormat'),
                (340, 'SMinSampleValue'),
                (341, 'SMaxSampleValue'),
                (342, 'TransferRange'),
                (343, 'ClipPath'),
                (344, 'XClipPathUnits'),
                (345, 'YClipPathUnits'),
                (346, 'Indexed'),
                (347, 'JPEGTables'),
                (351, 'OPIProxy'),
                (400, 'GlobalParametersIFD'),
                (401, 'ProfileType'),
                (402, 'FaxProfile'),
                (403, 'CodingMethods'),
                (404, 'VersionYear'),
                (405, 'ModeNumber'),
                (433, 'Decode'),
                (434, 'DefaultImageColor'),
                (435, 'T82Options'),
                (437, 'JPEGTables2'),  # 347
                (512, 'JPEGProc'),
                (513, 'JPEGInterchangeFormat'),
                (514, 'JPEGInterchangeFormatLength'),
                (515, 'JPEGRestartInterval'),
                (517, 'JPEGLosslessPredictors'),
                (518, 'JPEGPointTransforms'),
                (519, 'JPEGQTables'),
                (520, 'JPEGDCTables'),
                (521, 'JPEGACTables'),
                (529, 'YCbCrCoefficients'),
                (530, 'YCbCrSubSampling'),
                (531, 'YCbCrPositioning'),
                (532, 'ReferenceBlackWhite'),
                (559, 'StripRowCounts'),
                (700, 'XMP'),  # XMLPacket
                (769, 'GDIGamma'),  # GDI+
                (770, 'ICCProfileDescriptor'),  # GDI+
                (771, 'SRGBRenderingIntent'),  # GDI+
                (800, 'ImageTitle'),  # GDI+
                (999, 'USPTO_Miscellaneous'),
                (4864, 'AndorId'),  # TODO, Andor Technology 4864 - 5030
                (4869, 'AndorTemperature'),
                (4876, 'AndorExposureTime'),
                (4878, 'AndorKineticCycleTime'),
                (4879, 'AndorAccumulations'),
                (4881, 'AndorAcquisitionCycleTime'),
                (4882, 'AndorReadoutTime'),
                (4884, 'AndorPhotonCounting'),
                (4885, 'AndorEmDacLevel'),
                (4890, 'AndorFrames'),
                (4896, 'AndorHorizontalFlip'),
                (4897, 'AndorVerticalFlip'),
                (4898, 'AndorClockwise'),
                (4899, 'AndorCounterClockwise'),
                (4904, 'AndorVerticalClockVoltage'),
                (4905, 'AndorVerticalShiftSpeed'),
                (4907, 'AndorPreAmpSetting'),
                (4908, 'AndorCameraSerial'),
                (4911, 'AndorActualTemperature'),
                (4912, 'AndorBaselineClamp'),
                (4913, 'AndorPrescans'),
                (4914, 'AndorModel'),
                (4915, 'AndorChipSizeX'),
                (4916, 'AndorChipSizeY'),
                (4944, 'AndorBaselineOffset'),
                (4966, 'AndorSoftwareVersion'),
                (18246, 'Rating'),
                (18247, 'XP_DIP_XML'),
                (18248, 'StitchInfo'),
                (18249, 'RatingPercent'),
                (20481, 'ResolutionXUnit'),  # GDI+
                (20482, 'ResolutionYUnit'),  # GDI+
                (20483, 'ResolutionXLengthUnit'),  # GDI+
                (20484, 'ResolutionYLengthUnit'),  # GDI+
                (20485, 'PrintFlags'),  # GDI+
                (20486, 'PrintFlagsVersion'),  # GDI+
                (20487, 'PrintFlagsCrop'),  # GDI+
                (20488, 'PrintFlagsBleedWidth'),  # GDI+
                (20489, 'PrintFlagsBleedWidthScale'),  # GDI+
                (20490, 'HalftoneLPI'),  # GDI+
                (20491, 'HalftoneLPIUnit'),  # GDI+
                (20492, 'HalftoneDegree'),  # GDI+
                (20493, 'HalftoneShape'),  # GDI+
                (20494, 'HalftoneMisc'),  # GDI+
                (20495, 'HalftoneScreen'),  # GDI+
                (20496, 'JPEGQuality'),  # GDI+
                (20497, 'GridSize'),  # GDI+
                (20498, 'ThumbnailFormat'),  # GDI+
                (20499, 'ThumbnailWidth'),  # GDI+
                (20500, 'ThumbnailHeight'),  # GDI+
                (20501, 'ThumbnailColorDepth'),  # GDI+
                (20502, 'ThumbnailPlanes'),  # GDI+
                (20503, 'ThumbnailRawBytes'),  # GDI+
                (20504, 'ThumbnailSize'),  # GDI+
                (20505, 'ThumbnailCompressedSize'),  # GDI+
                (20506, 'ColorTransferFunction'),  # GDI+
                (20507, 'ThumbnailData'),
                (20512, 'ThumbnailImageWidth'),  # GDI+
                (20513, 'ThumbnailImageHeight'),  # GDI+
                (20514, 'ThumbnailBitsPerSample'),  # GDI+
                (20515, 'ThumbnailCompression'),
                (20516, 'ThumbnailPhotometricInterp'),  # GDI+
                (20517, 'ThumbnailImageDescription'),  # GDI+
                (20518, 'ThumbnailEquipMake'),  # GDI+
                (20519, 'ThumbnailEquipModel'),  # GDI+
                (20520, 'ThumbnailStripOffsets'),  # GDI+
                (20521, 'ThumbnailOrientation'),  # GDI+
                (20522, 'ThumbnailSamplesPerPixel'),  # GDI+
                (20523, 'ThumbnailRowsPerStrip'),  # GDI+
                (20524, 'ThumbnailStripBytesCount'),  # GDI+
                (20525, 'ThumbnailResolutionX'),
                (20526, 'ThumbnailResolutionY'),
                (20527, 'ThumbnailPlanarConfig'),  # GDI+
                (20528, 'ThumbnailResolutionUnit'),
                (20529, 'ThumbnailTransferFunction'),
                (20530, 'ThumbnailSoftwareUsed'),  # GDI+
                (20531, 'ThumbnailDateTime'),  # GDI+
                (20532, 'ThumbnailArtist'),  # GDI+
                (20533, 'ThumbnailWhitePoint'),  # GDI+
                (20534, 'ThumbnailPrimaryChromaticities'),  # GDI+
                (20535, 'ThumbnailYCbCrCoefficients'),  # GDI+
                (20536, 'ThumbnailYCbCrSubsampling'),  # GDI+
                (20537, 'ThumbnailYCbCrPositioning'),
                (20538, 'ThumbnailRefBlackWhite'),  # GDI+
                (20539, 'ThumbnailCopyRight'),  # GDI+
                (20545, 'InteroperabilityIndex'),
                (20546, 'InteroperabilityVersion'),
                (20624, 'LuminanceTable'),
                (20625, 'ChrominanceTable'),
                (20736, 'FrameDelay'),  # GDI+
                (20737, 'LoopCount'),  # GDI+
                (20738, 'GlobalPalette'),  # GDI+
                (20739, 'IndexBackground'),  # GDI+
                (20740, 'IndexTransparent'),  # GDI+
                (20752, 'PixelUnit'),  # GDI+
                (20753, 'PixelPerUnitX'),  # GDI+
                (20754, 'PixelPerUnitY'),  # GDI+
                (20755, 'PaletteHistogram'),  # GDI+
                (28672, 'SonyRawFileType'),  # Sony ARW
                (28722, 'VignettingCorrParams'),  # Sony ARW
                (28725, 'ChromaticAberrationCorrParams'),  # Sony ARW
                (28727, 'DistortionCorrParams'),  # Sony ARW
                # Private tags >= 32768
                (32781, 'ImageID'),
                (32931, 'WangTag1'),
                (32932, 'WangAnnotation'),
                (32933, 'WangTag3'),
                (32934, 'WangTag4'),
                (32953, 'ImageReferencePoints'),
                (32954, 'RegionXformTackPoint'),
                (32955, 'WarpQuadrilateral'),
                (32956, 'AffineTransformMat'),
                (32995, 'Matteing'),
                (32996, 'DataType'),  # use SampleFormat
                (32997, 'ImageDepth'),
                (32998, 'TileDepth'),
                (33300, 'ImageFullWidth'),
                (33301, 'ImageFullLength'),
                (33302, 'TextureFormat'),
                (33303, 'TextureWrapModes'),
                (33304, 'FieldOfViewCotangent'),
                (33305, 'MatrixWorldToScreen'),
                (33306, 'MatrixWorldToCamera'),
                (33405, 'Model2'),
                (33421, 'CFARepeatPatternDim'),
                (33422, 'CFAPattern'),
                (33423, 'BatteryLevel'),
                (33424, 'KodakIFD'),
                (33434, 'ExposureTime'),
                (33437, 'FNumber'),
                (33432, 'Copyright'),
                (33445, 'MDFileTag'),
                (33446, 'MDScalePixel'),
                (33447, 'MDColorTable'),
                (33448, 'MDLabName'),
                (33449, 'MDSampleInfo'),
                (33450, 'MDPrepDate'),
                (33451, 'MDPrepTime'),
                (33452, 'MDFileUnits'),
                (33465, 'NiffRotation'),  # NIFF
                (33466, 'NiffNavyCompression'),  # NIFF
                (33467, 'NiffTileIndex'),  # NIFF
                (33471, 'OlympusINI'),
                (33550, 'ModelPixelScaleTag'),
                (33560, 'OlympusSIS'),  # see also 33471 and 34853
                (33589, 'AdventScale'),
                (33590, 'AdventRevision'),
                (33628, 'UIC1tag'),  # Metamorph  Universal Imaging Corp STK
                (33629, 'UIC2tag'),
                (33630, 'UIC3tag'),
                (33631, 'UIC4tag'),
                (33723, 'IPTCNAA'),
                (33858, 'ExtendedTagsOffset'),  # DEFF points IFD with tags
                (33918, 'IntergraphPacketData'),  # INGRPacketDataTag
                (33919, 'IntergraphFlagRegisters'),  # INGRFlagRegisters
                (33920, 'IntergraphMatrixTag'),  # IrasBTransformationMatrix
                (33921, 'INGRReserved'),
                (33922, 'ModelTiepointTag'),
                (33923, 'LeicaMagic'),
                (34016, 'Site'),  # 34016..34032 ANSI IT8 TIFF/IT
                (34017, 'ColorSequence'),
                (34018, 'IT8Header'),
                (34019, 'RasterPadding'),
                (34020, 'BitsPerRunLength'),
                (34021, 'BitsPerExtendedRunLength'),
                (34022, 'ColorTable'),
                (34023, 'ImageColorIndicator'),
                (34024, 'BackgroundColorIndicator'),
                (34025, 'ImageColorValue'),
                (34026, 'BackgroundColorValue'),
                (34027, 'PixelIntensityRange'),
                (34028, 'TransparencyIndicator'),
                (34029, 'ColorCharacterization'),
                (34030, 'HCUsage'),
                (34031, 'TrapIndicator'),
                (34032, 'CMYKEquivalent'),
                (34118, 'CZ_SEM'),  # Zeiss SEM
                (34152, 'AFCP_IPTC'),
                (34232, 'PixelMagicJBIGOptions'),  # EXIF, also TI FrameCount
                (34263, 'JPLCartoIFD'),
                (34122, 'IPLAB'),  # number of images
                (34264, 'ModelTransformationTag'),
                (34306, 'WB_GRGBLevels'),  # Leaf MOS
                (34310, 'LeafData'),
                (34361, 'MM_Header'),
                (34362, 'MM_Stamp'),
                (34363, 'MM_Unknown'),
                (34377, 'ImageResources'),  # Photoshop
                (34386, 'MM_UserBlock'),
                (34412, 'CZ_LSMINFO'),
                (34665, 'ExifTag'),
                (34675, 'InterColorProfile'),  # ICCProfile
                (34680, 'FEI_SFEG'),  #
                (34682, 'FEI_HELIOS'),  #
                (34683, 'FEI_TITAN'),  #
                (34687, 'FXExtensions'),
                (34688, 'MultiProfiles'),
                (34689, 'SharedData'),
                (34690, 'T88Options'),
                (34710, 'MarCCD'),  # offset to MarCCD header
                (34732, 'ImageLayer'),
                (34735, 'GeoKeyDirectoryTag'),
                (34736, 'GeoDoubleParamsTag'),
                (34737, 'GeoAsciiParamsTag'),
                (34750, 'JBIGOptions'),
                (34821, 'PIXTIFF'),  # ? Pixel Translations Inc
                (34850, 'ExposureProgram'),
                (34852, 'SpectralSensitivity'),
                (34853, 'GPSTag'),  # GPSIFD  also OlympusSIS2
                (34853, 'OlympusSIS2'),
                (34855, 'ISOSpeedRatings'),
                (34855, 'PhotographicSensitivity'),
                (34856, 'OECF'),  # optoelectric conversion factor
                (34857, 'Interlace'),  # TIFF/EP
                (34858, 'TimeZoneOffset'),  # TIFF/EP
                (34859, 'SelfTimerMode'),  # TIFF/EP
                (34864, 'SensitivityType'),
                (34865, 'StandardOutputSensitivity'),
                (34866, 'RecommendedExposureIndex'),
                (34867, 'ISOSpeed'),
                (34868, 'ISOSpeedLatitudeyyy'),
                (34869, 'ISOSpeedLatitudezzz'),
                (34908, 'HylaFAXFaxRecvParams'),
                (34909, 'HylaFAXFaxSubAddress'),
                (34910, 'HylaFAXFaxRecvTime'),
                (34911, 'FaxDcs'),
                (34929, 'FedexEDR'),
                (34954, 'LeafSubIFD'),
                (34959, 'Aphelion1'),
                (34960, 'Aphelion2'),
                (34961, 'AphelionInternal'),  # ADCIS
                (36864, 'ExifVersion'),
                (36867, 'DateTimeOriginal'),
                (36868, 'DateTimeDigitized'),
                (36873, 'GooglePlusUploadCode'),
                (36880, 'OffsetTime'),
                (36881, 'OffsetTimeOriginal'),
                (36882, 'OffsetTimeDigitized'),
                # TODO, Pilatus/CHESS/TV6 36864..37120 conflicting with Exif
                (36864, 'TVX_Unknown'),
                (36865, 'TVX_NumExposure'),
                (36866, 'TVX_NumBackground'),
                (36867, 'TVX_ExposureTime'),
                (36868, 'TVX_BackgroundTime'),
                (36870, 'TVX_Unknown'),
                (36873, 'TVX_SubBpp'),
                (36874, 'TVX_SubWide'),
                (36875, 'TVX_SubHigh'),
                (36876, 'TVX_BlackLevel'),
                (36877, 'TVX_DarkCurrent'),
                (36878, 'TVX_ReadNoise'),
                (36879, 'TVX_DarkCurrentNoise'),
                (36880, 'TVX_BeamMonitor'),
                (37120, 'TVX_UserVariables'),  # A/D values
                (37121, 'ComponentsConfiguration'),
                (37122, 'CompressedBitsPerPixel'),
                (37377, 'ShutterSpeedValue'),
                (37378, 'ApertureValue'),
                (37379, 'BrightnessValue'),
                (37380, 'ExposureBiasValue'),
                (37381, 'MaxApertureValue'),
                (37382, 'SubjectDistance'),
                (37383, 'MeteringMode'),
                (37384, 'LightSource'),
                (37385, 'Flash'),
                (37386, 'FocalLength'),
                (37387, 'FlashEnergy'),  # TIFF/EP
                (37388, 'SpatialFrequencyResponse'),  # TIFF/EP
                (37389, 'Noise'),  # TIFF/EP
                (37390, 'FocalPlaneXResolution'),  # TIFF/EP
                (37391, 'FocalPlaneYResolution'),  # TIFF/EP
                (37392, 'FocalPlaneResolutionUnit'),  # TIFF/EP
                (37393, 'ImageNumber'),  # TIFF/EP
                (37394, 'SecurityClassification'),  # TIFF/EP
                (37395, 'ImageHistory'),  # TIFF/EP
                (37396, 'SubjectLocation'),  # TIFF/EP
                (37397, 'ExposureIndex'),  # TIFF/EP
                (37398, 'TIFFEPStandardID'),  # TIFF/EP
                (37399, 'SensingMethod'),  # TIFF/EP
                (37434, 'CIP3DataFile'),
                (37435, 'CIP3Sheet'),
                (37436, 'CIP3Side'),
                (37439, 'StoNits'),
                (37500, 'MakerNote'),
                (37510, 'UserComment'),
                (37520, 'SubsecTime'),
                (37521, 'SubsecTimeOriginal'),
                (37522, 'SubsecTimeDigitized'),
                (37679, 'MODIText'),  # Microsoft Office Document Imaging
                (37680, 'MODIOLEPropertySetStorage'),
                (37681, 'MODIPositioning'),
                (37706, 'TVIPS'),  # offset to TemData structure
                (37707, 'TVIPS1'),
                (37708, 'TVIPS2'),  # same TemData structure as undefined
                (37724, 'ImageSourceData'),  # Photoshop
                (37888, 'Temperature'),
                (37889, 'Humidity'),
                (37890, 'Pressure'),
                (37891, 'WaterDepth'),
                (37892, 'Acceleration'),
                (37893, 'CameraElevationAngle'),
                (40000, 'XPos'),  # Janelia
                (40001, 'YPos'),
                (40002, 'ZPos'),
                (40001, 'MC_IpWinScal'),  # Media Cybernetics
                (40001, 'RecipName'),  # MS FAX
                (40002, 'RecipNumber'),
                (40003, 'SenderName'),
                (40004, 'Routing'),
                (40005, 'CallerId'),
                (40006, 'TSID'),
                (40007, 'CSID'),
                (40008, 'FaxTime'),
                (40100, 'MC_IdOld'),
                (40106, 'MC_Unknown'),
                (40965, 'InteroperabilityTag'),  # InteropOffset
                (40091, 'XPTitle'),
                (40092, 'XPComment'),
                (40093, 'XPAuthor'),
                (40094, 'XPKeywords'),
                (40095, 'XPSubject'),
                (40960, 'FlashpixVersion'),
                (40961, 'ColorSpace'),
                (40962, 'PixelXDimension'),
                (40963, 'PixelYDimension'),
                (40964, 'RelatedSoundFile'),
                (40976, 'SamsungRawPointersOffset'),
                (40977, 'SamsungRawPointersLength'),
                (41217, 'SamsungRawByteOrder'),
                (41218, 'SamsungRawUnknown'),
                (41483, 'FlashEnergy'),
                (41484, 'SpatialFrequencyResponse'),
                (41485, 'Noise'),  # 37389
                (41486, 'FocalPlaneXResolution'),  # 37390
                (41487, 'FocalPlaneYResolution'),  # 37391
                (41488, 'FocalPlaneResolutionUnit'),  # 37392
                (41489, 'ImageNumber'),  # 37393
                (41490, 'SecurityClassification'),  # 37394
                (41491, 'ImageHistory'),  # 37395
                (41492, 'SubjectLocation'),  # 37395
                (41493, 'ExposureIndex '),  # 37397
                (41494, 'TIFF-EPStandardID'),
                (41495, 'SensingMethod'),  # 37399
                (41728, 'FileSource'),
                (41729, 'SceneType'),
                (41730, 'CFAPattern'),  # 33422
                (41985, 'CustomRendered'),
                (41986, 'ExposureMode'),
                (41987, 'WhiteBalance'),
                (41988, 'DigitalZoomRatio'),
                (41989, 'FocalLengthIn35mmFilm'),
                (41990, 'SceneCaptureType'),
                (41991, 'GainControl'),
                (41992, 'Contrast'),
                (41993, 'Saturation'),
                (41994, 'Sharpness'),
                (41995, 'DeviceSettingDescription'),
                (41996, 'SubjectDistanceRange'),
                (42016, 'ImageUniqueID'),
                (42032, 'CameraOwnerName'),
                (42033, 'BodySerialNumber'),
                (42034, 'LensSpecification'),
                (42035, 'LensMake'),
                (42036, 'LensModel'),
                (42037, 'LensSerialNumber'),
                (42080, 'CompositeImage'),
                (42081, 'SourceImageNumberCompositeImage'),
                (42082, 'SourceExposureTimesCompositeImage'),
                (42112, 'GDAL_METADATA'),
                (42113, 'GDAL_NODATA'),
                (42240, 'Gamma'),
                (43314, 'NIHImageHeader'),
                (44992, 'ExpandSoftware'),
                (44993, 'ExpandLens'),
                (44994, 'ExpandFilm'),
                (44995, 'ExpandFilterLens'),
                (44996, 'ExpandScanner'),
                (44997, 'ExpandFlashLamp'),
                (48129, 'PixelFormat'),  # HDP and WDP
                (48130, 'Transformation'),
                (48131, 'Uncompressed'),
                (48132, 'ImageType'),
                # (48256, 'ImageWidth'),  # 256
                (48257, 'ImageHeight'),
                (48258, 'WidthResolution'),
                (48259, 'HeightResolution'),
                (48320, 'ImageOffset'),
                (48321, 'ImageByteCount'),
                (48322, 'AlphaOffset'),
                (48323, 'AlphaByteCount'),
                (48324, 'ImageDataDiscard'),
                (48325, 'AlphaDataDiscard'),
                (50003, 'KodakAPP3'),
                (50215, 'OceScanjobDescription'),
                (50216, 'OceApplicationSelector'),
                (50217, 'OceIdentificationNumber'),
                (50218, 'OceImageLogicCharacteristics'),
                (50255, 'Annotations'),
                (50288, 'MC_Id'),  # Media Cybernetics
                (50289, 'MC_XYPosition'),
                (50290, 'MC_ZPosition'),
                (50291, 'MC_XYCalibration'),
                (50292, 'MC_LensCharacteristics'),
                (50293, 'MC_ChannelName'),
                (50294, 'MC_ExcitationWavelength'),
                (50295, 'MC_TimeStamp'),
                (50296, 'MC_FrameProperties'),
                (50341, 'PrintImageMatching'),
                (50495, 'PCO_RAW'),  # TODO, PCO CamWare
                (50547, 'OriginalFileName'),
                (50560, 'USPTO_OriginalContentType'),  # US Patent Office
                (50561, 'USPTO_RotationCode'),
                (50648, 'CR2Unknown1'),
                (50649, 'CR2Unknown2'),
                (50656, 'CR2CFAPattern'),
                (50674, 'LercParameters'),  # ESGI 50674 .. 50677
                (50706, 'DNGVersion'),  # DNG 50706 .. 51114
                (50707, 'DNGBackwardVersion'),
                (50708, 'UniqueCameraModel'),
                (50709, 'LocalizedCameraModel'),
                (50710, 'CFAPlaneColor'),
                (50711, 'CFALayout'),
                (50712, 'LinearizationTable'),
                (50713, 'BlackLevelRepeatDim'),
                (50714, 'BlackLevel'),
                (50715, 'BlackLevelDeltaH'),
                (50716, 'BlackLevelDeltaV'),
                (50717, 'WhiteLevel'),
                (50718, 'DefaultScale'),
                (50719, 'DefaultCropOrigin'),
                (50720, 'DefaultCropSize'),
                (50721, 'ColorMatrix1'),
                (50722, 'ColorMatrix2'),
                (50723, 'CameraCalibration1'),
                (50724, 'CameraCalibration2'),
                (50725, 'ReductionMatrix1'),
                (50726, 'ReductionMatrix2'),
                (50727, 'AnalogBalance'),
                (50728, 'AsShotNeutral'),
                (50729, 'AsShotWhiteXY'),
                (50730, 'BaselineExposure'),
                (50731, 'BaselineNoise'),
                (50732, 'BaselineSharpness'),
                (50733, 'BayerGreenSplit'),
                (50734, 'LinearResponseLimit'),
                (50735, 'CameraSerialNumber'),
                (50736, 'LensInfo'),
                (50737, 'ChromaBlurRadius'),
                (50738, 'AntiAliasStrength'),
                (50739, 'ShadowScale'),
                (50740, 'DNGPrivateData'),
                (50741, 'MakerNoteSafety'),
                (50752, 'RawImageSegmentation'),
                (50778, 'CalibrationIlluminant1'),
                (50779, 'CalibrationIlluminant2'),
                (50780, 'BestQualityScale'),
                (50781, 'RawDataUniqueID'),
                (50784, 'AliasLayerMetadata'),
                (50827, 'OriginalRawFileName'),
                (50828, 'OriginalRawFileData'),
                (50829, 'ActiveArea'),
                (50830, 'MaskedAreas'),
                (50831, 'AsShotICCProfile'),
                (50832, 'AsShotPreProfileMatrix'),
                (50833, 'CurrentICCProfile'),
                (50834, 'CurrentPreProfileMatrix'),
                (50838, 'IJMetadataByteCounts'),
                (50839, 'IJMetadata'),
                (50844, 'RPCCoefficientTag'),
                (50879, 'ColorimetricReference'),
                (50885, 'SRawType'),
                (50898, 'PanasonicTitle'),
                (50899, 'PanasonicTitle2'),
                (50908, 'RSID'),  # DGIWG
                (50909, 'GEO_METADATA'),  # DGIWG XML
                (50931, 'CameraCalibrationSignature'),
                (50932, 'ProfileCalibrationSignature'),
                (50933, 'ProfileIFD'),  # EXTRACAMERAPROFILES
                (50934, 'AsShotProfileName'),
                (50935, 'NoiseReductionApplied'),
                (50936, 'ProfileName'),
                (50937, 'ProfileHueSatMapDims'),
                (50938, 'ProfileHueSatMapData1'),
                (50939, 'ProfileHueSatMapData2'),
                (50940, 'ProfileToneCurve'),
                (50941, 'ProfileEmbedPolicy'),
                (50942, 'ProfileCopyright'),
                (50964, 'ForwardMatrix1'),
                (50965, 'ForwardMatrix2'),
                (50966, 'PreviewApplicationName'),
                (50967, 'PreviewApplicationVersion'),
                (50968, 'PreviewSettingsName'),
                (50969, 'PreviewSettingsDigest'),
                (50970, 'PreviewColorSpace'),
                (50971, 'PreviewDateTime'),
                (50972, 'RawImageDigest'),
                (50973, 'OriginalRawFileDigest'),
                (50974, 'SubTileBlockSize'),
                (50975, 'RowInterleaveFactor'),
                (50981, 'ProfileLookTableDims'),
                (50982, 'ProfileLookTableData'),
                (51008, 'OpcodeList1'),
                (51009, 'OpcodeList2'),
                (51022, 'OpcodeList3'),
                (51023, 'FibicsXML'),  #
                (51041, 'NoiseProfile'),
                (51043, 'TimeCodes'),
                (51044, 'FrameRate'),
                (51058, 'TStop'),
                (51081, 'ReelName'),
                (51089, 'OriginalDefaultFinalSize'),
                (51090, 'OriginalBestQualitySize'),
                (51091, 'OriginalDefaultCropSize'),
                (51105, 'CameraLabel'),
                (51107, 'ProfileHueSatMapEncoding'),
                (51108, 'ProfileLookTableEncoding'),
                (51109, 'BaselineExposureOffset'),
                (51110, 'DefaultBlackRender'),
                (51111, 'NewRawImageDigest'),
                (51112, 'RawToPreviewGain'),
                (51113, 'CacheBlob'),
                (51114, 'CacheVersion'),
                (51123, 'MicroManagerMetadata'),
                (51125, 'DefaultUserCrop'),
                (51159, 'ZIFmetadata'),  # Objective Pathology Services
                (51160, 'ZIFannotations'),  # Objective Pathology Services
                (51177, 'DepthFormat'),
                (51178, 'DepthNear'),
                (51179, 'DepthFar'),
                (51180, 'DepthUnits'),
                (51181, 'DepthMeasureType'),
                (51182, 'EnhanceParams'),
                (52525, 'ProfileGainTableMap'),  # DNG 1.6
                (52526, 'SemanticName'),  # DNG 1.6
                (52528, 'SemanticInstanceID'),  # DNG 1.6
                (52536, 'MaskSubArea'),  # DNG 1.6
                (52543, 'RGBTables'),  # DNG 1.6
                (52529, 'CalibrationIlluminant3'),  # DNG 1.6
                (52531, 'ColorMatrix3'),  # DNG 1.6
                (52530, 'CameraCalibration3'),  # DNG 1.6
                (52538, 'ReductionMatrix3'),  # DNG 1.6
                (52537, 'ProfileHueSatMapData3'),  # DNG 1.6
                (52532, 'ForwardMatrix3'),  # DNG 1.6
                (52533, 'IlluminantData1'),  # DNG 1.6
                (52534, 'IlluminantData2'),  # DNG 1.6
                (53535, 'IlluminantData3'),  # DNG 1.6
                (55000, 'AperioUnknown55000'),
                (55001, 'AperioMagnification'),
                (55002, 'AperioMPP'),
                (55003, 'AperioScanScopeID'),
                (55004, 'AperioDate'),
                (59932, 'Padding'),
                (59933, 'OffsetSchema'),
                # Reusable Tags 65000-65535
                # (65000,  DimapDocumentXML'),
                # (65001, 'EER_XML'),
                # 65000-65112,  Photoshop Camera RAW EXIF tags
                # (65000, 'OwnerName'),
                # (65001, 'SerialNumber'),
                # (65002, 'Lens'),
                # (65024, 'KodakKDCPrivateIFD'),
                # (65100, 'RawFile'),
                # (65101, 'Converter'),
                # (65102, 'WhiteBalance'),
                # (65105, 'Exposure'),
                # (65106, 'Shadows'),
                # (65107, 'Brightness'),
                # (65108, 'Contrast'),
                # (65109, 'Saturation'),
                # (65110, 'Sharpness'),
                # (65111, 'Smoothness'),
                # (65112, 'MoireFilter'),
                (65200, 'FlexXML'),
)

from enum import IntEnum
# invert it
tags_i = {name: value for value, name in tags}

TiffTag = IntEnum('TiffTag', tags_i)
