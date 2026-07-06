import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../services/video_call_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/web/adaptive_screen.dart';

class VideoCallScreen extends StatefulWidget {
  final String appointmentId;

  const VideoCallScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isLoading = true;
  String? _error;
  String? _joinUrl;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final service = VideoCallService(api);
      final token = await service.getCallToken(widget.appointmentId);

      if (!mounted) return;

      if (token == null) {
        setState(() {
          _error = 'Videoanruf konnte nicht gestartet werden';
          _isLoading = false;
        });
        return;
      }

      final uri = Uri.parse(token.joinUrl);
      final launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );

      if (!mounted) return;

      if (!launched) {
        setState(() {
          _error = 'Videoanruf konnte nicht geöffnet werden';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _joinUrl = token.joinUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reopenCall() async {
    if (_joinUrl == null) return;
    await launchUrl(Uri.parse(_joinUrl!), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScreen(
      title: 'Videoanruf',
      onBack: () => context.pop(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: FigmaUi.rubik(fontSize: 15, color: AppTheme.textColor),
                        ),
                        const SizedBox(height: 20),
                        NeumorphicPillButton(
                          label: 'Zurück',
                          leadingIcon: Icons.arrow_back,
                          expanded: false,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: NeumorphicRaisedCard(
                        height: null,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.videocam_outlined,
                                size: 30,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Der Videoanruf wurde in einem neuen Tab geöffnet.',
                              textAlign: TextAlign.center,
                              style: FigmaUi.rubik(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Falls sich kein neuer Tab geöffnet hat, nutzen Sie den Button unten.',
                              textAlign: TextAlign.center,
                              style: FigmaUi.bodyLight(fontSize: 13, color: AppTheme.textColorSecondary),
                            ),
                            const SizedBox(height: 28),
                            NeumorphicPillButton(
                              label: 'Erneut öffnen',
                              leadingIcon: Icons.open_in_new,
                              onPressed: _reopenCall,
                            ),
                            const SizedBox(height: 12),
                            NeumorphicPillButton(
                              label: 'Zurück',
                              leadingIcon: Icons.arrow_back,
                              backgroundColor: AppTheme.surface,
                              foregroundColor: AppTheme.textColor,
                              onPressed: () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
