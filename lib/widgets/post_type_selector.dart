import 'package:flutter/material.dart';

class PostTypeSelector extends StatefulWidget {
  final Function(String selectedType) onTypeSelected;

  const PostTypeSelector({
    super.key,
    required this.onTypeSelected,
  });

  @override
  State<PostTypeSelector> createState() => _PostTypeSelectorState();
}

class _PostTypeSelectorState extends State<PostTypeSelector> {
  String _selectedType = 'lost';

  @override
  void initState() {
    super.initState();
    widget.onTypeSelected(_selectedType);
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });

    widget.onTypeSelected(type);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("Lost"),
          selected: _selectedType == 'lost',
          onSelected: (_) => _selectType('lost'),
        ),

        const SizedBox(width: 10),

        ChoiceChip(
          label: const Text("Found"),
          selected: _selectedType == 'found',
          onSelected: (_) => _selectType('found'),
        ),
      ],
    );
  }
}

