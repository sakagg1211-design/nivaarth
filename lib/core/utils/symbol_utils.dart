import '../constants/nse_stocks_catalog.dart';

class SymbolUtils {
  const SymbolUtils._();

  static const Map<String, String> _aliases = {
    'TATA POWER': 'TATAPOWER',
    'TATAPOWER': 'TATAPOWER',
    'TATA MOTORS': 'TATAMOTORS',
    'TATAMOTORS': 'TATAMOTORS',
    'TATA STEEL': 'TATASTEEL',
    'TATASTEEL': 'TATASTEEL',
    'TATA TECH': 'TATATECH',
    'TATATECH': 'TATATECH',
    'TATA CONSUMER': 'TATACONSUM',
    'TATACONSUM': 'TATACONSUM',
    'TATA ELXSI': 'TATAELXSI',
    'TATAELXSI': 'TATAELXSI',
    'TATA CHEMICALS': 'TATACHEM',
    'TATACHEM': 'TATACHEM',
    'ADANI POWER': 'ADANIPOWER',
    'ADANIPOWER': 'ADANIPOWER',
    'ADANI PORTS': 'ADANIPORTS',
    'ADANIPORTS': 'ADANIPORTS',
    'ADANI ENT': 'ADANIENT',
    'ADANI ENTERPRISES': 'ADANIENT',
    'ADANIENT': 'ADANIENT',
    'ADANI GREEN': 'ADANIGREEN',
    'ADANIGREEN': 'ADANIGREEN',
    'ADANI TOTAL': 'ATGL',
    'ATGL': 'ATGL',
    'BAJAJ FINANCE': 'BAJFINANCE',
    'BAJFINANCE': 'BAJFINANCE',
    'BAJAJ FINSERV': 'BAJAJFINSV',
    'BAJAJFINSV': 'BAJAJFINSV',
    'BAJAJ AUTO': 'BAJAJ-AUTO',
    'BAJAJ-AUTO': 'BAJAJ-AUTO',
    'HDFC BANK': 'HDFCBANK',
    'HDFCBANK': 'HDFCBANK',
    'ICICI BANK': 'ICICIBANK',
    'ICICIBANK': 'ICICIBANK',
    'STATE BANK OF INDIA': 'SBIN',
    'SBI': 'SBIN',
    'SBIN': 'SBIN',
    'KOTAK BANK': 'KOTAKBANK',
    'KOTAK MAHINDRA': 'KOTAKBANK',
    'KOTAKBANK': 'KOTAKBANK',
    'AXIS BANK': 'AXISBANK',
    'AXISBANK': 'AXISBANK',
    'INDUSIND BANK': 'INDUSINDBK',
    'INDUSINDBK': 'INDUSINDBK',
    'YES BANK': 'YESBANK',
    'YESBANK': 'YESBANK',
    'IDFC FIRST BANK': 'IDFCFIRSTB',
    'IDFCFIRSTB': 'IDFCFIRSTB',
    'IDFC FIRST': 'IDFCFIRSTB',
    'ASIAN PAINT': 'ASIANPAINT',
    'ASIAN PAINTS': 'ASIANPAINT',
    'ASIANPAINT': 'ASIANPAINT',
    'BHARTI AIRTEL': 'BHARTIARTL',
    'AIRTEL': 'BHARTIARTL',
    'BHARTIARTL': 'BHARTIARTL',
    'SUN PHARMA': 'SUNPHARMA',
    'SUNPHARMA': 'SUNPHARMA',
    'MARUTI SUZUKI': 'MARUTI',
    'MARUTI': 'MARUTI',
    'HERO MOTOCORP': 'HEROMOTOCO',
    'HEROMOTOCO': 'HEROMOTOCO',
    'EICHER MOTORS': 'EICHERMOT',
    'EICHERMOT': 'EICHERMOT',
    'POWER GRID': 'POWERGRID',
    'POWERGRID': 'POWERGRID',
    'NTPC GREEN': 'NTPCGREEN',
    'NTPCGREEN': 'NTPCGREEN',
    'COAL INDIA': 'COALINDIA',
    'COALINDIA': 'COALINDIA',
    'ULTRATECH': 'ULTRACEMCO',
    'ULTRATECH CEMENT': 'ULTRACEMCO',
    'ULTRACEMCO': 'ULTRACEMCO',
    'NESTLE': 'NESTLEIND',
    'NESTLE INDIA': 'NESTLEIND',
    'NESTLEIND': 'NESTLEIND',
    'PIDILITE': 'PIDILITIND',
    'PIDILITIND': 'PIDILITIND',
    'VODAFONE IDEA': 'IDEA',
    'VI': 'IDEA',
    'IDEA': 'IDEA',
    'L&T': 'LT',
    'LARSEN & TOUBRO': 'LT',
    'LT': 'LT',
    'AVENUE SUPERMARTS': 'DMART',
    'DMART': 'DMART',
    'HINDUSTAN COPPER': 'HINDCOPPER',
    'HINDCOPPER': 'HINDCOPPER',
    'BHARAT ELECTRONICS': 'BEL',
    'BEL': 'BEL',
    'BHARAT HEAVY ELECTRICALS': 'BHEL',
    'BHEL': 'BHEL',
    'HINDUSTAN AERONAUTICS': 'HAL',
    'HAL': 'HAL',
    'IRCON': 'IRCON',
    'IRCON INTERNATIONAL': 'IRCON',
    'RPOWER': 'RPOWER',
    'RELIANCE POWER': 'RPOWER',
    'KEI': 'KEI',
    'KEI INDUSTRIES': 'KEI',
    'APOLLO TYRE': 'APOLLOTYRE',
    'APOLLO TYRES': 'APOLLOTYRE',
    'APOLLOTYRE': 'APOLLOTYRE',
    'APOLLOTYRES': 'APOLLOTYRE',
    'MRF': 'MRF',
    'CEAT': 'CEAT',
    'BALKRISHNA': 'BALKRISIND',
    'BALKRISIND': 'BALKRISIND',
    // Renamed NSE tickers: the old symbol resolves to the current one
    'ZOMATO': 'ETERNAL',
  };

  static String normalize(String symbol) {
    String clean = symbol
        .toUpperCase()
        .replaceAll(".NS", "")
        .replaceAll(".BO", "")
        .replaceAll("-BE", "")
        .replaceAll("-SM", "")
        .trim();

    // Check direct alias mapping
    if (_aliases.containsKey(clean)) {
      return _aliases[clean]!;
    }

    // Try space stripped version
    final noSpaces = clean.replaceAll(" ", "");
    if (_aliases.containsKey(noSpaces)) {
      return _aliases[noSpaces]!;
    }

    return clean;
  }

  static String getYahooSymbol(String symbol) {
    final clean = normalize(symbol);
    if (clean.startsWith('^')) return clean;
    return clean.endsWith('.NS') || clean.endsWith('.BO') ? clean : '$clean.NS';
  }

  static const Map<String, String> _knownCompanyNames = {
    'TATAPOWER': 'The Tata Power Company Limited',
    'TATAMOTORS': 'Tata Motors Limited',
    'TATASTEEL': 'Tata Steel Limited',
    'TATATECH': 'Tata Technologies Limited',
    'TATACONSUM': 'Tata Consumer Products Limited',
    'TATAELXSI': 'Tata Elxsi Limited',
    'TATACHEM': 'Tata Chemicals Limited',
    'TCS': 'Tata Consultancy Services Limited',
    'ANANTRAJ': 'Anant Raj Limited',
    'BAJAJFINSV': 'Bajaj Finserv Limited',
    'BAJFINANCE': 'Bajaj Finance Limited',
    'CCAVENUE': 'Infibeam Avenues (CCAVENUE)',
    'CDSL': 'Central Depository Services (India) Ltd',
    'CLEAN': 'Clean Science and Technology Ltd',
    'COALINDIA': 'Coal India Limited',
    'DWARKESH': 'Dwarikesh Sugar Industries Limited',
    'EXICOM': 'Exicom Tele-Systems Limited',
    'FIRSTCRY': 'Brainbees Solutions (FirstCry)',
    'GANESHHOU': 'Ganesh Housing Corporation Ltd',
    'GLOBALVECT': 'Global Vectra Helicorp Ltd',
    'GLOBALVECTRA': 'Global Vectra Helicorp Ltd',
    'HINDCOPPER': 'Hindustan Copper Limited',
    'IDFCFIRSTB': 'IDFC First Bank Limited',
    'IRCTC': 'Indian Railway Catering & Tourism Corp',
    'IREDA': 'Indian Renewable Energy Dev Agency',
    'IRFC': 'Indian Railway Finance Corporation',
    'JIOFIN': 'Jio Financial Services Limited',
    'LICHSGFIN': 'LIC Housing Finance Limited',
    'LIKHITHA-BE': 'Likhitha Infrastructure Limited',
    'LIKHITHA': 'Likhitha Infrastructure Limited',
    'MIDSMALL': 'Motilal Oswal MidSmall Cap Fund',
    'MOTHERSON': 'Samvardhana Motherson Int Ltd',
    'NATCOPHARM': 'Natco Pharma Limited',
    'NIFTYBEES': 'Nippon India ETF Nifty BeES',
    'NTPCGREEN': 'NTPC Green Energy Limited',
    'OLECTRA': 'Olectra Greentech Limited',
    'ONGC': 'Oil & Natural Gas Corporation Ltd',
    'RELIANCE': 'Reliance Industries Limited',
    'IRCON': 'Ircon International Ltd',
    'RPOWER': 'Reliance Power Limited',
    'RVNL': 'Rail Vikas Nigam Limited',
    'SEPC': 'SEPC Limited',
    'TATSILV': 'Tata Silver ETF',
    'TIINDIA': 'Tube Investments of India Limited',
    'UJJIVANSFB': 'Ujjivan Small Finance Bank Ltd',
    'INFY': 'Infosys Limited',
    'HDFCBANK': 'HDFC Bank Limited',
    'ICICIBANK': 'ICICI Bank Limited',
    'SBIN': 'State Bank of India',
    'BHARTIARTL': 'Bharti Airtel Limited',
    'ITC': 'ITC Limited',
    'LT': 'Larsen & Toubro Limited',
    'MARUTI': 'Maruti Suzuki India Limited',
    'SUNPHARMA': 'Sun Pharmaceutical Industries Ltd',
    'TITAN': 'Titan Company Limited',
    'ADANIENT': 'Adani Enterprises Limited',
    'ADANIPORTS': 'Adani Ports and SEZ Limited',
    'ADANIPOWER': 'Adani Power Limited',
    'ADANIGREEN': 'Adani Green Energy Limited',
    'ATGL': 'Adani Total Gas Limited',
    'WIPRO': 'Wipro Limited',
    'HCLTECH': 'HCL Technologies Limited',
    'AXISBANK': 'Axis Bank Limited',
    'KOTAKBANK': 'Kotak Mahindra Bank Limited',
    'NTPC': 'NTPC Limited',
    'POWERGRID': 'Power Grid Corporation of India',
    'JSWSTEEL': 'JSW Steel Limited',
    'ASIANPAINT': 'Asian Paints Limited',
    'ULTRACEMCO': 'UltraTech Cement Limited',
    'NESTLEIND': 'Nestle India Limited',
    'ETERNAL': 'Eternal Limited',
    'PAYTM': 'One97 Communications (Paytm)',
    'HAL': 'Hindustan Aeronautics Limited',
    'BEL': 'Bharat Electronics Limited',
    'BHEL': 'Bharat Heavy Electricals Limited',
    'SUZLON': 'Suzlon Energy Limited',
    'YESBANK': 'Yes Bank Limited',
    'IDEA': 'Vodafone Idea Limited',
    'POLYCAB': 'Polycab India Limited',
    'HAVELLS': 'Havells India Limited',
    'DIXON': 'Dixon Technologies (India) Limited',
    'TRENT': 'Trent Limited',
    'DMART': 'Avenue Supermarts (DMART)',
    'PIDILITIND': 'Pidilite Industries Limited',
    'HEROMOTOCO': 'Hero MotoCorp Limited',
    'EICHERMOT': 'Eicher Motors Limited',
    'BAJAJ-AUTO': 'Bajaj Auto Limited',
    'INDUSINDBK': 'IndusInd Bank Limited',
    'MUTHOOTFIN': 'Muthoot Finance Limited',
    'MANAPPURAM': 'Manappuram Finance Limited',
    'HERCULES': 'Hercules Investments & Finance',
    'MAHSEAMLES': 'Maharashtra Seamless Limited',
    'DLF': 'DLF Limited',
    'TECHM': 'Tech Mahindra Limited',
    'DIVISLAB': 'Divi\'s Laboratories Limited',
    'CIPLA': 'Cipla Limited',
    'DRREDDY': 'Dr. Reddy\'s Laboratories',
    'APOLLOHOSP': 'Apollo Hospitals Enterprise',
    'VEDL': 'Vedanta Limited',
    'HINDALCO': 'Hindalco Industries Limited',
    'JSWINFRA': 'JSW Infrastructure Limited',
    'GAIL': 'GAIL (India) Limited',
    'IOC': 'Indian Oil Corporation Limited',
    'BPCL': 'Bharat Petroleum Corp Limited',
    'CHOLAFIN': 'Cholamandalam Inv & Fin',
    'SHRIRAMFIN': 'Shriram Finance Limited',
    'CANBK': 'Canara Bank',
    'BANKBARODA': 'Bank of Baroda',
    'PNB': 'Punjab National Bank',
    'FEDERALBNK': 'The Federal Bank Limited',
    'PERSISTENT': 'Persistent Systems Limited',
    'COFORGE': 'Coforge Limited',
    'MPHASIS': 'Mphasis Limited',
    'LTIM': 'LTIMindtree Limited',
    'KPITTECH': 'KPIT Technologies Limited',
    'KALYANKJIL': 'Kalyan Jewellers India Ltd',
    'VAIBHAVGBL': 'Vaibhav Global Limited',
    'KEI': 'KEI Industries Limited',
    'APOLLOTYRE': 'Apollo Tyres Limited',
    'MRF': 'MRF Limited',
    'CEAT': 'CEAT Limited',
    'BALKRISIND': 'Balkrishna Industries Limited',
  };

  static const Map<String, String> _knownSectors = {
    'TATAPOWER': 'Power & Utilities',
    'ADANIPOWER': 'Power & Utilities',
    'RPOWER': 'Power & Utilities',
    'NTPC': 'Power & Utilities',
    'POWERGRID': 'Power & Utilities',
    'NTPCGREEN': 'Renewable Energy',
    'SUZLON': 'Renewable Energy',
    'IREDA': 'Financial Services',
    'IRFC': 'Financial Services',

    'TATAMOTORS': 'Automobile & Auto Components',
    'MARUTI': 'Automobile & Auto Components',
    'HEROMOTOCO': 'Automobile & Auto Components',
    'EICHERMOT': 'Automobile & Auto Components',
    'BAJAJ-AUTO': 'Automobile & Auto Components',
    'MOTHERSON': 'Automobile & Auto Components',
    'TIINDIA': 'Automobile & Auto Components',
    'OLECTRA': 'Automobile & Auto Components',
    'EXICOM': 'Automobile & Auto Components',

    'TATASTEEL': 'Metals & Mining',
    'JSWSTEEL': 'Metals & Mining',
    'HINDCOPPER': 'Metals & Mining',
    'VEDL': 'Metals & Mining',
    'HINDALCO': 'Metals & Mining',

    'TCS': 'Information Technology',
    'INFY': 'Information Technology',
    'WIPRO': 'Information Technology',
    'HCLTECH': 'Information Technology',
    'TATATECH': 'Information Technology',
    'TATAELXSI': 'Information Technology',
    'TECHM': 'Information Technology',
    'LTIM': 'Information Technology',
    'PERSISTENT': 'Information Technology',
    'COFORGE': 'Information Technology',
    'MPHASIS': 'Information Technology',
    'KPITTECH': 'Information Technology',
    'CCAVENUE': 'Information Technology',
    'PAYTM': 'Financial Technology',

    'HDFCBANK': 'Financial Services',
    'ICICIBANK': 'Financial Services',
    'SBIN': 'Financial Services',
    'KOTAKBANK': 'Financial Services',
    'AXISBANK': 'Financial Services',
    'INDUSINDBK': 'Financial Services',
    'BAJFINANCE': 'Financial Services',
    'BAJAJFINSV': 'Financial Services',
    'JIOFIN': 'Financial Services',
    'CDSL': 'Financial Services',
    'IDFCFIRSTB': 'Financial Services',
    'LICHSGFIN': 'Financial Services',
    'YESBANK': 'Financial Services',
    'UJJIVANSFB': 'Financial Services',
    'MUTHOOTFIN': 'Financial Services',
    'MANAPPURAM': 'Financial Services',
    'CHOLAFIN': 'Financial Services',
    'SHRIRAMFIN': 'Financial Services',
    'CANBK': 'Financial Services',
    'BANKBARODA': 'Financial Services',
    'PNB': 'Financial Services',
    'FEDERALBNK': 'Financial Services',
    'HERCULES': 'Financial Services',

    'RELIANCE': 'Oil, Gas & Energy',
    'ONGC': 'Oil, Gas & Energy',
    'COALINDIA': 'Oil, Gas & Energy',
    'GAIL': 'Oil, Gas & Energy',
    'IOC': 'Oil, Gas & Energy',
    'BPCL': 'Oil, Gas & Energy',
    'ATGL': 'Gas Distribution',

    'NATCOPHARM': 'Healthcare & Pharma',
    'SUNPHARMA': 'Healthcare & Pharma',
    'DIVISLAB': 'Healthcare & Pharma',
    'CIPLA': 'Healthcare & Pharma',
    'DRREDDY': 'Healthcare & Pharma',
    'APOLLOHOSP': 'Healthcare Services',

    'ANANTRAJ': 'Real Estate & Infrastructure',
    'GANESHHOU': 'Real Estate & Infrastructure',
    'DLF': 'Real Estate & Infrastructure',
    'LT': 'Construction & Engineering',
    'RVNL': 'Infrastructure & Railways',
    'IRCON': 'Infrastructure & Railways',
    'IRCTC': 'Consumer Services',
    'LIKHITHA': 'Infrastructure & Engineering',
    'LIKHITHA-BE': 'Infrastructure & Engineering',
    'SEPC': 'Infrastructure & Engineering',
    'JSWINFRA': 'Infrastructure & Ports',
    'ADANIPORTS': 'Infrastructure & Ports',
    'GLOBALVECT': 'Logistics & Aviation',
    'GLOBALVECTRA': 'Logistics & Aviation',

    'ITC': 'FMCG & Consumer Goods',
    'NESTLEIND': 'FMCG & Consumer Goods',
    'TATACONSUM': 'FMCG & Consumer Goods',
    'DWARKESH': 'Sugar & Agro Products',
    'CLEAN': 'Specialty Chemicals',
    'TATACHEM': 'Chemicals',
    'PIDILITIND': 'Chemicals & Adhesives',
    'TITAN': 'Consumer Discretionary',
    'KALYANKJIL': 'Gems & Jewellery',
    'VAIBHAVGBL': 'E-Commerce & Retail',
    'FIRSTCRY': 'Consumer E-Commerce',
    'ETERNAL': 'Consumer Internet Services',
    'BHARTIARTL': 'Telecommunications',
    'IDEA': 'Telecommunications',
    'HAL': 'Aerospace & Defence',
    'BEL': 'Defence & Electronics',
    'BHEL': 'Heavy Electrical Equipment',
    'ULTRACEMCO': 'Cement & Building Materials',
    'ASIANPAINT': 'Paints & Coatings',
    'ADANIENT': 'Diversified Conglomerate',
    'ADANIGREEN': 'Renewable Energy',
    'POLYCAB': 'Cables, Wires & Electricals',
    'HAVELLS': 'Electrical Consumer Goods',
    'DIXON': 'Electronic Manufacturing Services',
    'TRENT': 'Retail & Consumer Discretionary',
    'DMART': 'Retail & Consumer Goods',
    'TATSILV': 'Commodities & ETFs',
    'NIFTYBEES': 'Index & ETFs',
    'MIDSMALL': 'Mutual Funds',
    'KEI': 'Cables, Wires & Electricals',
    'APOLLOTYRE': 'Auto Tyres & Rubber Products',
    'MRF': 'Auto Tyres & Rubber Products',
    'CEAT': 'Auto Tyres & Rubber Products',
    'BALKRISIND': 'Auto Tyres & Rubber Products',
  };

  static const Map<String, String> _knownIndustries = {
    'TATAPOWER': 'Thermal & Renewable Power Generation',
    'ADANIPOWER': 'Thermal Power Generation',
    'RPOWER': 'Thermal & Renewable Power Generation',
    'POWERGRID': 'Power Transmission',
    'NTPC': 'Power Generation & Utility',
    'NTPCGREEN': 'Green Energy Solutions',
    'IRCON': 'Railway Infrastructure & EPC Construction',
    'SUZLON': 'Wind Turbines & Equipment',
    'TATAMOTORS': 'Commercial & Passenger Vehicles',
    'MARUTI': 'Passenger Cars & Utility Vehicles',
    'TATASTEEL': 'Integrated Steel Production',
    'TCS': 'IT Consulting & Software Services',
    'INFY': 'Digital Services & Consulting',
    'HDFCBANK': 'Private Sector Banking',
    'ICICIBANK': 'Private Sector Banking',
    'SBIN': 'Public Sector Banking',
    'RELIANCE': 'Petrochemicals, Retail & Telecom',
    'ITC': 'Cigarettes, FMCG & Agri Business',
    'LT': 'Heavy Civil Infrastructure & EPC',
    'BHARTIARTL': 'Wireless Telecom Services',
    'SUNPHARMA': 'Pharmaceutical Formulations',
    'POLYCAB': 'Wires, Power Cables & FMEG',
    'HAVELLS': 'Consumer Electrical Goods',
    'DIXON': 'Electronics System Design & Mfg',
    'TRENT': 'Fashion & Lifestyle Retail',
    'DMART': 'Hypermarket & Supermarket Retail',
    'HAL': 'Military Aircraft & Helicopters',
    'BEL': 'Defense Radar & Avionics',
    'BHEL': 'Power Plant Equipment & EPC',
    'IRCTC': 'Online Ticketing & Catering',
    'IRFC': 'Railway Asset Leasing & Finance',
    'IREDA': 'Clean Energy Financing',
    'CDSL': 'Securities Depository Services',
    'ETERNAL': 'Online Food Delivery & Quick Commerce',
    'KEI': 'Extra High Voltage Cables & EPC',
    'APOLLOTYRE': 'Automotive Radial Tires Manufacturing',
    'MRF': 'Automotive Tyres & Rubber Pre-cures',
    'CEAT': 'Automotive Tyres & Tubes',
    'BALKRISIND': 'Off-Highway Tires Manufacturing',
  };

  static bool isEtf(String symbol) {
    final sym = normalize(symbol).toUpperCase();
    return sym.endsWith("BEES") ||
        sym.endsWith("ETF") ||
        sym.contains("NIFTY") ||
        sym.contains("SILV") ||
        sym.contains("GOLD") ||
        sym.contains("COMMODITY") ||
        sym.contains("LIQUID") ||
        sym.contains("INVIT") ||
        sym.contains("REIT");
  }

  static String getDisplayName(String symbol, {String? dbCompanyName}) {
    if (dbCompanyName != null &&
        dbCompanyName.trim().isNotEmpty &&
        dbCompanyName.trim().toUpperCase() != normalize(symbol)) {
      return dbCompanyName.trim();
    }

    final clean = normalize(symbol);
    return _knownCompanyNames[clean] ?? NseStocksCatalog.stocks[clean] ?? clean;
  }

  static String getSector(String symbol, {String? dbSector}) {
    if (dbSector != null &&
        dbSector.trim().isNotEmpty &&
        dbSector.trim().toLowerCase() != 'energy' &&
        dbSector.trim().toLowerCase() != 'general' &&
        dbSector.trim().toLowerCase() != 'diversified') {
      return dbSector.trim();
    }

    final clean = normalize(symbol);
    if (_knownSectors.containsKey(clean)) return _knownSectors[clean]!;

    final name = (NseStocksCatalog.stocks[clean] ?? '').toUpperCase();
    if (name.contains('CEMENT')) return 'Cement & Building Materials';
    if (name.contains('BANK') || name.contains('FINANC')) return 'Financial Services';
    if (name.contains('PHARMA') || name.contains('HEALTH') || name.contains('DRUG')) return 'Healthcare & Pharma';
    if (name.contains('ELECTR') || name.contains('ENGINEER') || name.contains('POWER')) return 'Capital Goods & Infrastructure';
    if (name.contains('CHEM')) return 'Specialty Chemicals';
    if (name.contains('STEEL') || name.contains('METAL') || name.contains('MIN')) return 'Metals & Mining';
    if (name.contains('TECH') || name.contains('INFO') || name.contains('SOFTWARE')) return 'Information Technology';
    if (name.contains('AUTO') || name.contains('MOTOR')) return 'Automobile & Auto Components';

    return (dbSector?.trim().isNotEmpty == true ? dbSector!.trim() : 'Industrials & Services');
  }

  static String getIndustry(String symbol, {String? dbIndustry}) {
    if (dbIndustry != null && dbIndustry.trim().isNotEmpty) {
      return dbIndustry.trim();
    }

    final clean = normalize(symbol);
    if (_knownIndustries.containsKey(clean)) return _knownIndustries[clean]!;

    if (clean == 'ABB') return 'Heavy Electrical & Industrial Automation';
    if (clean == 'ACC') return 'Cement & Clinker Manufacturing';

    return 'Industry not available';
  }

  static List<MapEntry<String, String>> searchUniverse(String query) {
    final rawQ = query.trim().toUpperCase();
    if (rawQ.isEmpty) return const [];

    final normalizedQ = normalize(rawQ);
    final cleanQ = rawQ.replaceAll(" ", "");

    final results = <MapEntry<String, String>>[];
    final seen = <String>{};

    // 1. Direct exact symbol match (Priority #1)
    if (_knownCompanyNames.containsKey(normalizedQ)) {
      results.add(MapEntry(normalizedQ, _knownCompanyNames[normalizedQ]!));
      seen.add(normalizedQ);
    } else if (NseStocksCatalog.stocks.containsKey(normalizedQ)) {
      results.add(MapEntry(normalizedQ, NseStocksCatalog.stocks[normalizedQ]!));
      seen.add(normalizedQ);
    }

    if (!seen.contains(cleanQ) && NseStocksCatalog.stocks.containsKey(cleanQ)) {
      results.add(MapEntry(cleanQ, NseStocksCatalog.stocks[cleanQ]!));
      seen.add(cleanQ);
    }

    // 2. Direct symbol prefix match (Priority #2 - e.g. ACC*, ABB*, TAT*)
    for (final entry in NseStocksCatalog.stocks.entries) {
      final sym = entry.key;
      if (!seen.contains(sym) && (sym.startsWith(normalizedQ) || sym.startsWith(cleanQ))) {
        results.add(entry);
        seen.add(sym);
        if (results.length >= 25) break;
      }
    }

    // 3. Company name prefix match (Priority #3)
    for (final entry in NseStocksCatalog.stocks.entries) {
      final sym = entry.key;
      final name = entry.value.toUpperCase();
      if (!seen.contains(sym) && name.startsWith(rawQ)) {
        results.add(entry);
        seen.add(sym);
        if (results.length >= 30) break;
      }
    }

    // 4. Substring / contains matches in symbol or company name (Priority #4)
    for (final entry in NseStocksCatalog.stocks.entries) {
      final sym = entry.key;
      final name = entry.value.toUpperCase();
      if (!seen.contains(sym)) {
        if (sym.contains(normalizedQ) || sym.contains(cleanQ) || name.contains(rawQ)) {
          results.add(entry);
          seen.add(sym);
          if (results.length >= 35) break;
        }
      }
    }

    // 5. Search aliases
    for (final aliasEntry in _aliases.entries) {
      final aliasKey = aliasEntry.key;
      final targetSym = aliasEntry.value;

      if (!seen.contains(targetSym) &&
          (aliasKey.contains(rawQ) || rawQ.contains(aliasKey))) {
        final name = _knownCompanyNames[targetSym] ?? NseStocksCatalog.stocks[targetSym];
        if (name != null) {
          results.add(MapEntry(targetSym, name));
          seen.add(targetSym);
        }
      }
    }

    return results;
  }

  /// Normalizes legacy or raw backend recommendation strings to clean, human-friendly,
  /// SEBI-compliant research labels that never break UI card headers.
  static String toCompliantVerdict(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'NEUTRAL / WATCH';
    final upper = raw.trim().toUpperCase();

    // Canonical Quant Engine v2.0 Signals (Objective Research & Factor Rankings)
    if (upper == 'ACCUMULATE_CANDIDATE' || upper == 'ACCUMULATE' || upper == 'ROBUST PROFILE') {
      return 'ROBUST PROFILE';
    }
    if (upper == 'WATCH_WEAK_TREND' || upper == 'WAIT FOR DIP') {
      return 'WAIT FOR DIP';
    }
    if (upper == 'HOLD_WAIT_FOR_BETTER_ENTRY' || upper == 'FAIR VALUE / HOLD' || upper == 'FAIR VALUE / CORE') {
      return 'FAIR VALUE / CORE';
    }
    if (upper == 'HOLD_VALUATION_EXTENDED' || upper == 'EXTENDED VALUE' || upper == 'EXTENDED VALUATION') {
      return 'EXTENDED VALUE';
    }
    if (upper == 'REVIEW_FOR_TRIM' || upper == 'REVIEW TO TRIM' || upper == 'ELEVATED VALUATION') {
      return 'ELEVATED VALUATION';
    }
    if (upper == 'NOT_ELIGIBLE_FOR_ACCUMULATE' || upper == 'BELOW HURDLE') {
      return 'BELOW HURDLE';
    }
    if (upper == 'AVOID_HIGH_RISK_OVERRIDE' || upper == 'HIGH RISK' || upper == 'SELL' || upper == 'AVOID' || upper == 'HIGH RISK / AVOID' || upper == 'HIGH RISK FLAG') {
      return 'HIGH RISK FLAG';
    }
    if (upper == 'WATCH_FURTHER_RESEARCH' || upper == 'UNDER RESEARCH' || upper == 'NEUTRAL / WATCH' || upper == 'NEUTRAL' || upper == 'WATCH') {
      return 'NEUTRAL / WATCH';
    }
    if (upper == 'WATCH_VALUATION_UNAVAILABLE' || upper == 'LOSS MAKING / WATCH' || upper == 'NEGATIVE EARNINGS') {
      return 'NEGATIVE EARNINGS';
    }
    if (upper == 'QUALITY_UNAVAILABLE' || upper == 'DATA_STALE_SUPPRESSED' || upper == 'RISK_UNCONFIRMED_SUPPRESSED') {
      return 'DATA PENDING';
    }

    // Legacy Support
    if (upper == 'STRONG BUY' || upper == 'STRONG OUTPERFORM') {
      return 'ROBUST PROFILE';
    }
    if (upper == 'BUY' || upper == 'OUTPERFORM') {
      return 'ROBUST PROFILE';
    }
    if (upper == 'MODERATE STRENGTH' || upper == 'MODERATE') {
      return 'MODERATE STRENGTH';
    }
    if (upper == 'HOLD' || upper.contains('HOLD') || upper == 'NEUTRAL') {
      return 'FAIR VALUE / CORE';
    }
    if (upper == 'REDUCE' || upper == 'CAUTION' || upper == 'ELEVATED RISK') {
      return 'ELEVATED VALUATION';
    }

    return upper.replaceAll('_', ' ');
  }
}