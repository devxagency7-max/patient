/// بيانات الدواء للطلب
class MedicineData {
  final String nameAr;
  final String nameEn;
  final double price;
  final String category;
  final bool requiresPrescription;
  final bool isAvailable;

  const MedicineData({
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.category,
    this.requiresPrescription = false,
    this.isAvailable = true,
  });
}

/// عنصر في السلة
class CartItem {
  final MedicineData medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get totalPrice => medicine.price * quantity;
}

/// البيانات الوهمية للأدوية
class MedicineRepository {
  static const List<MedicineData> medicines = [
    MedicineData(
      nameAr: 'باراسيتامول',
      nameEn: 'Paracetamol',
      price: 15,
      category: 'مسكنات',
    ),
    MedicineData(
      nameAr: 'أسبرين',
      nameEn: 'Aspirin',
      price: 25,
      category: 'مسكنات',
    ),
    MedicineData(
      nameAr: 'أوميجا 3',
      nameEn: 'Omega-3',
      price: 120,
      category: 'فيتامينات',
    ),
    MedicineData(
      nameAr: 'فيتامين د',
      nameEn: 'Vitamin D',
      price: 85,
      category: 'فيتامينات',
    ),
    MedicineData(
      nameAr: 'أموكسيسيلين',
      nameEn: 'Amoxicillin',
      price: 55,
      category: 'مضادات حيوية',
      requiresPrescription: true,
      isAvailable: false,
    ),
    MedicineData(
      nameAr: 'ميتفورمين',
      nameEn: 'Metformin',
      price: 45,
      category: 'مضادات حيوية',
      requiresPrescription: true,
    ),
  ];

  static const List<String> categories = [
    'الكل',
    'مسكنات',
    'فيتامينات',
    'مضادات حيوية',
  ];
}
