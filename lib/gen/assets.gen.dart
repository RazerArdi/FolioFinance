/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/ic_launcher.png
  AssetGenImage get icLauncher =>
      const AssetGenImage('assets/images/Intel_icon.png');


  /// List of all assets
  List<AssetGenImage> get values => [icLauncher];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/General-Dynamics-Symbol.png
  AssetGenImage get generalDynamicsSymbol =>
      const AssetGenImage('assets/images/General-Dynamics-Symbol.png');

  /// File path: assets/images/gog.png
  AssetGenImage get google => const AssetGenImage('assets/images/gog.png');

  /// File path: assets/images/Intel_icon.png
  AssetGenImage get intelIcon =>
      const AssetGenImage('assets/images/Intel_icon.png');

  /// File path: assets/images/Karina.png
  AssetGenImage get karina => const AssetGenImage('assets/images/Karina.png');

  /// File path: assets/images/Logo_umm.png
  AssetGenImage get logoUmm =>
      const AssetGenImage('assets/images/Logo_umm.png');

  /// File path: assets/images/Microsoft.png
  AssetGenImage get microsoft =>
      const AssetGenImage('assets/images/Microsoft.png');

  /// File path: assets/images/Ningning.png
  AssetGenImage get ningning =>
      const AssetGenImage('assets/images/Ningning.png');

  /// File path: assets/images/Winter.png
  AssetGenImage get winter => const AssetGenImage('assets/images/Winter.png');

  /// File path: assets/images/wa.png
  AssetGenImage get wa => const AssetGenImage('assets/images/wa.png');

  /// File path: assets/images/github-logo.png
  AssetGenImage get github_logo => const AssetGenImage('assets/images/github-logo.png');

  /// File path: assets/images/github-logo.png
  AssetGenImage get video => const AssetGenImage('assets/videos/Intro.mp4');

  /// List of all assets
  List<AssetGenImage> get values => [
        generalDynamicsSymbol,
        google,
        intelIcon,
        karina,
        logoUmm,
        microsoft,
        ningning,
        winter,
        wa,
        github_logo,
        video
      ];
}

class Assets {
  Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
