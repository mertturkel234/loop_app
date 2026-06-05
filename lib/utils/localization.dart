class Localization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'EN': {
      // General
      'live_map': 'Live Map',
      'fleet_tracked': 'Fleet tracked in real-time',
      'live': 'LIVE',
      'active_vehicles': 'Active Vehicles',
      'completed': 'Completed',
      'delayed': 'Delayed',
      'active_orders': 'Active Orders',
      'see_all': 'See All',
      'ai_route_analysis': 'AI ROUTE ANALYSIS',
      'ai_analysis_desc': 'Global network optimization active. Traffic anomalies reduced by 18%.',
      'search_hint': 'Order Tracking Number',
      
      // Order Status
      'on_the_way': 'On the way',
      'delivering': 'Delivering',
      'delay': 'Delay',
      'traffic': 'Traffic',
      
      // ETA extensions
      'h': 'h',
      'm': 'm',
      'delayed_status': 'Delayed',

      // Settings/Profile
      'profile': 'Profile',
      'theme': 'Theme',
      'language': 'Language',
    },
    'TR': {
      // General
      'live_map': 'Canlı Harita',
      'fleet_tracked': 'Filo gerçek zamanlı izleniyor',
      'live': 'CANLI',
      'active_vehicles': 'Aktif Araç',
      'completed': 'Tamamlanan',
      'delayed': 'Geciken',
      'active_orders': 'Aktif Siparişler',
      'see_all': 'Tümünü Gör',
      'ai_route_analysis': 'AI ROTA ANALİZİ',
      'ai_analysis_desc': 'Global ağ optimizasyonu devrede. Trafik anomalileri %18 azaltıldı.',
      'search_hint': 'Sipariş Takip Numarası',
      
      // Order Status
      'on_the_way': 'Yolda',
      'delivering': 'Teslimatta',
      'delay': 'Gecikme',
      'traffic': 'Trafik',

      // ETA extensions
      'h': 's',
      'm': 'dk',
      'delayed_status': 'Gecikmeli',

      // Settings/Profile
      'profile': 'Profilim',
      'theme': 'Tema',
      'language': 'Dil',
    },
  };

  static String translate(String key, String locale) {
    return _localizedValues[locale]?[key] ?? key;
  }
}
