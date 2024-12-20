import 'package:flutter/material.dart';
import 'page.dart' as p;

final ShapeBorder cardBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onNavigate,
  });

  final Function(p.Page page) onNavigate;

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    final int crossAxisCount = windowSize.width ~/ 400;
    final double size = windowSize.width / crossAxisCount;

    return GridView.extent(
      maxCrossAxisExtent: size,
      padding: const EdgeInsets.all(32),
      mainAxisSpacing: 32,
      crossAxisSpacing: 32,
      children: p.Page.values
          .map((page) => Card(
                shape: cardBorder,
                child: InkWell(
                  customBorder: cardBorder,
                  onTap: () => onNavigate(page),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        page.icon,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
