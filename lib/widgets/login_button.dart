import 'package:flutter/material.dart';
import 'loop_button.dart';

/// "Giriş Yap" butonu — artık [LoopButton] üzerine kurulu.
///
/// Geriye dönük uyumluluk için aynı API korundu.
class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LoopButton(
      label: 'Giriş Yap',
      onTap: onPressed,
      isLoading: isLoading,
      fontSize: 16,
    );
  }
}
