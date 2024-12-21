import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectEntitySheet extends StatelessWidget {
  final List<String> items;
  final Function(String)? onItemTap;
  final ScrollController _scrollController = ScrollController();
  SelectEntitySheet({super.key, required this.items, this.onItemTap});

  Widget _itemsBuilder() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(items[index]),
            onTap: () {
              onItemTap == null
                  ? null
                  : onItemTap!(
                      items[index],
                    );
              Navigator.pop(context);
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
              child: Text("Select Entity",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w600))),
        ),
        Flexible(
          child:
              Scrollbar(controller: _scrollController, child: _itemsBuilder()),
        )
      ],
    );
  }
}
