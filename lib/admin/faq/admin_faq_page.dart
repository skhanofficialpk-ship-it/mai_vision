import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/faq_model.dart';

class AdminFaqPage extends StatefulWidget {
  const AdminFaqPage({super.key});

  @override
  State<AdminFaqPage> createState() => _AdminFaqPageState();
}

class _AdminFaqPageState extends State<AdminFaqPage> {
  late List<FaqModel> _faqs;

  @override
  void initState() {
    super.initState();
    _faqs = List.from(defaultFaqs);
  }

  void _addOrEdit({FaqModel? existing, int? index}) {
    showDialog(
      context: context,
      builder: (ctx) => _FaqDialog(
        faq: existing,
        onSave: (faq) {
          setState(() {
            if (index != null) {
              _faqs[index] = faq;
            } else {
              _faqs.add(faq);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('FAQ Management',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.text, letterSpacing: -0.5)),
                    SizedBox(height: 6),
                    Text('Manage frequently asked questions displayed on the homepage.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addOrEdit(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add FAQ'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ..._faqs.asMap().entries.map((entry) {
            final i = entry.key;
            final faq = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(faq.question,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text)),
                      const SizedBox(height: 8),
                      Text(faq.answer,
                          style: const TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.6, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  onPressed: () => _addOrEdit(existing: faq, index: i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  onPressed: () => setState(() => _faqs.removeAt(i)),
                ),
              ],
            ),
          );
        }),
      ],
    ));
  }
}

class _FaqDialog extends StatefulWidget {
  final FaqModel? faq;
  final ValueChanged<FaqModel> onSave;
  const _FaqDialog({this.faq, required this.onSave});

  @override
  State<_FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends State<_FaqDialog> {
  late TextEditingController _question;
  late TextEditingController _answer;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.faq?.question ?? '');
    _answer = TextEditingController(text: widget.faq?.answer ?? '');
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: screenWidth < 520 ? screenWidth * 0.9 : 480,
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.faq == null ? 'Add FAQ' : 'Edit FAQ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
            const SizedBox(height: 20),
            TextField(controller: _question, decoration: const InputDecoration(labelText: 'Question')),
            const SizedBox(height: 14),
            TextField(
                controller: _answer,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Answer')),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(FaqModel(
                      id: widget.faq?.id,
                      question: _question.text,
                      answer: _answer.text,
                      order: widget.faq?.order ?? 99,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
