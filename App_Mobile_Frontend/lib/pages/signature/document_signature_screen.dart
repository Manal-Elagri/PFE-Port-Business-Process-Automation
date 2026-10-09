import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/signature_service.dart';

class DocumentSignatureScreen extends StatefulWidget {
  final int documentId;
  final String token;

  const DocumentSignatureScreen({
    super.key,
    required this.documentId,
    required this.token,
  });

  @override
  State<DocumentSignatureScreen> createState() => _DocumentSignatureScreenState();
}

class _DocumentSignatureScreenState extends State<DocumentSignatureScreen> {
  final SignatureApiService _signatureApi = SignatureApiService();
  final TextEditingController _otpCtrl = TextEditingController();

  late final SignatureController _signatureCtrl;

  bool _busy = false;

  @override
  void initState() {
    super.initState();

    _signatureCtrl = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _signatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _signDocument() async {
    final otp = _otpCtrl.text.trim();

    if (otp.isEmpty) {
      _showSnack('Code OTP obligatoire', isError: true);
      return;
    }

    if (_signatureCtrl.isEmpty) {
      _showSnack('Signature obligatoire', isError: true);
      return;
    }

    setState(() => _busy = true);

    try {
      final signatureBytes = await _signatureCtrl.toPngBytes();

      if (signatureBytes == null || signatureBytes.isEmpty) {
        _showSnack('Signature invalide', isError: true);
        return;
      }

      final signatureBase64 =
          'data:image/png;base64,${base64Encode(signatureBytes)}';

      await _signatureApi.signDocumentBySecureLink(
        documentId: widget.documentId,
        token: widget.token,
        otpCode: otp,
        signatureBase64: signatureBase64,
      );

      if (!mounted) return;

      _showSnack('Document signé avec succès');

      Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Erreur signature : $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = _signatureApi.getPdfUrl(
      documentId: widget.documentId,
      token: widget.token,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature du document'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: SfPdfViewer.network(
              pdfUrl,
              canShowScrollHead: true,
              canShowScrollStatus: true,
            ),
          ),

          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Code OTP',
                    hintText: 'Entrer le code reçu par email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Signature',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Signature(
                    controller: _signatureCtrl,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _signatureCtrl.clear,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Effacer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _signDocument,
                        icon: _busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.edit_document),
                        label: const Text('Signer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}