import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('ar'), Locale('fr')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const _values = {
    'ar': {
      'appName': 'ضالة',
      'splash': 'ضالة',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'searchHint': 'البحث عن الإعلانات...',
      'wilayaFilter': 'تصفية حسب الولاية',
      'potentialMatches': 'مطابقات محتملة',
      'home': 'الرئيسية',
      'addPost': 'إضافة إعلان',
      'myPosts': 'إعلاناتي',
      'profile': 'الملف الشخصي',
      'details': 'تفاصيل الإعلان',
      'lost': 'مفقود',
      'found': 'موجود',
      'title': 'العنوان',
      'description': 'الوصف',
      'category': 'الفئة',
      'all': 'الكل',
      'categoryElectronics': 'إلكترونيات',
      'categoryOfficialDocuments': 'وثائق رسمية',
      'categoryWalletsAndMoney': 'محافظ ونقود',
      'categoryKeys': 'مفاتيح',
      'categoryVehicles': 'مركبات',
      'categoryAnimals': 'حيوانات',
      'categoryBagsAndLuggage': 'حقائب وأمتعة',
      'categoryBooksAndPapers': 'كتب وأوراق',
      'categoryClothingAndAccessories': 'ملابس وإكسسوارات',
      'categoryOther': 'أخرى',
      'location': 'الولاية / الموقع',
      'wilaya': 'الولاية *',
      'district': 'المقاطعة *',
      'locationDescription': 'تفاصيل الموقع (اختياري)',
      'contact': 'التواصل',
      'date': 'التاريخ',
      'status': 'الحالة',
      'open': 'مفتوح',
      'closed': 'مغلق',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'cancel': 'إلغاء',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'fullName': 'الاسم الكامل',
      'phoneNumber': 'رقم الهاتف',
      'required': 'هذا الحقل مطلوب',
      'invalidEmail': 'البريد الإلكتروني غير صالح',
      'passwordsDoNotMatch': 'كلمتا المرور غير متطابقتين',
      'createAccount': 'إنشاء حساب',
      'alreadyHaveAccount': 'لديك حساب؟ تسجيل الدخول',
      'noPosts': 'لا توجد إعلانات',
      'noPostsYet': 'لا توجد إعلانات بعد',
      'add': 'إضافة',
      'logout': 'تسجيل الخروج',
      'postNotFound': 'الإعلان غير موجود',
      'searchLocation': 'البحث عبر OpenStreetMap',
      'chooseLocationFromMap': 'اختيار الموقع من الخريطة (اختياري)',
      'mapOptionalHint': 'يمكنك حفظ الإعلان بدون الخريطة.',
      'loginSuccess': 'تم تسجيل الدخول بنجاح',
      'registerSuccess': 'تم إنشاء الحساب',
      'logoutSuccess': 'تم تسجيل الخروج',
      'postCreated': 'تم نشر الإعلان',
      'postUpdated': 'تم تحديث الإعلان',
      'postDeleted': 'تم حذف الإعلان',
      'imageUploaded': 'تم رفع الصورة',
      'selectImage': 'اختيار صورة',
      'locationFound': 'تم العثور على الموقع',
      'locationNotFound': 'لم يتم العثور على موقع',
      'genericError': 'حدث خطأ، حاول مرة أخرى',
      'imageUploadFailed': 'فشل رفع الصورة',
      'locationSearchFailed': 'فشل البحث عن الموقع',
      'locationSearchOptionalFailed':
          'تعذر استخدام الخريطة الآن. يمكنك المتابعة بدونها.',
      'confirmDeleteTitle': 'تأكيد الحذف',
      'confirmDeleteMessage': 'هل أنت متأكد من حذف هذا الإعلان؟',
      'selectDate': 'اختر التاريخ',
      'changeLanguage': 'تغيير اللغة',
      'french': 'Français',
      'arabic': 'العربية',
      'name': 'الاسم',
    },
    'fr': {
      'appName': 'Dalah',
      'splash': 'Dalah',
      'login': 'Connexion',
      'register': 'Inscription',
      'searchHint': 'Rechercher des annonces...',
      'wilayaFilter': 'Filtrer par Wilaya',
      'potentialMatches': 'Correspondances potentielles',
      'home': 'Accueil',
      'addPost': 'Ajouter une annonce',
      'myPosts': 'Mes annonces',
      'profile': 'Profil',
      'details': "Détails de l'annonce",
      'lost': 'Perdu',
      'found': 'Trouvé',
      'title': 'Titre',
      'description': 'Description',
      'category': 'Catégorie',
      'all': 'Tous',
      'categoryElectronics': 'Électronique',
      'categoryOfficialDocuments': 'Documents officiels',
      'categoryWalletsAndMoney': 'Portefeuilles et argent',
      'categoryKeys': 'Clés',
      'categoryVehicles': 'Véhicules',
      'categoryAnimals': 'Animaux',
      'categoryBagsAndLuggage': 'Sacs et bagages',
      'categoryBooksAndPapers': 'Livres et papiers',
      'categoryClothingAndAccessories': 'Vêtements et accessoires',
      'categoryOther': 'Autre',
      'location': 'Wilaya / lieu',
      'wilaya': 'Wilaya *',
      'district': 'Moughataa *',
      'locationDescription': 'Lieu détaillé (optionnel)',
      'contact': 'Contact',
      'date': 'Date',
      'status': 'Statut',
      'open': 'Ouvert',
      'closed': 'Fermé',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'cancel': 'Annuler',
      'email': 'Email',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'fullName': 'Nom complet',
      'phoneNumber': 'Numéro de téléphone',
      'required': 'Champ obligatoire',
      'invalidEmail': 'Email invalide',
      'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas',
      'createAccount': 'Créer un compte',
      'alreadyHaveAccount': 'Déjà un compte ? Connexion',
      'noPosts': 'Aucune annonce',
      'noPostsYet': 'Aucune annonce pour le moment',
      'add': 'Ajouter',
      'logout': 'Déconnexion',
      'postNotFound': 'Annonce introuvable',
      'searchLocation': 'Rechercher avec OpenStreetMap',
      'chooseLocationFromMap': 'Choisir le lieu depuis la carte (optionnel)',
      'mapOptionalHint': "Vous pouvez publier l'annonce sans la carte.",
      'loginSuccess': 'Connexion réussie',
      'registerSuccess': 'Compte créé',
      'logoutSuccess': 'Déconnexion réussie',
      'postCreated': 'Annonce publiée',
      'postUpdated': 'Annonce mise à jour',
      'postDeleted': 'Annonce supprimée',
      'imageUploaded': 'Image téléversée',
      'selectImage': 'Choisir une image',
      'locationFound': 'Lieu trouvé',
      'locationNotFound': 'Aucun lieu trouvé',
      'genericError': 'Une erreur est survenue, réessayez',
      'imageUploadFailed': "Échec du téléversement de l'image",
      'locationSearchFailed': 'Échec de la recherche du lieu',
      'locationSearchOptionalFailed':
          'La carte est indisponible pour le moment. Vous pouvez continuer sans elle.',
      'confirmDeleteTitle': 'Confirmer la suppression',
      'confirmDeleteMessage': 'Voulez-vous vraiment supprimer cette annonce ?',
      'selectDate': 'Choisir la date',
      'changeLanguage': 'Changer la langue',
      'french': 'Français',
      'arabic': 'العربية',
      'name': 'Nom',
    },
  };

  String text(String key) {
    return _values[locale.languageCode]?[key] ?? _values['ar']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
