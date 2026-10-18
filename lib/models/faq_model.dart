class FaqModel {
  final String? id;
  final String question;
  final String answer;
  final int order;

  const FaqModel({
    this.id,
    required this.question,
    required this.answer,
    required this.order,
  });

  factory FaqModel.fromMap(Map<String, dynamic> map, String id) {
    return FaqModel(
      id: id,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'order': order,
    };
  }
}

final List<FaqModel> defaultFaqs = [
  FaqModel(
    question: 'What are the admission requirements?',
    answer:
        'Anyone who wants to learn can apply. The Advance Computer Course covers everything from fundamentals onward, so no prior computer knowledge is required. For AI & Digital Skills, basic computer familiarity is helpful.',
    order: 1,
  ),
  FaqModel(
    question: 'What is the course duration?',
    answer:
        'Both courses are 3 months long with classes scheduled on weekdays. You will receive a certificate upon successful completion.',
    order: 2,
  ),
  FaqModel(
    question: 'How much are the fees?',
    answer:
        'The Advance Computer Course is PKR 2,500 per month and the AI & Smart Digital Skills course is PKR 3,000 per month. Fees are to be paid monthly.',
    order: 3,
  ),
  FaqModel(
    question: 'Is the certificate recognized?',
    answer:
        'Yes, our certificates are issued by MAI Coaching Academy and can be verified online. We are committed to providing quality education that is relevant in today\'s digital job market.',
    order: 4,
  ),
  FaqModel(
    question: 'Can I apply online?',
    answer:
        'Yes, you can apply through our online admissions form on this website. Once submitted, our team will contact you within 24–48 hours to confirm your enrollment.',
    order: 5,
  ),
  FaqModel(
    question: 'What is the class schedule?',
    answer:
        'Classes are held Monday to Friday. The exact schedule will be communicated upon enrollment. We also offer flexible timing to accommodate students with other commitments.',
    order: 6,
  ),
  FaqModel(
    question: 'Where is the institute located?',
    answer:
        'We are located at Manglor Pull, Near NBP, Swat, Pakistan. You can contact us via phone or WhatsApp at +92 329 8681641 for directions.',
    order: 7,
  ),
  FaqModel(
    question: 'Do I need to bring my own laptop?',
    answer:
        'No, we have a computer lab with all necessary equipment. However, if you have your own laptop, you are welcome to bring it for additional practice.',
    order: 8,
  ),
];
