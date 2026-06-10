import 'package:lost_and_found/core/localization/app_localizations.dart';

class PostCategories {
  static const electronics = 'Electronics';
  static const officialDocuments = 'Official Documents';
  static const walletsAndMoney = 'Wallets and Money';
  static const keys = 'Keys';
  static const vehicles = 'Vehicles';
  static const animals = 'Animals';
  static const bagsAndLuggage = 'Bags and Luggage';
  static const booksAndPapers = 'Books and Papers';
  static const clothingAndAccessories = 'Clothing and Accessories';
  static const other = 'Other';

  static const values = [
    electronics,
    officialDocuments,
    walletsAndMoney,
    keys,
    vehicles,
    animals,
    bagsAndLuggage,
    booksAndPapers,
    clothingAndAccessories,
    other,
  ];

  static String normalize(String? category) {
    final trimmed = category?.trim() ?? '';
    if (trimmed.isEmpty) return other;
    return values.contains(trimmed) ? trimmed : trimmed;
  }

  static String filterValue(String? category) {
    final normalized = normalize(category);
    return values.contains(normalized) ? normalized : other;
  }

  static String label(AppLocalizations l, String category) {
    return l.text(_translationKeys[filterValue(category)] ?? 'categoryOther');
  }

  static const _translationKeys = {
    electronics: 'categoryElectronics',
    officialDocuments: 'categoryOfficialDocuments',
    walletsAndMoney: 'categoryWalletsAndMoney',
    keys: 'categoryKeys',
    vehicles: 'categoryVehicles',
    animals: 'categoryAnimals',
    bagsAndLuggage: 'categoryBagsAndLuggage',
    booksAndPapers: 'categoryBooksAndPapers',
    clothingAndAccessories: 'categoryClothingAndAccessories',
    other: 'categoryOther',
  };
}
