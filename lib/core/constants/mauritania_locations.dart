class MauritaniaLocations {
  static const Map<String, List<String>> districtsByWilaya = {
    'Nouakchott Ouest': ['Tevragh Zeina', 'Ksar', 'Sebkha'],
    'Nouakchott Nord': ['Dar Naim', 'Teyarett', 'Toujounine'],
    'Nouakchott Sud': ['Arafat', 'El Mina', 'Riyadh'],
    'Adrar': ['Atar', 'Chinguetti', 'Ouadane', 'Aoujeft'],
    'Inchiri': ['Akjoujt', 'Bennechab'],
    'Tagant': ['Tidjikja', 'Moudjeria', 'Tichitt'],
    'Hodh Ech Chargui': ['Nema', 'Amourj', 'Bassiknou', 'Djigueni', 'Oualata'],
    'Hodh El Gharbi': ['Aioun', 'Tintane', 'Kobeni', 'Tamchekett'],
    'Assaba': ['Kiffa', 'Guerou', 'Boumdeid', 'Barkewol', 'Kankossa'],
    'Brakna': ['Aleg', 'Boghé', 'Bababé', 'Mbagne', 'Magta-Lahjar'],
    'Trarza': ['Rosso', 'Boutilimit', 'Mederdra', 'Rkiz', 'Keur Macène'],
    'Gorgol': ['Kaédi', 'Monguel', 'Mbout', 'Maghama'],
    'Guidimakha': ['Sélibaby', 'Ould Yengé', 'Ghabou'],
    'Tiris Zemmour': ['Zouérat', 'Fderik', 'Bir Moghrein'],
    'Dakhlet Nouadhibou': ['Nouadhibou', 'Chami'],
  };

  static List<String> get wilayas => districtsByWilaya.keys.toList();

  static List<String> districtsFor(String? wilaya) {
    if (wilaya == null) return const [];
    return districtsByWilaya[wilaya] ?? const [];
  }
}
