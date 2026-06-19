import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../services/video_call_service.dart';
import '../widgets/figma_ui.dart';
import '../widgets/neumorphic.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videoanruf'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Zurück'),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videocam_outlined,
                            size: 64,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Der Videoanruf wurde in einem neuen Tab geöffnet.',
                            textAlign: TextAlign.center,
                            style: FigmaUi.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          NeumorphicButton(
                            isPrimary: true,
                            onPressed: _reopenCall,
                            child: Text(
                              'Erneut öffnen',
                              style: FigmaUi.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          NeumorphicButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Zurück',
                              style: FigmaUi.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
