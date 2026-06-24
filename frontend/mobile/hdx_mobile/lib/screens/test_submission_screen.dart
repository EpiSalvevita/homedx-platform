import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../services/test_service.dart';
import '../widgets/figma_ui.dart';

class TestSubmissionScreen extends StatefulWidget {
  final String testTypeId;
  final String testTypeName;
  final String rapidTestId;
  final String? cubeResult;

  const TestSubmissionScreen({
    super.key,
    required this.testTypeId,
    required this.testTypeName,
    required this.rapidTestId,
    this.cubeResult,
  });

  @override
  State<TestSubmissionScreen> createState() => _TestSubmissionScreenState();
}

class _TestSubmissionScreenState extends State<TestSubmissionScreen> {
  bool _agreement = false;
  bool _submitting = false;
  String? _error;
  String? _photoName;
  String? _videoName;
  String? _idFrontName;
  String? _idBackName;

  TestService get _testService =>
      TestService(Provider.of<ApiService>(context, listen: false));

  Future<void> _pickAndUpload(String kind) async {
    final isVideo = kind == 'video';
    final pick = await FilePicker.platform.pickFiles(
      type: isVideo ? FileType.video : FileType.image,
      withData: true,
    );
    if (pick == null || pick.files.isEmpty) return;
    final file = pick.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    final filename = file.name;

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      switch (kind) {
        case 'photo':
          _photoName = await _testService.uploadTestPhoto(
            widget.rapidTestId,
            bytes,
            filename,
          );
        case 'video':
          _videoName = await _testService.uploadTestVideo(
            widget.rapidTestId,
            bytes,
            filename,
          );
        case 'idFront':
          _idFrontName = await _testService.uploadIdPhoto(
            widget.rapidTestId,
            bytes,
            filename,
            type: 'front',
          );
        case 'idBack':
          _idBackName = await _testService.uploadIdPhoto(
            widget.rapidTestId,
            bytes,
            filename,
            type: 'back',
          );
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (!_agreement) {
      setState(() => _error = 'Bitte stimmen Sie den Bedingungen zu.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _testService.finalizeSubmission(
        widget.rapidTestId,
        agreementGiven: true,
      );
      if (!mounted) return;
      context.go('/results');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaScreen(
      header: FigmaBackHeader(
        title: 'Test abschließen',
        blueTopBar: true,
        onBack: () => context.go('/home'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.screenHorizontalPadding),
        children: [
          Text(
            widget.testTypeName,
            style: FigmaUi.rubik(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          if (widget.cubeResult != null) ...[
            const SizedBox(height: 8),
            Text(
              'Cube-Ergebnis: ${widget.cubeResult}',
              style: FigmaUi.rubik(color: AppTheme.textColorSecondary),
            ),
          ],
          const SizedBox(height: 24),
          _uploadTile('Testfoto (optional)', _photoName, () => _pickAndUpload('photo')),
          _uploadTile('Testvideo (optional)', _videoName, () => _pickAndUpload('video')),
          _uploadTile('Ausweis Vorderseite', _idFrontName, () => _pickAndUpload('idFront')),
          _uploadTile('Ausweis Rückseite', _idBackName, () => _pickAndUpload('idBack')),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _agreement,
            onChanged: (v) => setState(() => _agreement = v ?? false),
            title: const Text(
              'Ich bestätige die Richtigkeit der Angaben und akzeptiere die Testbedingungen.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppTheme.errorColor)),
          ],
          const SizedBox(height: 24),
          NeumorphicPillButton(
            label: _submitting ? 'Wird gesendet…' : 'Test absenden',
            height: 52,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _uploadTile(String label, String? uploaded, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: AppTheme.baseColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(label),
        subtitle: uploaded != null ? Text('Hochgeladen: $uploaded') : null,
        trailing: Icon(
          uploaded != null ? Icons.check_circle : Icons.upload_file,
          color: uploaded != null ? AppTheme.successColor : AppTheme.primaryColor,
        ),
        onTap: _submitting ? null : onTap,
      ),
    );
  }
}
