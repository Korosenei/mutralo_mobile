import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/gestionnaire_espace_provider.dart';
import '../../providers/scanner_provider.dart';
import '../../theme/colors.dart';
import 'verification_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  // Le contrôleur n'est créé QU'APRÈS confirmation de la permission —
  // jamais au niveau du champ — pour éviter tout appel start() pendant
  // que le dialogue système de permission met l'app en arrière-plan.
  MobileScannerController? _controller;
  bool _locked = false;
  bool _reinitialisationEnCours = false;

  bool _checkingPermission = true;
  bool _permissionAccordee = false;
  bool _permissionDefinitivementRefusee = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Gère le cycle de vie de la caméra en fonction du premier plan/arrière
  /// plan de l'app — indispensable avec mobile_scanner pour éviter les
  /// genericError au retour d'un dialogue système (permission, appel, etc.)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_permissionAccordee) return;

    switch (state) {
      case AppLifecycleState.resumed:
        controller.start().catchError((_) {
          // Si le redémarrage échoue silencieusement, on laisse
          // errorBuilder afficher le bouton "Réessayer" manuel.
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        controller.stop();
        break;
    }
  }

  /// Recrée entièrement le contrôleur caméra (dispose + nouvelle instance)
  /// — permet de sortir d'un MobileScannerErrorCode.genericError sans
  /// avoir à fermer l'app.
  Future<void> _reinitialiserCamera() async {
    if (_reinitialisationEnCours) return;
    setState(() => _reinitialisationEnCours = true);

    final ancienControleur = _controller;
    final nouveauControleur = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
    );

    setState(() {
      _controller = nouveauControleur;
      _reinitialisationEnCours = false;
    });

    // Dispose de l'ancien contrôleur après le rebuild, pour ne pas libérer
    // une ressource encore référencée par le widget MobileScanner affiché.
    if (ancienControleur != null) await ancienControleur.dispose();

    try {
      await nouveauControleur.start();
    } catch (_) {
      // errorBuilder prendra le relais si le démarrage échoue encore.
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      await _creerEtDemarrerControleur();
      return;
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _permissionDefinitivementRefusee = true;
          _checkingPermission = false;
        });
      }
      return;
    }
    final result = await Permission.camera.request();
    if (!mounted) return;
    if (result.isGranted) {
      await _creerEtDemarrerControleur();
    } else {
      setState(() {
        _permissionAccordee = false;
        _permissionDefinitivementRefusee = result.isPermanentlyDenied;
        _checkingPermission = false;
      });
    }
  }

  /// Créé le contrôleur uniquement une fois la permission confirmée,
  /// avec autoStart désactivé, et démarre explicitement — évite toute
  /// tentative de binding caméra pendant le dialogue système.
  Future<void> _creerEtDemarrerControleur() async {
    final controleur = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
    );
    if (!mounted) return;
    setState(() {
      _controller = controleur;
      _permissionAccordee = true;
      _checkingPermission = false;
    });
    try {
      await controleur.start();
    } catch (_) {
      // errorBuilder affichera le bouton "Réessayer" si le start échoue.
    }
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_locked || _controller == null) return;
    final code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null) return;

    _locked = true;
    await _controller!.stop();

    final scannerProvider = context.read<ScannerProvider>();
    await scannerProvider.verifierCode(code);

    if (!mounted) return;
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(code: code)));

    _locked = false;
    if (mounted && _controller != null) {
      try {
        await _controller!.start();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final estProgramme =
        context.watch<GestionnaireEspaceProvider>().estProgramme;
    final chargementStatut =
        context.watch<GestionnaireEspaceProvider>().chargement;

    if (chargementStatut) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: CircularProgressIndicator(color: AppColors.accent)));
    }

    if (!estProgramme) {
      return _restaurantNonProgramme(context);
    }

    if (_checkingPermission) {
      return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
              child: CircularProgressIndicator(color: AppColors.accent)));
    }

    if (_permissionDefinitivementRefusee) {
      return _permissionRefusee(
        message:
            "L'accès à la caméra a été refusé. Autorisez-le dans les paramètres pour scanner les QR codes.",
        bouton: ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Ouvrir les paramètres')),
      );
    }

    if (!_permissionAccordee || _controller == null) {
      return _permissionRefusee(
        message:
            "L'accès à la caméra est nécessaire pour scanner les QR codes.",
        bouton: ElevatedButton(
          onPressed: () {
            setState(() => _checkingPermission = true);
            _initCamera();
          },
          child: const Text('Réessayer'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            key: ValueKey(_controller),
            controller: _controller!,
            onDetect: _handleDetect,
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_outlined,
                        color: Colors.white54, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      "Erreur caméra : ${error.errorCode}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "La session caméra s'est mal initialisée. Réessayez — si le problème persiste, fermez complètement l'application puis rouvrez-la.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _reinitialisationEnCours
                          ? null
                          : _reinitialiserCamera,
                      icon: _reinitialisationEnCours
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent, width: 3),
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: const Text('Placez le QR code du client dans le cadre',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restaurantNonProgramme(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 56, color: AppColors.disabled),
                const SizedBox(height: AppSpacing.md),
                const Text('Scanner indisponible',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  "Votre restaurant n'est programmé sur aucune agence aujourd'hui. Vous pouvez tout de même consulter vos consommations, "
                  "vos agences et les avis clients depuis les autres onglets.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _permissionRefusee({required String message, required Widget bouton}) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              bouton,
            ],
          ),
        ),
      ),
    );
  }
}
