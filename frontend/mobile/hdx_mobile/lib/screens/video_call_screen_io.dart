import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';
import '../services/video_call_service.dart';

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
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;

  static bool _isAllowedVideoHost(String host) {
    final h = host.toLowerCase();
    return h == 'daily.co' || h.endsWith('.daily.co');
  }

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

      final joinUri = Uri.parse(token.joinUrl);
      if (!_isAllowedVideoHost(joinUri.host)) {
        setState(() {
          _error = 'Ungültige Video-URL';
          _isLoading = false;
        });
        return;
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onNavigationRequest: (request) {
              final uri = Uri.tryParse(request.url);
              if (uri == null || !_isAllowedVideoHost(uri.host)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        );
      await controller.loadRequest(joinUri);

      setState(() {
        _controller = controller;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Videoanruf konnte nicht gestartet werden';
          _isLoading = false;
        });
      }
    }
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
      body: _error != null
          ? Center(child: Text(_error!))
          : Stack(
              children: [
                if (_controller != null) WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
