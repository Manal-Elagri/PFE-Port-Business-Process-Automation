import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(
            color: ThemeConfig.primaryColor,
            strokeWidth: 2,
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
