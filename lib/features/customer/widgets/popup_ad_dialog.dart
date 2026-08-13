import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/popup_ad_model.dart';

// إعلان منبثق يظهر مرة واحدة لكل حملة إعلانية — صورة واحدة أو أكثر بتمرير
// تلقائي ويدوي، وصف اختياري أسفل الصور، وإمكانية الضغط للانتقال لوجهة الإعلان
Future<void> showPopupAdDialog(
  BuildContext context, {
  required PopupAdModel ad,
  VoidCallback? onTapAction,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _PopupAdDialog(ad: ad, onTapAction: onTapAction),
  );
}

class _PopupAdDialog extends StatefulWidget {
  final PopupAdModel ad;
  final VoidCallback? onTapAction;
  const _PopupAdDialog({required this.ad, this.onTapAction});

  @override
  State<_PopupAdDialog> createState() => _PopupAdDialogState();
}

class _PopupAdDialogState extends State<_PopupAdDialog> {
  late final PageController _pageController;
  Timer? _autoTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.ad.autoScroll && widget.ad.imageUrls.length > 1) {
      _autoTimer = Timer.periodic(Duration(seconds: widget.ad.autoScrollSeconds), (_) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (_page + 1) % widget.ad.imageUrls.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final hasCaption = ad.caption != null && ad.caption!.trim().isNotEmpty;
    final hasLink = ad.linkType != PopupAdLinkType.none;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: hasLink
                        ? () {
                            Navigator.pop(context);
                            widget.onTapAction?.call();
                          }
                        : null,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: ad.imageUrls.length,
                            onPageChanged: (i) => setState(() => _page = i),
                            itemBuilder: (_, i) => Image.network(
                              ad.imageUrls[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceLight,
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: AppColors.textHint, size: 40),
                              ),
                            ),
                          ),
                          if (ad.imageUrls.length > 1)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  ad.imageUrls.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    width: i == _page ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == _page
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (hasCaption)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        ad.caption!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          ),
          Positioned(
            top: -14,
            right: -14,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
