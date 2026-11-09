// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menuLanguage => 'Language';

  @override
  String get authInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authResetFailed =>
      'Unable to send reset link. Please check your email and try again.';

  @override
  String get authResetTitle => 'Reset Password';

  @override
  String get authResetCheckInbox => 'Check your inbox for a recovery link.';

  @override
  String get authResetPrompt =>
      'Enter the email linked to your Nivaarth account to receive a reset link.';

  @override
  String get authResetSent => 'Reset Link Sent';

  @override
  String authResetSentTo(Object email) {
    return 'We sent instructions to $email.';
  }

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get authRegisteredEmail => 'Registered Email';

  @override
  String get authSendReset => 'Send Reset Link';

  @override
  String get authEnterBoth => 'Please enter both email and password.';

  @override
  String get authWrongCreds => 'Incorrect email or password.';

  @override
  String get commonNetworkIssue =>
      'Network issue. Please check your internet connection.';

  @override
  String get authTooMany => 'Too many attempts. Please try again shortly.';

  @override
  String get authSignInFailed =>
      'Unable to sign in. Please verify your details.';

  @override
  String get authTagline =>
      'Private portfolio intelligence for focused investors.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgot => 'Forgot password?';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authEnterName => 'Please enter your full name.';

  @override
  String get authPasswordShort =>
      'Password must be at least 6 characters long.';

  @override
  String get authPasswordMismatch => 'Passwords do not match.';

  @override
  String get authAcceptRisk =>
      'Please acknowledge that stock investments carry market risks and accept the terms.';

  @override
  String get authEmailExists =>
      'An account with this email already exists. Please log in.';

  @override
  String get authCreateFailed => 'Unable to create account. Please try again.';

  @override
  String get authAccountCreated => 'Account Created';

  @override
  String authAccountReady(Object email) {
    return 'Your Nivaarth account is ready! If verification is requested, check $email to confirm.';
  }

  @override
  String get authProceedSignIn => 'Proceed to Sign In';

  @override
  String get authJoinBeta => 'Join the private closed beta of Nivaarth.';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get welcomeTagline =>
      'Quantitative portfolio intelligence for serious Indian investors.';

  @override
  String get welcomePrivateTitle => 'Private & Isolated';

  @override
  String get welcomePrivateBody =>
      'Your portfolio data is isolated and protected with zero cross-user access.';

  @override
  String get welcomeScoringTitle => 'Multi-Factor AI Scoring';

  @override
  String get welcomeScoringBody =>
      'Fundamental, technical, management, and risk dimensions ranked continuously.';

  @override
  String get welcomeCockpitTitle => 'Live Cockpit';

  @override
  String get welcomeCockpitBody =>
      'Instant P&L tracking, live prices, and actionable explainable signals.';

  @override
  String get authCreateAnAccount => 'Create an Account';

  @override
  String get homeBackToExit => 'Press back again to exit Nivaarth';

  @override
  String get legalAcknowledge => 'I Understand & Acknowledge';

  @override
  String get syncFetchingPrices => 'Fetching Latest Market Prices...';

  @override
  String get syncReady => 'Portfolio Ready';

  @override
  String get syncFailed =>
      'Portfolio could not be loaded. Tap Try Again on the Portfolio tab.';

  @override
  String get syncPreparing => 'Preparing your portfolio intelligence';

  @override
  String get syncDontClose =>
      'Please don\'t close the app.\nWe\'re preparing the latest market intelligence.';

  @override
  String get menuFeedbackTitle => 'Share Feedback / Report Bug';

  @override
  String get menuFeedbackBody => 'Direct channel to the engineering team';

  @override
  String get menuLegalTitle => 'Compliance & Legal Disclaimers';

  @override
  String get menuLegalBody => 'SEBI non-advisory notice & platform terms';

  @override
  String get menuLogOut => 'Log out';

  @override
  String get menuLogOutBody => 'Sign out and return to welcome screen';

  @override
  String get feedbackTitle => 'Friends Beta Feedback';

  @override
  String get feedbackPrompt =>
      'Found a bug or have a suggestion? Let us know directly:';

  @override
  String get feedbackHint => 'Describe the issue or idea...';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get feedbackThanks =>
      'Thank you! Your feedback has been noted for the next release.';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get logoutConfirmTitle => 'Log out of Nivaarth?';

  @override
  String get logoutConfirmBody =>
      'You will need to sign in again to view your private portfolio cockpit.';

  @override
  String get greetMorning => 'Good morning,';

  @override
  String get greetAfternoon => 'Good afternoon,';

  @override
  String get greetEvening => 'Good evening,';

  @override
  String get tipShowValues => 'Show Values';

  @override
  String get tipHideValues => 'Hide Values (Privacy Mode)';

  @override
  String get tipProfile => 'Profile & Details';

  @override
  String get tipNotifications => 'Notifications';

  @override
  String get dashLoadingTitle => 'Building portfolio cockpit';

  @override
  String get dashLoadingBody =>
      'Fetching live valuation, health scores and AI signals.';

  @override
  String get dashUnavailable => 'Dashboard unavailable';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get dashBriefingSub => 'What the numbers of your holdings show today.';

  @override
  String get dashWelcome => 'Welcome to Nivaarth Cockpit';

  @override
  String get dashTools => 'Nivaarth research tools';

  @override
  String get dashAddPrompt =>
      'Add your current equity holdings to activate real-time analytics:';

  @override
  String get dashToolScore => 'Rules-based NV Score (0-100)';

  @override
  String get dashToolScoreSub => 'Quality 50%, Valuation 30%, Price trend 20%';

  @override
  String get dashToolHealth => 'Dynamic Portfolio Health & Risk Radar';

  @override
  String get dashToolHealthSub =>
      'Concentration, sector mix and holdings below their buy price';

  @override
  String get dashToolAdvisor => 'NV Advisor Contextual Co-Pilot';

  @override
  String get dashToolAdvisorSub =>
      'Ask about your holdings; answers use your data and NV Scores';

  @override
  String get dashAddFirst => 'Add Your First Holding';

  @override
  String get indexMarketClosed => 'MARKET CLOSED';

  @override
  String get indexPerformance => 'Market Index Performance';

  @override
  String get indexChartUnavailable => 'Index chart unavailable right now';

  @override
  String get indexRanges => 'Price Spectrum & Ranges';

  @override
  String get indexTodayRange => 'Today\'s Range';

  @override
  String get indexTodayRangeNa => 'Today\'s range unavailable';

  @override
  String get index52wRange => '52-Week Range';

  @override
  String get index52wLoading => '52-week range loading…';

  @override
  String get index52wNa => '52-week range unavailable';

  @override
  String indexAbout(Object name) {
    return 'About $name';
  }

  @override
  String get indexAboutNifty =>
      'The NIFTY 50 is India\'s benchmark stock market index representing the weighted average of 50 of the largest and most liquid Indian companies listed on the National Stock Exchange. It serves as the primary gauge of India\'s broader economy and capital markets.';

  @override
  String get indexAboutSensex =>
      'The BSE SENSEX is India\'s oldest and premier market barometer comprising 30 prominent, financially sound, and actively traded companies listed on the Bombay Stock Exchange, covering major sectors of the Indian economy.';

  @override
  String get indexLargestSectors => 'Largest sectors in the index';

  @override
  String get indexWeightsNifty =>
      'Current sector weights are in the monthly NIFTY 50 factsheet on niftyindices.com.';

  @override
  String get indexWeightsSensex =>
      'Current sector weights are in the BSE SENSEX factsheet on bseindia.com.';

  @override
  String get indexTechnical => 'Technical Indicators';

  @override
  String get indexTechnicalSub =>
      'Calculated from daily closing prices over the last year.';

  @override
  String get indexLoadingDaily => 'Loading daily prices…';

  @override
  String get indexIndicatorsNa => 'Indicators unavailable right now.';

  @override
  String get indexPriceAbove => 'Price above';

  @override
  String get indexPriceBelow => 'Price below';

  @override
  String get indexEma20 => '20-day EMA';

  @override
  String get indexAvg50 => '50-day average';

  @override
  String get indexAvg200 => '200-day average';

  @override
  String get indexOverbought => 'Overbought zone (70+)';

  @override
  String get indexOversold => 'Oversold zone (30-)';

  @override
  String get indexNeutral => 'Neutral zone';

  @override
  String get indexRsi => 'RSI (14 days)';

  @override
  String get indexNotEnough => 'Not enough daily prices yet.';

  @override
  String get briefCoverageNa => 'Data coverage —';

  @override
  String briefCoverage(Object pct) {
    return '$pct% Data coverage';
  }

  @override
  String get briefReasons => 'Reasons';

  @override
  String get briefToCheck => 'What to check';

  @override
  String get allocTitle => 'Portfolio split';

  @override
  String get allocMarketCap => 'Market cap';

  @override
  String get allocSector => 'Sector';

  @override
  String get allocCapNote =>
      'Large: top 100 companies by market cap · Mid: 101–250 · Small: the rest';

  @override
  String get commonShare => 'Share';

  @override
  String get allocShareSector => 'Portfolio: by sector';

  @override
  String get allocShareCap => 'Portfolio: by market cap';

  @override
  String get signalWinner => 'BIGGEST WINNER';

  @override
  String get signalStrongest => 'STRONGEST HOLDING';

  @override
  String get signalNotAssessed => 'Not assessed';

  @override
  String get signalDiversification => 'DIVERSIFICATION';

  @override
  String signalTopSector(Object pct) {
    return 'Top sector $pct%';
  }

  @override
  String get topHoldingsTitle => 'Top Holdings';

  @override
  String get topHoldingsSub => 'Ranked by highest current valuation (₹)';

  @override
  String get commonViewAll => 'View all';

  @override
  String get macroBreadth => 'Breadth';

  @override
  String macroAdvances(Object n) {
    return '$n up';
  }

  @override
  String macroDeclines(Object n) {
    return '$n down';
  }

  @override
  String get macroWhatIf => 'If this happens';

  @override
  String get healthIndex => 'NV HEALTH INDEX';

  @override
  String get commonLive => 'Live';

  @override
  String get commonMarketClosed => 'Market closed';

  @override
  String get healthCoverageNa => 'Data coverage: —';

  @override
  String healthCoverage(Object pct) {
    return 'Data coverage: $pct%';
  }

  @override
  String healthStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String get healthExplain =>
      'Average NV Score of your scored holdings, weighted by value.';

  @override
  String get healthOpenAdvisorHint => 'Open NV Advisor from the bottom bar.';

  @override
  String get healthOpenAdvisor => 'Open Advisor';

  @override
  String get healthMarketOpenNote =>
      'Market open: prices refresh every few minutes. NV Scores update every evening.';

  @override
  String get healthMarketClosedNote =>
      'Market closed: prices are the last close. NV Scores update every evening.';

  @override
  String heroQuiet(Object count, Object names) {
    return '$count stocks had no trade in 15 min ($names) — the price is from the last trade';
  }

  @override
  String get heroClosedNote => 'Market closed · today\'s closing prices';

  @override
  String heroUnpriced(Object count) {
    return 'No price for $count stocks — not included in the total';
  }

  @override
  String heroStale(Object count) {
    return '$count stocks did not update in this refresh — showing the last saved price';
  }

  @override
  String get heroValue => 'PORTFOLIO VALUE';

  @override
  String get heroTotalPl => 'Total P&L';

  @override
  String get heroToday => 'Today';

  @override
  String holdingRemoveTitle(Object symbol) {
    return 'Remove $symbol?';
  }

  @override
  String holdingRemoveBody(Object symbol) {
    return '$symbol and all its trades will be removed from the portfolio.\n\nSold the shares? Then don\'t delete: open the stock and add a SELL trade, so the trade history and the \"last time\" figures stay.';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String holdingRemoved(Object symbol) {
    return '$symbol removed.';
  }

  @override
  String get commonPriceUnavailable => 'Price unavailable';

  @override
  String get holdingEdit => 'Edit Holding';

  @override
  String get holdingDelete => 'Delete Holding';

  @override
  String heroClosedOn(Object date) {
    return 'Market closed · closing prices of $date';
  }

  @override
  String heroRefreshedAt(Object time) {
    return 'Refreshed at $time';
  }

  @override
  String heroRefreshedOn(Object date, Object time) {
    return 'Refreshed $date, $time';
  }

  @override
  String get closedTitle => 'Closed positions';

  @override
  String get closedLoadFailed => 'Closed positions could not be loaded';

  @override
  String get commonCheckInternet => 'Check your internet and try again.';

  @override
  String get closedEmptyTitle => 'No closed positions';

  @override
  String get closedEmptyBody =>
      'When you fully sell a stock, it will appear here with its realized P&L.';

  @override
  String closedCount(Object count) {
    return '$count stocks fully sold';
  }

  @override
  String closedRealized(Object amount) {
    return 'Realized $amount';
  }

  @override
  String tradeBought(Object amount) {
    return 'Bought $amount';
  }

  @override
  String tradeSold(Object amount) {
    return 'Sold $amount';
  }

  @override
  String closedLastSell(Object date) {
    return 'Last sell $date';
  }

  @override
  String closedTrades(Object count) {
    return '$count trades';
  }

  @override
  String get importStarting => 'Starting…';

  @override
  String get importTitle => 'Tradebook import';

  @override
  String get importHeading => 'Zerodha tradebook (CSV or Excel)';

  @override
  String get importSteps =>
      'Console → Reports → Tradebook → Segment: Equity → Download (CSV or XLSX). You will see a preview first; nothing is saved until you tap \"Import\". Adding the same file again will not add the earlier trades twice.';

  @override
  String get importPickFile => 'Choose file (CSV / XLSX)';

  @override
  String get importPickOther => 'Choose another file';

  @override
  String importDone(Object count, Object stocks) {
    return '$count trades imported ($stocks stocks).';
  }

  @override
  String importSummary(Object stocks, Object trades) {
    return '$stocks stocks · $trades new trades';
  }

  @override
  String importUnlisted(Object symbols) {
    return 'These symbols are not in Nivaarth\'s list and will not be imported: $symbols. ';
  }

  @override
  String get importRenamed =>
      '(If the name changed, as after a demerger, add the stock yourself from Add Holding.)';

  @override
  String get importBonusNote =>
      'Bonuses and splits are not in the tradebook. If such a stock\'s quantity differs from your broker\'s, check that stock.';

  @override
  String get importNothingNew => 'Nothing new to import';

  @override
  String importConfirm(Object trades, Object stocks) {
    return 'Import ($trades trades, $stocks stocks)';
  }

  @override
  String get importNotHeld => 'Not in the portfolio now';

  @override
  String importHeldNow(Object qty) {
    return 'Now: $qty shares';
  }

  @override
  String get importFromBook => 'Build from tradebook';

  @override
  String get importOnlyNew => 'Add new only';

  @override
  String get importFromBookNote =>
      'The old opening holding goes away; the holding is built only from tradebook trades.';

  @override
  String get importOnlyNewNote =>
      'The old holding stays and tradebook trades are added on top (careful: old buys must not be added twice).';

  @override
  String importManualWarn(Object count) {
    return 'You also entered $count trades of this stock by hand. If the same trade is in the tradebook, it will be added twice; after import, check Trade book and remove the repeated trade.';
  }

  @override
  String importError(Object error) {
    return 'Will not be imported: $error';
  }

  @override
  String importResultClosed(Object pl) {
    return 'After import: fully sold (Closed positions), realized $pl';
  }

  @override
  String importResultOpen(Object qty, Object avg, Object invested) {
    return 'After import: $qty shares @ $avg · Invested $invested';
  }

  @override
  String get addHolding => 'Add Holding';

  @override
  String get portfolioLoadingTitle => 'Loading holdings';

  @override
  String get portfolioLoadingBody => 'Pulling your live portfolio positions.';

  @override
  String get portfolioUnavailable => 'Portfolio unavailable';

  @override
  String get portfolioEmptyTitle => 'No Portfolio Holdings Yet';

  @override
  String get portfolioEmptyBody =>
      'Add your investment positions to unlock real-time Indian stock valuations, P&L, and AI scores.';

  @override
  String get portfolioAddFirst => 'Add Your First Stock';

  @override
  String get portfolioOpenTradeBook => 'View trade book';

  @override
  String get portfolioImport => 'Zerodha tradebook import';

  @override
  String get tradeBookTitle => 'Trade book';

  @override
  String portfolioTracked(Object count) {
    return '$count holdings under active tracking.';
  }

  @override
  String get sortAlphabetical => 'Alphabetical (A-Z)';

  @override
  String get sortTodayGainers => 'Today\'s Top Gainers (₹)';

  @override
  String get sortTodayLosers => 'Today\'s Top Losers (₹)';

  @override
  String get sortOverallGainers => 'Overall Top Gainers (%)';

  @override
  String get sortOverallLosers => 'Overall Top Losers (%)';

  @override
  String get sortHighestValue => 'Highest Value (₹)';

  @override
  String get commonShowLess => 'Show less';

  @override
  String commonSeeAll(Object count) {
    return 'See all ($count)';
  }

  @override
  String get sortShortTodayGainers => 'Today\'s Gainers';

  @override
  String get sortShortTodayLosers => 'Today\'s Losers';

  @override
  String get sortShortGainers => 'Top Gainers';

  @override
  String get sortShortLosers => 'Top Losers';

  @override
  String get sortShortValue => 'Valuation';

  @override
  String get portfolioValuation => 'PORTFOLIO VALUATION';

  @override
  String get metricInvested => 'Invested';

  @override
  String get metricHoldings => 'Holdings';

  @override
  String metricPositions(Object count) {
    return '$count Positions';
  }

  @override
  String get metricWinRatio => 'Win Ratio';

  @override
  String get heatReturnTitle => 'Return Heatmap';

  @override
  String heatUpDown(Object up, Object down) {
    return '$up Up • $down Down';
  }

  @override
  String get heatOverall => 'Overall';

  @override
  String get heatTodayPl => 'Today\'s P&L';

  @override
  String get heatGainersFirst => 'Gainers first';

  @override
  String get heatLosersFirst => 'Losers first';

  @override
  String get heatEmpty => 'No holdings to display';

  @override
  String get tradesLoadFailed => 'Trades could not be loaded';

  @override
  String get tradesEmptyTitle => 'No trades yet';

  @override
  String get tradesEmptyBody =>
      'Every trade you add, buy or sell will appear here by day.';

  @override
  String get tradesSearchHint => 'Search by stock (e.g. POLYCAB)';

  @override
  String tradesCountDays(Object trades, Object days) {
    return '$trades trades · $days days';
  }

  @override
  String get tradesNoMatch => 'No trade found with this name.';

  @override
  String get tradeOpeningHolding => 'Opening holding';

  @override
  String get tradeBonusSplit => 'Shares from bonus/split';

  @override
  String lastTimeTitle(Object symbol) {
    return '$symbol: last time';
  }

  @override
  String lastTimeDates(Object from, Object to, Object days) {
    return '$from to $to ($days days)';
  }

  @override
  String get lastTimeBought => 'Bought';

  @override
  String get lastTimeSold => 'Sold';

  @override
  String lastTimeRounds(Object count) {
    return 'You have fully sold this stock $count times; the figures above are for the latest one.';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get addSelectStock => 'Please search and select a stock symbol.';

  @override
  String get addValidQty => 'Please enter a valid quantity greater than 0.';

  @override
  String get addValidPrice => 'Please enter a valid average buy price.';

  @override
  String addDone(Object symbol) {
    return '$symbol added to portfolio successfully!';
  }

  @override
  String addMerged(Object symbol, Object qty) {
    return '$symbol: $qty shares added, average updated.';
  }

  @override
  String get addTitle => 'Add Stock Holding';

  @override
  String get addSubtitle =>
      'Search any NSE/BSE stock to auto-fill details and start live AI tracking.';

  @override
  String get addSearchHint =>
      'Search Stock Symbol (e.g. RELIANCE, TITAN, INFY)';

  @override
  String get addCompanyName => 'Company Name';

  @override
  String get addFetchingPrice => 'Fetching live price...';

  @override
  String addCurrentPrice(Object price) {
    return 'Current Price: $price';
  }

  @override
  String get addUseAsBuy => '[Use as Buy Price]';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get addAvgBuyPrice => 'Avg Buy Price (₹)';

  @override
  String get commonBuyPrice => 'Buy Price (₹)';

  @override
  String get addToPortfolio => 'Add to Portfolio';

  @override
  String get addToPortfolioAvg => 'Add to portfolio (update avg)';

  @override
  String get tradeQtyPositive => 'Quantity must be more than 0.';

  @override
  String get tradePricePositive => 'Price must be more than 0.';

  @override
  String tradeNotEnough(Object have, Object selling) {
    return 'Not enough shares: you have $have, selling $selling.';
  }

  @override
  String tradeSellSaved(Object symbol, Object qty) {
    return '$symbol: sale of $qty shares recorded.';
  }

  @override
  String get tradeRemoveOpening => 'Remove opening holding?';

  @override
  String get tradeRemoveThis => 'Remove this trade?';

  @override
  String tradeRemoveOpeningBody(Object qty, Object price) {
    return 'This is your holding from before Trade entry: $qty shares @ $price. Removing it takes these $qty shares out of the portfolio.\n\nIf you sold the shares, don\'t remove this; add a SELL trade.';
  }

  @override
  String get tradeRebuilt =>
      'The holding will be rebuilt from the remaining trades.';

  @override
  String get tradeYesRemove => 'Yes, remove';

  @override
  String get tradeRemove => 'Remove';

  @override
  String tradeRemoved(Object symbol) {
    return '$symbol: trade removed.';
  }

  @override
  String holdingRemoveBodyFinal(Object symbol) {
    return '$symbol and all its trades will be removed from the portfolio. This cannot be undone.\n\nSold the shares? Then don\'t delete; add a SELL trade, so the trade history and the \"last time\" figures stay.';
  }

  @override
  String holdingRemovedFull(Object symbol) {
    return '$symbol removed from portfolio.';
  }

  @override
  String tradeAddFor(Object symbol) {
    return 'Add trade · $symbol';
  }

  @override
  String get editHolding => 'Holding';

  @override
  String get editTotalInvested => 'Total Invested';

  @override
  String get editRealized => 'Realized P&L (avg cost)';

  @override
  String get editLtp => 'Current Market Price (LTP)';

  @override
  String get commonSellPrice => 'Sell Price (₹)';

  @override
  String get tradeAdd => 'Add trade';

  @override
  String get tradesHeading => 'Trades';

  @override
  String tradesLoadError(Object error) {
    return 'Trades could not be loaded: $error';
  }

  @override
  String get tradesNoneYet =>
      'No trades recorded yet. As soon as you add the first trade, your current holding becomes an \"Opening holding\" trade.';

  @override
  String get tradeRemoveTip => 'Remove trade';

  @override
  String sellDoneTitle(Object symbol, Object qty) {
    return '$symbol: $qty shares sold';
  }

  @override
  String get sellRealized => 'Realized P&L of this sale';

  @override
  String sellDetail(Object qty, Object price, Object avg) {
    return 'Sold $qty @ $price; the average was $avg.';
  }

  @override
  String sellAllGone(Object symbol) {
    return 'All shares sold. $symbol is now in Closed positions.';
  }

  @override
  String sellRemaining(Object left, Object avg, Object invested) {
    return 'Left: $left shares @ $avg (a sale does not change the average). Invested now $invested.';
  }

  @override
  String styleFunds(Object pct) {
    return 'ETF / funds $pct';
  }

  @override
  String styleLoss(Object pct) {
    return 'Loss-making $pct';
  }

  @override
  String styleNoData(Object pct) {
    return 'No data $pct';
  }

  @override
  String get styleTitle => 'Investment style';

  @override
  String get styleWhatTip => 'What is this?';

  @override
  String get styleLargest => 'Largest share';

  @override
  String stylePctPortfolio(Object pct) {
    return '$pct% portfolio';
  }

  @override
  String get styleShare => 'Share';

  @override
  String get styleRankNote =>
      'Growth and Value are ranks from 0 to 100, like a rank in class. 60 or above means strong on that side.';

  @override
  String get styleWhatTitle => 'What is Investment style?';

  @override
  String get styleWhatIntro =>
      'This card is a mirror of your portfolio. It shows what kind of companies your money is in. It is not a suggestion to buy or sell.';

  @override
  String get styleSizeHead => 'Company size';

  @override
  String get styleLarge => 'Large: the 100 biggest companies.';

  @override
  String get styleMid => 'Mid: the next 150 companies.';

  @override
  String get styleSmall => 'Small: companies smaller than that.';

  @override
  String get styleMicro => 'Micro: companies under ₹1,000 crore.';

  @override
  String get styleTypeHead => 'Company type';

  @override
  String get styleGrowth => 'Growth: growing fast, but the share is not cheap.';

  @override
  String get styleValue =>
      'Value: the share is cheap, but the company is not growing especially fast.';

  @override
  String get styleBoth =>
      'Growth + Value: growing fast and cheap too. Such companies are rare.';

  @override
  String get styleOthers =>
      'Others: neither especially fast nor especially cheap.';

  @override
  String get styleTableHead => 'How to read the table';

  @override
  String get styleTableBody =>
      'Each box shows how much of the portfolio is in that size and type. Say ₹100 is invested: 18.0% means ₹18.';

  @override
  String get styleTableBody2 =>
      'The box with a gold border is the largest share. The darker the colour, the bigger the share. Tap a box to see its stocks.';

  @override
  String get styleHowHead => 'How the type is decided';

  @override
  String get styleHow1 =>
      'Each company is compared with companies of its own size, like a rank in class.';

  @override
  String get styleHow2 =>
      'Growth rank: how much sales and profit grew over the last 3 and 5 years.';

  @override
  String get styleHow3 =>
      'Value rank: how cheap the share is by P/E, P/B and dividend.';

  @override
  String get styleHow4 =>
      'A rank of 60 or above puts the company in that type.';

  @override
  String get styleBelowHead => 'The line below';

  @override
  String get styleBelowBody =>
      'ETFs and funds are not companies, and loss-making companies have no P/E. So they are listed separately, outside the table.';

  @override
  String get styleNoteHead => 'Keep in mind';

  @override
  String get styleNoteBody =>
      'The rank is against other companies, so the label can change over time.';

  @override
  String get perfBackcast =>
      'If today\'s holdings had been held the whole time. This is not your actual return.';

  @override
  String perfFooter(Object date) {
    return 'Price only, dividends not included. Data up to $date.';
  }

  @override
  String get perfPartial =>
      'Some holdings lack full past data. The graph is built on the remaining holdings without them.';

  @override
  String get movesToday => 'Today';

  @override
  String get movesLastSession => 'Last session';

  @override
  String get movesLegend =>
      'Box size: share of the portfolio. Colour: that day\'s change.';

  @override
  String get movesGainers => 'Top gainers';

  @override
  String get movesLosers => 'Top losers';

  @override
  String get tradeDateHelp => 'Trade date';

  @override
  String get tradeDate => 'Trade date';

  @override
  String get tradeZeroLeft => '0 shares (fully sold)';

  @override
  String get tradeNow => 'Now';

  @override
  String get tradeAfter => 'After the trade';

  @override
  String importFailed(Object count) {
    return ' $count stocks failed; their holdings are unchanged:';
  }

  @override
  String importDuplicates(Object count) {
    return ' · $count already imported (skipped)';
  }

  @override
  String importSkipped(Object count) {
    return ' · $count rows skipped (F&O / unreadable)';
  }

  @override
  String importStockLine(Object count, Object skip) {
    return '$count trades$skip';
  }

  @override
  String savedRemoved(Object symbol) {
    return '$symbol removed from MY SAVED LIST';
  }

  @override
  String savedAdded(Object symbol, Object price) {
    return '$symbol saved to MY SAVED LIST at $price';
  }

  @override
  String alertButtonCount(Object count) {
    return 'Price alert · $count set';
  }

  @override
  String get alertButton => 'Set price alert';

  @override
  String get stockPricePerformance => 'Price Performance';

  @override
  String get stockChartSoon => 'Historical Chart Coming Soon';

  @override
  String get stockWatchlistAsset => 'Watchlist Asset';

  @override
  String get stockNotOwned => 'Not currently in your owned portfolio.';

  @override
  String get stockScoreFailed => 'Unable to load AI Score';

  @override
  String stockAnalyzing(Object symbol) {
    return 'Analyzing $symbol signals...';
  }

  @override
  String get stockScoring =>
      'Scoring quality, valuation and price trend from the latest data.';

  @override
  String get stockSaved => 'Saved';

  @override
  String get stockSave => '+ Save';

  @override
  String get aiRulesBased => 'Rules-based research score';

  @override
  String get aiHowWorks => 'How the NV Score works';

  @override
  String get aiDataPending => 'Data Pending';

  @override
  String get aiDataReview => 'Data Under Review';

  @override
  String get aiExcluded => 'Score Excluded';

  @override
  String get aiCreditPending => 'Credit Pending';

  @override
  String get aiBrokerLeverage => 'Broker MTF Leverage';

  @override
  String get aiDebtNotAssessed => 'Debt Not Assessed';

  @override
  String get aiWhyScore => 'Why this score';

  @override
  String get aiMethodology => 'Methodology';

  @override
  String aiNoScore(Object reason) {
    return 'No NV Score yet: $reason. The score needs at least 3 of 4 quality inputs and is not built on assumed values.';
  }

  @override
  String get aiReviewBody =>
      'The source data for this stock did not match the exchange (market cap or price belong to a different company), so it is being reviewed. No score is shown rather than a score built on wrong numbers.';

  @override
  String get aiInsurance =>
      'Life and General Insurance firms operate on actuarial float and statutory accounting. Quantitative 1-100 scoring is withheld until dedicated Embedded Value (EV) models are integrated.';

  @override
  String get aiHolding =>
      'Investment holding companies trade at variable net asset value (NAV) discounts. Standard operating multiples (P/E, ROCE) are not applicable; specialized SOTP research is recommended.';

  @override
  String get aiReit =>
      'Real Estate & Infrastructure Investment Trusts operate on distribution yield and Net Asset Value (NAV). Standard industrial scoring is withheld.';

  @override
  String get aiSpecialised =>
      'The 1-100 score is not calculated for this stock: its accounts need a specialised valuation method.';

  @override
  String aiScoreOnly(Object score) {
    return 'NV Score $score/100. The pillar breakdown appears after the next score update.';
  }

  @override
  String aiHighest(Object score, Object pillar) {
    return 'NV Score $score/100. Highest: $pillar';
  }

  @override
  String aiLowest(Object pillar) {
    return '; lowest: $pillar';
  }

  @override
  String aiRiskCap(Object cap) {
    return ' A risk check failed, which caps the score at $cap.';
  }

  @override
  String get aiHurdle => ' Quality is below 55, so the score is scaled down.';

  @override
  String get companyOverview => 'Company Overview';

  @override
  String get companyLabel => 'Company';

  @override
  String get companyIndustry => 'Industry';

  @override
  String get companyStatus => 'Status';

  @override
  String get holdingDetails => 'Holding Details';

  @override
  String get holdingAvgPrice => 'Average Price';

  @override
  String get holdingCurrentPrice => 'Current Price';

  @override
  String get holdingInvested => 'Invested Value';

  @override
  String get holdingCurrentValue => 'Current Value';

  @override
  String get holdingNetPl => 'Net P&L';

  @override
  String get holdingReturn => 'Return';

  @override
  String get holdingDayPl => 'Day\'s P&L';

  @override
  String get thesisTitle => 'Investment Thesis';

  @override
  String get thesisNone => 'No investment thesis available for this stock yet.';

  @override
  String get thesisReview => 'Review this thesis after every quarterly result.';

  @override
  String get newsTitle => 'Latest News';

  @override
  String get newsSub => 'AI curated market updates';

  @override
  String get newsEmptyTitle => 'No News Available';

  @override
  String get newsEmptyBody =>
      'Latest company news and market updates will automatically appear here when available.';

  @override
  String get newsAutoRefresh => 'Auto Refresh';

  @override
  String get peersTitle => 'Compared with peers';

  @override
  String get peersAdd => 'Add another peer';

  @override
  String get peersChange => 'Change peer';

  @override
  String get peersDashNote =>
      '— means no data. A loss-making company has no P/E.';

  @override
  String get alertRemoveTip => 'Remove alert';

  @override
  String get alertRemoveFailed =>
      'Could not remove the alert. Please try again.';

  @override
  String get alertDuplicate => 'This alert is already set';

  @override
  String alertMax(Object max) {
    return 'You can have up to $max alerts at once';
  }

  @override
  String get alertSaveFailed => 'Could not save the alert. Please try again.';

  @override
  String alertTitle(Object symbol) {
    return 'Price alert · $symbol';
  }

  @override
  String alertCurrent(Object price) {
    return 'Current price $price';
  }

  @override
  String get alertAbove => 'Goes above';

  @override
  String get alertBelow => 'Falls below';

  @override
  String get alertPriceHint => 'Price (₹)';

  @override
  String get alertSaving => 'Saving...';

  @override
  String get alertSet => 'Set alert';

  @override
  String get alertNote =>
      'During market hours the price is checked every 5 minutes. When it reaches your price, it shows in Notifications. All alerts: Notifications > My price alerts.';

  @override
  String get alertsMine => 'My price alerts';

  @override
  String get alertsLoadFailed => 'Alerts could not be loaded';

  @override
  String get alertsNone => 'No active alerts. Set one from any stock\'s page.';

  @override
  String get recSummary => 'DATA SUMMARY';

  @override
  String get recPlaybook => 'Tactical Playbook';

  @override
  String get recHeld => 'HELD IN PORTFOLIO';

  @override
  String get recDiscovery => 'DISCOVERY MODE';

  @override
  String get recShows => 'What the data shows';

  @override
  String get recWatch => 'Number to watch';

  @override
  String get recUpdates => 'What updates the score';

  @override
  String recCoverage(Object pct) {
    return 'Data coverage: $pct% • Synthesized from 6 quantitative pillars';
  }

  @override
  String get breakdownPending =>
      'The breakdown appears after the next score update.';

  @override
  String get breakdownNone =>
      'No score for this stock, so there is no breakdown.';

  @override
  String get breakdownNotCounted => 'not counted';

  @override
  String breakdownWeight(Object pct) {
    return '$pct% weight';
  }

  @override
  String get breakdownRiskFlag => 'Risk flag';

  @override
  String breakdownRiskCap(Object cap) {
    return 'Score capped at $cap (pledge, net worth or debt check failed)';
  }

  @override
  String get breakdownHurdle => 'Quality hurdle';

  @override
  String breakdownHurdleBody(Object hurdle) {
    return '× $hurdle (quality below 55)';
  }

  @override
  String get breakdownQualityCap => 'Quality cap';

  @override
  String breakdownQualityCapBody(Object cap) {
    return 'Capped at $cap (54 below quality 55, rising to no cap at 65)';
  }

  @override
  String get breakdownLenderCap => 'Lender / broker cap';

  @override
  String breakdownLenderCapBody(Object cap) {
    return 'Capped at $cap until credit data is added';
  }

  @override
  String get breakdownNote => 'Note';

  @override
  String get shareDownloaded => 'Image downloaded.';

  @override
  String get shareFailed => 'Could not share. Please try again.';

  @override
  String get commonClose => 'Close';

  @override
  String get stockSyncing => 'Syncing...';

  @override
  String stockAllTime(Object amount, Object pct) {
    return 'All-Time: $amount   ($pct)';
  }

  @override
  String stockToday(Object amount, Object pct) {
    return 'Today: $amount   ($pct)';
  }

  @override
  String get stockExchange => 'Exchange';

  @override
  String get stockTrend => 'Trend';

  @override
  String get chartUpdating => 'Chart updating...';

  @override
  String get radarTitle => 'Score shape';

  @override
  String get radarNoteLeverage =>
      'Each score is 0–100, higher toward the outside. In Leverage a higher score means less leverage.';

  @override
  String get radarNoteDebt =>
      'Each score is 0–100, higher toward the outside. In Debt a higher score means less debt.';

  @override
  String get breakdownHintQuality =>
      'Return on capital, debt, cash conversion and 5-year growth';

  @override
  String get breakdownHintValuation => 'P/E vs sector peers and earnings yield';

  @override
  String get breakdownHintMomentum =>
      '12-month return, latest month left out, ranked against all stocks';

  @override
  String get shareDisclaimer =>
      'For information only. This is not investment advice.';

  @override
  String get searchTitle => 'Search & Watchlist';

  @override
  String searchTracked(Object count) {
    return '$count Tracked';
  }

  @override
  String get searchSub => 'Prices, NV Scores and watchlist tracking.';

  @override
  String get searchExplore => 'Explore Stocks';

  @override
  String get searchHint =>
      'Search stock by symbol or name (e.g. TAT, KEI, APO)...';

  @override
  String get searchingTitle => 'Searching market universe';

  @override
  String get searchingBody => 'Matching symbols and AI scores.';

  @override
  String get searchUnavailable => 'Search unavailable';

  @override
  String get searchStartTitle => 'Start with a symbol';

  @override
  String get searchStartBody => 'Search any stock to see its NV Score.';

  @override
  String get searchNoneTitle => 'No stock found';

  @override
  String get searchNoneBody => 'Try another instrument or company name.';

  @override
  String get watchRemove => 'Remove from Watchlist';

  @override
  String get watchAdd => 'Add to Watchlist';

  @override
  String watchSavedAt(Object symbol, Object price) {
    return '$symbol saved at $price';
  }

  @override
  String watchAdded(Object symbol) {
    return '$symbol added to watchlist';
  }

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get watchRemoveConfirm => 'Remove from Watchlist?';

  @override
  String watchRemoveBodyPrice(Object name, Object symbol, Object price) {
    return 'Are you sure you want to remove $name ($symbol)? Your tracked entry price ($price) will be cleared.';
  }

  @override
  String watchRemoveBody(Object name, Object symbol) {
    return 'Are you sure you want to remove $name ($symbol) from your watchlist?';
  }

  @override
  String get watchEmptyTitle => 'No stocks in watchlist';

  @override
  String get watchEmptyBody =>
      'Search any stock and tap \"+ Save\" to track it here.\nPull down to sync and refresh.';

  @override
  String get watchColCompany => 'Company ⬍';

  @override
  String get watchColScore => 'Score ⬍';

  @override
  String get watchColAdded => 'Added Price';

  @override
  String get watchColLatest => 'Latest Price ⬍\nChange';

  @override
  String get watchColReturns => 'Returns ⬍\nTracked Date';

  @override
  String get watchColTech => 'Technical & Things you should know';

  @override
  String get watchColAction => 'Action';

  @override
  String get watchEntry => 'Entry Point';

  @override
  String get notifMarkAll => 'Mark all as read';

  @override
  String get notifMarked => 'All alerts marked as read.';

  @override
  String notifFailed(Object error) {
    return 'Failed to load notifications:\n$error';
  }

  @override
  String notifActive(Object count) {
    return '$count active';
  }

  @override
  String get notifJustNow => 'Just now';

  @override
  String notifMinutes(Object n) {
    return '${n}m ago';
  }

  @override
  String notifHours(Object n) {
    return '${n}h ago';
  }

  @override
  String notifDays(Object n) {
    return '${n}d ago';
  }

  @override
  String get notifEmptyTitle => 'No Alerts in this Category';

  @override
  String get notifEmptyBody =>
      'Your portfolio is stable and within risk limits.';

  @override
  String get advBusy =>
      'NV Advisor is busy or there is a connection issue. Please ask again in a little while.';

  @override
  String get advNoReply => 'No reply yet';

  @override
  String get advHistoryTitle => 'Today\'s History';

  @override
  String advQueries(Object count) {
    return '$count Queries';
  }

  @override
  String get advNoHistory => 'No conversation yet today.';

  @override
  String get advSub => 'Research assistant for your holdings';

  @override
  String get advClear => 'Clear Chat';

  @override
  String get advReset =>
      'Chat reset. You can ask me anything about your portfolio!';

  @override
  String get advAnalyzing => 'NV Advisor analyzing...';

  @override
  String get advHint => 'Ask NV Advisor anything about your portfolio...';

  @override
  String get riskLoadFailed => 'Portfolio could not be loaded';

  @override
  String get riskNoStocks => 'No stocks in the portfolio';

  @override
  String get riskDisclaimer =>
      'This is an estimate from the past 1 year\'s beta, not a prediction. The actual fall can differ. No trade happens here, and this is not investment advice.';

  @override
  String get riskBetaNote =>
      '1.00 means it moves as much as Nifty. Above 1 means more.';

  @override
  String riskNoBeta(Object stocks, Object pct) {
    return '$stocks have no beta. Built on $pct of the portfolio.';
  }

  @override
  String riskPeExcluded(Object stocks, Object pct) {
    return '$stocks not in P/E (loss-making or ETF). P/E is built on $pct of the portfolio.';
  }

  @override
  String get riskIfFalls => 'If the market falls';

  @override
  String get riskBetaNa =>
      'Beta is not available right now, so this cannot be worked out.';

  @override
  String riskEstimated(Object amount) {
    return 'Estimated change $amount';
  }

  @override
  String riskNotCounted(Object stocks) {
    return '$stocks not counted, as they have no beta.';
  }

  @override
  String get riskMostImpact => 'Biggest effect';

  @override
  String riskStockShare(Object name) {
    return '$name share';
  }

  @override
  String get riskStockNoBeta =>
      'This stock has no beta, so it is not counted in portfolio beta.';

  @override
  String get riskIfChange => 'If this stock changes';

  @override
  String get riskStockField => 'Stock name or symbol';

  @override
  String get riskYouHold => 'You hold';

  @override
  String get riskAdd => 'Add';

  @override
  String get riskReduce => 'Reduce';

  @override
  String get riskAmount => 'Amount (₹)';

  @override
  String riskWarnStock(Object symbol, Object pct, Object limit) {
    return '$symbol would be $pct% of the portfolio, above the $limit% line.';
  }

  @override
  String get alertEnterPrice => 'Enter a valid price';

  @override
  String get alertMustAbove => 'The price must be above the current price';

  @override
  String get alertMustBelow => 'The price must be below the current price';

  @override
  String caTitle(Object symbol, Object label) {
    return '$symbol: $label announced';
  }

  @override
  String caBody(Object before, Object extra) {
    return 'You held $before shares that day, so $extra new shares (at ₹0) will be added.';
  }

  @override
  String caNow(Object qty, Object avg) {
    return 'Now: $qty shares @ $avg';
  }

  @override
  String caAfter(Object qty, Object avg) {
    return 'After update: $qty shares @ $avg';
  }

  @override
  String caInvested(Object amount) {
    return 'Invested stays the same: $amount';
  }

  @override
  String get caFraction =>
      'Fractional shares not added: the broker pays cash for them.';

  @override
  String get caMatch =>
      'Match the share count with your broker app. If it is wrong, you can remove it later from Trade book.';

  @override
  String get caLater => 'Later';

  @override
  String get commonNo => 'No';

  @override
  String get caYesAdd => 'Yes, add';

  @override
  String cardLtp(Object price) {
    return 'LTP: $price';
  }

  @override
  String alertWeightTitle(Object symbol) {
    return 'Weight Alert: $symbol';
  }

  @override
  String alertWeightBody(Object symbol, Object pct) {
    return '$symbol accounts for $pct% of your portfolio value, above the 25% concentration line.';
  }

  @override
  String get alertChecksTitle => 'Portfolio checks on';

  @override
  String alertChecksBody(Object count) {
    return 'Concentration is checked across your $count holdings each time alerts load.';
  }

  @override
  String get alertWelcomeBody =>
      'Add your holdings in Portfolio to enable automated algorithmic risk monitoring and technical pivot tracking.';

  @override
  String get errNoInternet =>
      'No internet connection. Check your network and tap Try Again.';

  @override
  String get errGeneric =>
      'Something went wrong while loading. Please try again in a moment.';

  @override
  String get importNotZerodha =>
      'This does not look like a Zerodha tradebook: the symbol, trade_date, trade_type, quantity, price and trade_id columns were not found.';

  @override
  String get advGreeting =>
      'Namaste! I am **NV Advisor**\n\nI am your research assistant. I explain the numbers of your portfolio holdings, P&L, NV Scores, **Peer Comparisons** and **Risk Checks**; I do not give advice to buy or sell.\n\nYou can ask me any portfolio or stock question!';

  @override
  String get advAsk1 => 'Show my portfolio\'s 3 biggest mistakes and risks';

  @override
  String get advAsk2 => 'Tata Motors vs Maruti: which has better growth?';

  @override
  String get advAsk3 => 'Titan vs Trent comparison';

  @override
  String get advAsk4 => 'What are UltraTech\'s price and NV Score?';

  @override
  String get advAsk5 => 'How is my portfolio performing?';

  @override
  String get advAsk6 => 'What is the trend of Nifty 50 and the market?';

  @override
  String caExDate(Object date, Object multiple) {
    return 'Ex-date $date: each 1 share is now $multiple shares. ';
  }

  @override
  String get narrEtf => 'Exchange-Traded Fund';

  @override
  String narrEtfBrief(Object name, Object sector) {
    return '$name is an exchange-traded fund that tracks $sector. Its price follows the underlying basket, so company-level ratios such as ROCE do not apply; the NV Score gives it a fixed quality of 75 and valuation of 60 and scores only its 12-month return rank.';
  }

  @override
  String get narrEtfBasket => 'Diversified basket';

  @override
  String get narrEtfBasketBody =>
      'Holds many securities (or a commodity), so the results of one company move it less than a single stock.';

  @override
  String get narrEtfBenchmark => 'Moves with its benchmark';

  @override
  String get narrEtfBenchmarkBody =>
      'Returns follow the index or commodity it tracks, including its falls.';

  @override
  String narrEtfOwned(Object score) {
    return 'In your portfolio. NV Score $score/100, set mostly by its 12-month return rank.';
  }

  @override
  String narrEtfNotOwned(Object score) {
    return 'NV Score $score/100, set mostly by its 12-month return rank.';
  }

  @override
  String get narrEtfWatch =>
      'Tracking difference against its benchmark and the expense ratio (from the fund house factsheet).';

  @override
  String get narrEtfUpdates =>
      'Daily closing prices update the 12-month return rank.';

  @override
  String get narrNotEnough => 'Not enough quality data yet';

  @override
  String narrPendingBrief(Object name, Object why) {
    return 'No NV Score for $name yet: $why. A score built on too few inputs would be misleading, so none is shown.';
  }

  @override
  String get narrMissing => 'What is missing';

  @override
  String narrMissingBody(Object why) {
    return '$why. The score needs at least 3 of 4 quality inputs (return on capital, debt, cash conversion, growth).';
  }

  @override
  String get narrScorePending => 'Score: Pending';

  @override
  String get narrWhyNoScore => 'Why no score';

  @override
  String get narrNoAssumed =>
      'Missing inputs are not filled with assumed values.';

  @override
  String get narrInputsIncomplete => 'Inputs: Incomplete';

  @override
  String get narrPendingOwned =>
      'Currently in your portfolio. Your holding, price and P&L are unaffected; only the NV Score is pending.';

  @override
  String get narrPendingNotOwned =>
      'Only the NV Score is pending; the live price is unaffected.';

  @override
  String get narrPendingWatch =>
      'The next annual results of the company, which usually fill the missing inputs.';

  @override
  String get narrPendingUpdates =>
      'The score appears automatically once enough data is available.';

  @override
  String narrReviewBrief(Object name) {
    return 'The fundamentals we hold for $name did not match exchange data: the market cap or price belongs to a different company. The score is withheld until the data is corrected.';
  }

  @override
  String get narrChecked => 'What we checked';

  @override
  String get narrCheckedBody =>
      'Stored market cap and price were compared with the NSE closing price and an independent market-cap source.';

  @override
  String get narrCheckFailed => 'Check: Failed';

  @override
  String get narrWrongNumbers =>
      'A score built on another company\'s numbers would be misleading, so none is shown.';

  @override
  String get narrScoreWithheld => 'Score: Withheld';

  @override
  String get narrReviewOwned =>
      'Currently in your portfolio. Your holding, price and P&L are unaffected; only the NV Score is withheld.';

  @override
  String get narrReviewNotOwned =>
      'Only the NV Score is withheld; the live price is unaffected.';

  @override
  String get narrReviewWatch =>
      'Check the company\'s latest results on the NSE / BSE website until the data is corrected.';

  @override
  String get narrReviewUpdates =>
      'The score returns automatically once the data passes the check.';

  @override
  String get narrHoldingTag => 'Investment Holding Company (SOTP Required)';

  @override
  String get narrInsuranceTag =>
      'Actuarial Underwriting Entity (EV Model Required)';

  @override
  String get narrTrustTag => 'Yield Distribution Trust (NAV Required)';

  @override
  String get narrSpecialTag => 'Specialized Asset Class (Score Excluded)';

  @override
  String narrHoldingBrief(Object name) {
    return '$name functions as an equity investment holding company. Standard operating ROCE and P/E ratios are mathematically distorted by holding company discounts and non-operating dividend income. Valuation must be assessed via Sum-of-the-Parts (SOTP) net asset value.';
  }

  @override
  String narrInsuranceBrief(Object name) {
    return '$name operates an actuarial insurance underwriting portfolio. Statutory accounting and premium float dynamics make industrial ROCE metrics non-applicable; valuation is driven by Value of New Business (VNB) margins and Embedded Value (EV).';
  }

  @override
  String narrTrustBrief(Object name) {
    return '$name is a structured trust vehicle distributing rental/infrastructure cash flows. Standard industrial scoring is withheld in favor of Net Asset Value (NAV) and distribution yield.';
  }

  @override
  String get narrHoldingNav => 'Underlying Portfolio Holdings NAV';

  @override
  String get narrFloat => 'Float Compounding & VNB Expansion';

  @override
  String get narrDistribution => 'Predictable Distribution Yield';

  @override
  String get narrHoldingNavBody =>
      'Value realization is linked to the market capitalization growth of listed subsidiaries and unlisted associates.';

  @override
  String get narrFloatBody =>
      'Long-duration customer float and growing policyholder retention fuel actuarial book value expansion.';

  @override
  String get narrDistributionBody =>
      'High dividend payout mandates and pass-through tax structures provide tangible cash distribution.';

  @override
  String get narrCoverage => 'Coverage: Specialized';

  @override
  String get narrDiscount => 'Holding Company Discount Persistence';

  @override
  String get narrClaims => 'Actuarial Claims / Surrender Risk';

  @override
  String get narrRate => 'Interest Rate Sensitivity';

  @override
  String get narrDiscountBody =>
      'Holding company share prices often trade below the value of their underlying holdings; the gap varies by company and over time.';

  @override
  String get narrClaimsBody =>
      'Regulatory commission caps and sudden mortality/morbidity claims spikes can pressure quarterly margins.';

  @override
  String get narrRateBody =>
      'Rising benchmark yields increase the discount rate and compress trust capital value.';

  @override
  String get narrRiskSpecial => 'Risk: Specialized';

  @override
  String get narrSpecialOwned =>
      'Currently in your portfolio. The 1-100 score is not calculated for this category; review it on the metrics listed below.';

  @override
  String get narrSpecialNotOwned =>
      'The 1-100 score is not calculated for this category because standard operating ratios do not apply.';

  @override
  String get narrSpecialMetrics =>
      'Relevant metrics for this category: NAV discount (holding companies), EV / VNB (insurance), distribution yield (REITs / InvITs).';

  @override
  String get narrSpecialHold =>
      'Market value of core subsidiary holdings and parent capital allocation track record.';

  @override
  String get narrSpecialIns =>
      'VNB margins, persistency ratios, and solvency margin ratio.';

  @override
  String get narrSpecialTrust =>
      'Occupancy rates, weighted average lease expiry (WALE), and yield spreads over G-Sec.';

  @override
  String get narrScoreProfile => 'Score Profile';

  @override
  String narrNoScore(Object name) {
    return '$name has no NV Score yet.';
  }

  @override
  String narrScoreNoBreakdown(Object name, Object score) {
    return '$name has an NV Score of $score/100. The pillar-by-pillar breakdown appears after the next score update.';
  }

  @override
  String get narrBreakdownPending => 'Breakdown pending';

  @override
  String get narrBreakdownNext =>
      'Quality, valuation and price-trend details load with the next nightly score update.';

  @override
  String get narrNoPillars => 'No pillar data to compare yet.';

  @override
  String narrOwnedScore(Object score) {
    return 'In your portfolio. NV Score $score/100.';
  }

  @override
  String narrScoreLine(Object score) {
    return 'NV Score $score/100.';
  }

  @override
  String get narrBreakdownWatch =>
      'The breakdown below the score shows which pillar moves it.';

  @override
  String narrHasScore(Object name, Object score) {
    return '$name has an NV Score of $score/100. ';
  }

  @override
  String narrMissingPillars(Object pillars) {
    return ' $pillars: no data yet, so the other pillars carry its weight.';
  }

  @override
  String narrRiskCap(Object cap) {
    return ' A risk check failed (pledge, net worth or debt), which caps the score at $cap.';
  }

  @override
  String narrQualityCap(Object cap) {
    return ' Its quality pillar caps the score at $cap (54 below quality 55, no cap from 65).';
  }

  @override
  String narrHurdle(Object factor) {
    return ' Quality is below 55, so the weighted score is multiplied by $factor.';
  }

  @override
  String narrLenderCap(Object cap) {
    return ' Banks, NBFCs and brokers are capped at $cap until credit data is added.';
  }

  @override
  String get narrInPortfolio => 'In your portfolio. ';

  @override
  String narrHighLow(Object high, Object low) {
    return 'Highest pillar: $high. Lowest pillar: $low.';
  }

  @override
  String narrHighest(Object pillar) {
    return 'Highest pillar: $pillar';
  }

  @override
  String narrLowest(Object pillar) {
    return 'Lowest pillar: $pillar';
  }

  @override
  String get narrNoDetail => 'No detail available for this pillar.';

  @override
  String narrMostRoom(Object pillar) {
    return 'The $pillar pillar has the most room to move the score.';
  }

  @override
  String narrPartScore(Object label, Object points, Object max, Object detail) {
    return '$label scores $points of $max ($detail).';
  }

  @override
  String get narrRiskFlag => 'Risk Flag';

  @override
  String get narrBelowHurdle => 'Below Quality Hurdle';

  @override
  String get narrStrongLowVal => 'Strong Quality, Lower Valuation';

  @override
  String get narrStrongHighVal => 'Strong Quality, High Valuation';

  @override
  String get narrStrongQuality => 'Strong Quality';

  @override
  String get narrMixed => 'Mixed Profile';

  @override
  String get narrNotScored => 'Not Scored';

  @override
  String get narrBandExcellent => 'Score Band: Excellent';

  @override
  String get narrBandStrong => 'Score Band: Strong';

  @override
  String get narrBandAverage => 'Score Band: Average';

  @override
  String get narrBandWeak => 'Score Band: Weak';

  @override
  String get commonAnd => 'and';

  @override
  String get narrUpdates =>
      'Quarterly results update return on capital, debt, cash flow and growth; daily closing prices update valuation and the 12-month return rank.';

  @override
  String get mWhatTitle => 'What the score is';

  @override
  String get mWhatBody =>
      'A 0-100 score built only from published numbers: return on capital, debt, cash flow, growth, valuation and the 12-month price return. The same rules apply to every stock, and no person picks or adjusts a score. It describes a company\'s financial profile; it is not a forecast and not a buy or sell call.';

  @override
  String get mBands => 'Score bands';

  @override
  String get mBandExcellent => 'Excellent: strong on most measures';

  @override
  String get mBandStrong => 'Strong';

  @override
  String get mBandAverage => 'Average';

  @override
  String get mBandWeak => 'Weak: below the quality hurdle, or a risk flag';

  @override
  String get mPillars => 'Three pillars';

  @override
  String get mPillarsBody =>
      'The overall score is a weighted mix. If valuation or momentum has no data it is left out and its weight is shared by the others; it is never filled with a guessed value.';

  @override
  String get mQualityBody =>
      'Return on capital (ROCE) 40, debt to equity 25, operating cash flow vs profit 15, 5-year sales and profit growth 20 (full marks at 20% a year sales and 25% profit; shrinking scores 0). ROCE and debt count half on a fixed scale and half on the rank among companies in the same industry (15 or more), else the same sector.';

  @override
  String get mValuationBody =>
      'P/E compared with companies in the same industry 50, P/E compared with its own 5-year average 30 (0.6x or lower full marks, 0.85x half, 1.3x or higher none), and P/E against 5-year profit growth (PEG) 20 (1 or lower full marks, 3 or higher none; growth counted between 5% and 40% a year). A part with no data is left out. A loss-making company scores 0. Companies that demerged a large business, or have no 5-year average, use the earnings yield vs the 10-year government bond instead of their own average. Banks and NBFCs use P/B: rank within banks or NBFCs 60, against their own 5-year average 40.';

  @override
  String get mMomentumBody =>
      'Price return over the last 12 months, leaving out the latest month, ranked against every scored stock (6 months for stocks listed under a year). RSI, MACD and moving averages are shown for information and are not scored.';

  @override
  String get mHurdleBody =>
      'When the quality pillar is below 55, the overall score is capped at 54. From quality 55 to 65 the cap rises step by step (about 4.6 points per quality point) and disappears at 65, so a small change in quality never makes the score jump. A cheap stock or a strong price run cannot lift a weak business into the strong bands.';

  @override
  String get mMinData => 'Minimum data';

  @override
  String get mMinDataBody =>
      'Quality needs at least 3 of its 4 inputs (return on capital, debt, cash flow, growth). With 2 inputs the overall score is capped at 60; with fewer, or without return on capital, no score is shown and the stock reads DATA PENDING. Missing inputs are never assumed.';

  @override
  String get mRiskFlags => 'Risk flags';

  @override
  String get mRiskBody =>
      'Any of these caps the score at 28 and shows HIGH RISK FLAG, whatever the other numbers say:';

  @override
  String get mPledge => 'Pledge';

  @override
  String get mPledgeBody =>
      '75% or more of promoter shares pledged, or pledged shares at 25% or more of the company';

  @override
  String get mNetWorth => 'Net worth';

  @override
  String get mNetWorthBody =>
      'Zero or negative shareholder equity (held for review instead when the price-to-book in the fundamentals dataset is positive)';

  @override
  String get mDebt => 'Debt';

  @override
  String get mDebtBody => 'A negative debt-to-equity figure (a data anomaly)';

  @override
  String get mReviewed => 'Reviewed pledges';

  @override
  String get mReviewedBody =>
      'Some large pledges are checked against exchange filings. When the promoter is a private-equity owner that pledged its stake for its own holding-company loan, the pledge is shown as a note and does not trigger the flag. Every other pledge follows the rule above.';

  @override
  String get mSpecial => 'Special cases';

  @override
  String get mBanks => 'Banks and NBFCs';

  @override
  String get mBanksBody =>
      'Quality is return on equity 30, return on assets 25, net interest margin 15 (banks only), leverage 10 and growth 20. Loan quality (NPA) is not assessed yet, so the score is capped at 75 and shows a \"provisional\" badge.';

  @override
  String get mBrokers => 'Brokers';

  @override
  String get mBrokersBody =>
      'Debt is not scored (margin funding borrowings); capped at 75 with a \"provisional\" badge.';

  @override
  String get mInsurance => 'Insurance, holding companies, REITs / InvITs';

  @override
  String get mInsuranceBody =>
      'No score. Their accounts do not fit these ratios; they need embedded value, NAV or yield instead.';

  @override
  String get mEtfsBody => 'Valuation is set to a neutral 60.';

  @override
  String get mReview => 'Data under review';

  @override
  String get mReviewBody =>
      'No score when our stored fundamentals fail a check against exchange data (market cap or price of a different company). It returns once the data is corrected.';

  @override
  String get mLabels => 'Labels';

  @override
  String get mPositiveTrend => 'Positive trend';

  @override
  String get mPositiveBody =>
      'Momentum rank 50+. A stock already on the positive side keeps it until the rank falls below 45; one on the weak side needs 55 to cross, so a label does not flip on small daily moves.';

  @override
  String get mHighStrength => 'Quality 70+, valuation 65+, positive trend';

  @override
  String get mConsolidation => 'Quality 70+, valuation 65+, weak trend';

  @override
  String get mFair => 'Quality 70+, valuation 35-64';

  @override
  String get mExtended => 'Quality 70+, valuation below 35, positive trend';

  @override
  String get mElevated => 'Quality 70+, valuation below 35, weak trend';

  @override
  String get mNeutral => 'Quality 55-69';

  @override
  String get mBelow => 'Quality below 55';

  @override
  String get mNegative => 'Quality 70+, but the company is loss-making';

  @override
  String get mUnavailable =>
      'Quality 70+, but under 6 months of price history or no valuation data';

  @override
  String get mUnconfirmed =>
      'Pledge data is missing, so the risk check could not run';

  @override
  String get mDataPending => 'Not enough data to score yet';

  @override
  String get mFreshness => 'Data and freshness';

  @override
  String get mFreshnessBody =>
      'Fundamentals come from a dataset compiled from companies\' published results; where a figure is missing, debt and cash flow are taken from Yahoo Finance; net worth, margins and bank balance-sheet figures come from Yahoo Finance. Closing prices come from the NSE daily bhavcopy; prices during market hours come from Yahoo Finance and can be delayed. Scores are recalculated after each trading day\'s close. Data can be incomplete or wrong; check the company\'s filings before relying on any number.';

  @override
  String get syncStepAuth => 'Verifying Authentication';

  @override
  String get syncStepHoldings => 'Loading Portfolio Holdings';

  @override
  String get syncStepPrices => 'Syncing Latest Prices & Health';

  @override
  String get syncLoading => 'Loading Portfolio...';

  @override
  String get dashToday => 'TODAY';

  @override
  String get signalWeakest => 'WEAKEST';

  @override
  String get recoStrong => 'Strong Returns';

  @override
  String recoAbove(Object ret) {
    return 'Your holdings are $ret above their total cost.';
  }

  @override
  String get recoPositive => 'Positive Returns';

  @override
  String get recoNearCost => 'Near Cost';

  @override
  String recoAgainst(Object ret) {
    return 'Your holdings are $ret against their total cost.';
  }

  @override
  String get recoMild => 'Mild Drawdown';

  @override
  String recoBelow(Object ret) {
    return 'Your holdings are $ret below their total cost.';
  }

  @override
  String get recoBelowCost => 'Below Cost';

  @override
  String recoOverall(Object ret) {
    return 'Overall return: $ret.';
  }

  @override
  String recoAboveBuy(Object profit, Object total) {
    return '$profit of $total holdings are above their buy price.';
  }

  @override
  String recoHealth(Object score) {
    return 'NV Health Index $score/100 (value-weighted average NV Score).';
  }

  @override
  String recoLoss(Object count) {
    return '$count holdings are below their buy price; each one\'s \"Why this score\" shows its lowest pillar.';
  }

  @override
  String recoLargestFall(Object symbol, Object pct) {
    return 'Largest fall: $symbol ($pct).';
  }

  @override
  String recoUnpriced(Object count) {
    return '$count holdings have no current price and are left out of the totals.';
  }

  @override
  String recoStale(Object count) {
    return '$count holdings show their last saved price, not a live one.';
  }

  @override
  String get recoNoneBelow => 'No holding is below its buy price.';

  @override
  String get errSymbolNotListed =>
      'This symbol is not in the NSE list. Choose the stock from search.';

  @override
  String get errLoginRequired => 'Please log in first.';
}

/// The translations for English, as used in India (`en_IN`).
class AppLocalizationsEnIn extends AppLocalizationsEn {
  AppLocalizationsEnIn() : super('en_IN');

  @override
  String get menuLanguage => 'Bhasha';

  @override
  String get authInvalidEmail => 'Sahi email address daaliye.';

  @override
  String get authResetFailed =>
      'Reset link nahi bhej paaye. Email check karke dobara try kijiye.';

  @override
  String get authResetTitle => 'Password reset karein';

  @override
  String get authResetCheckInbox => 'Recovery link ke liye apna inbox dekhiye.';

  @override
  String get authResetPrompt =>
      'Reset link paane ke liye apne Nivaarth account ka email daaliye.';

  @override
  String get authResetSent => 'Reset link bhej diya';

  @override
  String authResetSentTo(Object email) {
    return 'Humne instructions $email par bhej diye hain.';
  }

  @override
  String get authBackToLogin => 'Login par wapas';

  @override
  String get authRegisteredEmail => 'Registered email';

  @override
  String get authSendReset => 'Reset link bhejein';

  @override
  String get authEnterBoth => 'Email aur password dono daaliye.';

  @override
  String get authWrongCreds => 'Email ya password galat hai.';

  @override
  String get commonNetworkIssue =>
      'Network ki dikkat hai. Internet connection check kijiye.';

  @override
  String get authTooMany =>
      'Bahut baar try ho gaya. Thodi der baad try kijiye.';

  @override
  String get authSignInFailed =>
      'Sign in nahi ho paaya. Apni details check kijiye.';

  @override
  String get authTagline =>
      'Focused investors ke liye private portfolio intelligence.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgot => 'Password bhool gaye?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authNoAccount => 'Account nahi hai? ';

  @override
  String get authCreateAccount => 'Account banayein';

  @override
  String get authEnterName => 'Apna poora naam daaliye.';

  @override
  String get authPasswordShort => 'Password kam se kam 6 characters ka ho.';

  @override
  String get authPasswordMismatch => 'Dono password alag hain.';

  @override
  String get authAcceptRisk =>
      'Stock investment mein market risk hai, yeh maan kar terms accept kijiye.';

  @override
  String get authEmailExists =>
      'Is email ka account pehle se hai. Log in kijiye.';

  @override
  String get authCreateFailed => 'Account nahi ban paaya. Dobara try kijiye.';

  @override
  String get authAccountCreated => 'Account ban gaya';

  @override
  String authAccountReady(Object email) {
    return 'Aapka Nivaarth account taiyar hai! Verification maanga jaaye toh $email check karke confirm kijiye.';
  }

  @override
  String get authProceedSignIn => 'Sign in par chalein';

  @override
  String get authJoinBeta => 'Nivaarth ke private closed beta se judiye.';

  @override
  String get authFullName => 'Poora naam';

  @override
  String get authEmailAddress => 'Email address';

  @override
  String get authConfirmPassword => 'Password dobara daaliye';

  @override
  String get authHaveAccount => 'Account pehle se hai? ';

  @override
  String get welcomeTagline =>
      'Serious Indian investors ke liye quantitative portfolio intelligence.';

  @override
  String get welcomePrivateTitle => 'Private aur alag-thalag';

  @override
  String get welcomePrivateBody =>
      'Aapka portfolio data alag aur surakshit hai. Koi doosra user ise nahi dekh sakta.';

  @override
  String get welcomeScoringTitle => 'Multi-factor AI scoring';

  @override
  String get welcomeScoringBody =>
      'Fundamental, technical, management aur risk, sab ki lagatar ranking.';

  @override
  String get welcomeCockpitTitle => 'Live cockpit';

  @override
  String get welcomeCockpitBody =>
      'Turant P&L, live prices aur samajh mein aane wale signals.';

  @override
  String get authCreateAnAccount => 'Account banayein';

  @override
  String get homeBackToExit =>
      'Nivaarth band karne ke liye back dobara dabaiye';

  @override
  String get legalAcknowledge => 'Maine samajh liya';

  @override
  String get syncFetchingPrices => 'Latest market prices la rahe hain...';

  @override
  String get syncReady => 'Portfolio taiyar';

  @override
  String get syncFailed =>
      'Portfolio abhi load nahi hua. Portfolio tab me Try Again dabao.';

  @override
  String get syncPreparing => 'Aapki portfolio intelligence taiyar ho rahi hai';

  @override
  String get syncDontClose =>
      'App band mat kijiye.\nLatest market intelligence taiyar ho rahi hai.';

  @override
  String get menuFeedbackTitle => 'Feedback dein / Bug batayein';

  @override
  String get menuFeedbackBody => 'Seedha engineering team tak';

  @override
  String get menuLegalTitle => 'Compliance aur legal disclaimers';

  @override
  String get menuLegalBody => 'SEBI non-advisory notice aur platform terms';

  @override
  String get menuLogOut => 'Log out';

  @override
  String get menuLogOutBody => 'Sign out karke welcome screen par jaayein';

  @override
  String get feedbackTitle => 'Friends Beta feedback';

  @override
  String get feedbackPrompt => 'Koi bug mila ya sujhav hai? Seedha batayein:';

  @override
  String get feedbackHint => 'Dikkat ya idea likhiye...';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get feedbackThanks =>
      'Shukriya! Aapka feedback agle release ke liye note kar liya.';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get logoutConfirmTitle => 'Nivaarth se log out karein?';

  @override
  String get logoutConfirmBody =>
      'Apna private portfolio cockpit dekhne ke liye dobara sign in karna hoga.';

  @override
  String get greetMorning => 'Good morning,';

  @override
  String get greetAfternoon => 'Good afternoon,';

  @override
  String get greetEvening => 'Good evening,';

  @override
  String get tipShowValues => 'Values dikhayein';

  @override
  String get tipHideValues => 'Values chhupayein (Privacy Mode)';

  @override
  String get tipProfile => 'Profile aur details';

  @override
  String get tipNotifications => 'Notifications';

  @override
  String get dashLoadingTitle => 'Portfolio cockpit taiyar ho raha hai';

  @override
  String get dashLoadingBody =>
      'Live valuation, health score aur AI signals la rahe hain.';

  @override
  String get dashUnavailable => 'Dashboard abhi nahi khul raha';

  @override
  String get commonTryAgain => 'Dobara try karein';

  @override
  String get dashBriefingSub =>
      'Aaj aapke holdings ke numbers kya dikha rahe hain.';

  @override
  String get dashWelcome => 'Nivaarth Cockpit mein swagat hai';

  @override
  String get dashTools => 'Nivaarth ke research tools';

  @override
  String get dashAddPrompt =>
      'Real-time analytics chalu karne ke liye apne equity holdings jodiye:';

  @override
  String get dashToolScore => 'Rules par bana NV Score (0-100)';

  @override
  String get dashToolScoreSub => 'Quality 50%, Valuation 30%, Price trend 20%';

  @override
  String get dashToolHealth => 'Portfolio Health aur Risk Radar';

  @override
  String get dashToolHealthSub =>
      'Concentration, sector mix aur buy price se neeche ke holdings';

  @override
  String get dashToolAdvisor => 'NV Advisor, aapke portfolio ke saath';

  @override
  String get dashToolAdvisorSub =>
      'Apne holdings ke baare mein puchhiye; jawab aapke data aur NV Score se aate hain';

  @override
  String get dashAddFirst => 'Pehla holding jodiye';

  @override
  String get indexMarketClosed => 'MARKET BAND';

  @override
  String get indexPerformance => 'Market index ka performance';

  @override
  String get indexChartUnavailable => 'Index chart abhi uplabdh nahi';

  @override
  String get indexRanges => 'Price range';

  @override
  String get indexTodayRange => 'Aaj ki range';

  @override
  String get indexTodayRangeNa => 'Aaj ki range uplabdh nahi';

  @override
  String get index52wRange => '52-week range';

  @override
  String get index52wLoading => '52-week range load ho rahi hai…';

  @override
  String get index52wNa => '52-week range uplabdh nahi';

  @override
  String indexAbout(Object name) {
    return '$name ke baare mein';
  }

  @override
  String get indexAboutNifty =>
      'NIFTY 50 India ka benchmark stock market index hai. Isme National Stock Exchange ki 50 sabse badi aur sabse zyada trade hone wali companies ka weighted average hota hai. Yeh India ki economy aur capital markets ka main paimana maana jaata hai.';

  @override
  String get indexAboutSensex =>
      'BSE SENSEX India ka sabse purana market index hai. Isme Bombay Stock Exchange ki 30 badi, financially mazboot aur active trade hone wali companies hain, jo Indian economy ke main sectors ko cover karti hain.';

  @override
  String get indexLargestSectors => 'Index ke sabse bade sectors';

  @override
  String get indexWeightsNifty =>
      'Aaj ke sector weights niftyindices.com par monthly NIFTY 50 factsheet mein milenge.';

  @override
  String get indexWeightsSensex =>
      'Aaj ke sector weights bseindia.com par BSE SENSEX factsheet mein milenge.';

  @override
  String get indexTechnical => 'Technical indicators';

  @override
  String get indexTechnicalSub =>
      'Pichhle ek saal ke daily closing prices se nikala gaya.';

  @override
  String get indexLoadingDaily => 'Daily prices load ho rahe hain…';

  @override
  String get indexIndicatorsNa => 'Indicators abhi uplabdh nahi.';

  @override
  String get indexPriceAbove => 'Price upar';

  @override
  String get indexPriceBelow => 'Price neeche';

  @override
  String get indexEma20 => '20-day EMA';

  @override
  String get indexAvg50 => '50-day average';

  @override
  String get indexAvg200 => '200-day average';

  @override
  String get indexOverbought => 'Overbought zone (70+)';

  @override
  String get indexOversold => 'Oversold zone (30-)';

  @override
  String get indexNeutral => 'Neutral zone';

  @override
  String get indexRsi => 'RSI (14 din)';

  @override
  String get indexNotEnough => 'Abhi kaafi daily prices nahi hain.';

  @override
  String get briefCoverageNa => 'Data coverage —';

  @override
  String briefCoverage(Object pct) {
    return '$pct% Data coverage';
  }

  @override
  String get briefReasons => 'Kaaran';

  @override
  String get briefToCheck => 'Kya dekhein';

  @override
  String get allocTitle => 'Portfolio ka bantwara';

  @override
  String get allocMarketCap => 'Market cap';

  @override
  String get allocSector => 'Sector';

  @override
  String get allocCapNote =>
      'Large: market cap mein top 100 companies · Mid: 101–250 · Small: baaki';

  @override
  String get commonShare => 'Share';

  @override
  String get allocShareSector => 'Portfolio: sector ke hisaab se';

  @override
  String get allocShareCap => 'Portfolio: market cap ke hisaab se';

  @override
  String get signalWinner => 'SABSE ZYADA BADHA';

  @override
  String get signalStrongest => 'SABSE MAZBOOT HOLDING';

  @override
  String get signalNotAssessed => 'Jaanch nahi hui';

  @override
  String get signalDiversification => 'DIVERSIFICATION';

  @override
  String signalTopSector(Object pct) {
    return 'Top sector $pct%';
  }

  @override
  String get topHoldingsTitle => 'Top holdings';

  @override
  String get topHoldingsSub => 'Sabse zyada current value (₹) ke hisaab se';

  @override
  String get commonViewAll => 'Sab dekhein';

  @override
  String get macroBreadth => 'Breadth';

  @override
  String macroAdvances(Object n) {
    return '$n badhe';
  }

  @override
  String macroDeclines(Object n) {
    return '$n gire';
  }

  @override
  String get macroWhatIf => 'Agar aisa ho to';

  @override
  String get healthIndex => 'NV HEALTH INDEX';

  @override
  String get commonLive => 'Live';

  @override
  String get commonMarketClosed => 'Market band';

  @override
  String get healthCoverageNa => 'Data coverage: —';

  @override
  String healthCoverage(Object pct) {
    return 'Data coverage: $pct%';
  }

  @override
  String healthStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String get healthExplain =>
      'Aapke scored holdings ka value ke hisaab se average NV Score.';

  @override
  String get healthOpenAdvisorHint => 'NV Advisor neeche ki bar se kholiye.';

  @override
  String get healthOpenAdvisor => 'Advisor kholein';

  @override
  String get healthMarketOpenNote =>
      'Market khula hai: prices har kuch minute mein refresh hote hain. NV Score har shaam update hota hai.';

  @override
  String get healthMarketClosedNote =>
      'Market band hai: prices aakhri close ke hain. NV Score har shaam update hota hai.';

  @override
  String heroQuiet(Object count, Object names) {
    return '$count stock me 15 min se koi trade nahi hua ($names) — price aakhri trade ka hai';
  }

  @override
  String get heroClosedNote => 'Market band · aaj ke closing prices';

  @override
  String heroUnpriced(Object count) {
    return '$count stock ka price nahi mila — total mein shaamil nahi';
  }

  @override
  String heroStale(Object count) {
    return '$count stock is refresh me update nahi hue — pichhla saved price dikh raha hai';
  }

  @override
  String get heroValue => 'PORTFOLIO VALUE';

  @override
  String get heroTotalPl => 'Total P&L';

  @override
  String get heroToday => 'Aaj';

  @override
  String holdingRemoveTitle(Object symbol) {
    return '$symbol hatayein?';
  }

  @override
  String holdingRemoveBody(Object symbol) {
    return '$symbol aur uske saare trades portfolio se hat jayenge.\n\nShares bech diye hain? To Delete nahi, stock kholkar SELL trade daalo, taaki trade history aur \"pichhli baar\" ka hisaab bacha rahe.';
  }

  @override
  String get commonDelete => 'Delete';

  @override
  String holdingRemoved(Object symbol) {
    return '$symbol hat gaya.';
  }

  @override
  String get commonPriceUnavailable => 'Price uplabdh nahi';

  @override
  String get holdingEdit => 'Holding edit karein';

  @override
  String get holdingDelete => 'Holding delete karein';

  @override
  String heroClosedOn(Object date) {
    return 'Market band · $date ke closing prices';
  }

  @override
  String heroRefreshedAt(Object time) {
    return '$time par refresh hua';
  }

  @override
  String heroRefreshedOn(Object date, Object time) {
    return '$date, $time par refresh hua';
  }

  @override
  String get closedTitle => 'Closed positions';

  @override
  String get closedLoadFailed => 'Closed positions load nahi hue';

  @override
  String get commonCheckInternet => 'Internet check karke dobara try karo.';

  @override
  String get closedEmptyTitle => 'Koi closed position nahi';

  @override
  String get closedEmptyBody =>
      'Jab koi stock poora bik jayega, wo yahan realized P&L ke saath dikhega.';

  @override
  String closedCount(Object count) {
    return '$count stock poore beche gaye';
  }

  @override
  String closedRealized(Object amount) {
    return 'Realized $amount';
  }

  @override
  String tradeBought(Object amount) {
    return 'Kharida $amount';
  }

  @override
  String tradeSold(Object amount) {
    return 'Becha $amount';
  }

  @override
  String closedLastSell(Object date) {
    return 'Aakhri sell $date';
  }

  @override
  String closedTrades(Object count) {
    return '$count trades';
  }

  @override
  String get importStarting => 'Shuru ho raha hai…';

  @override
  String get importTitle => 'Tradebook import';

  @override
  String get importHeading => 'Zerodha tradebook (CSV ya Excel)';

  @override
  String get importSteps =>
      'Console → Reports → Tradebook → Segment: Equity → Download (CSV ya XLSX). Pehle preview dikhega; \"Import karo\" dabane tak kuch save nahi hoga. Ek hi file dobara daaloge to pehle wale trades dobara nahi judenge.';

  @override
  String get importPickFile => 'File chuno (CSV / XLSX)';

  @override
  String get importPickOther => 'Doosri file chuno';

  @override
  String importDone(Object count, Object stocks) {
    return '$count trades import hue ($stocks stocks).';
  }

  @override
  String importSummary(Object stocks, Object trades) {
    return '$stocks stocks · $trades naye trades';
  }

  @override
  String importUnlisted(Object symbols) {
    return 'Ye symbols Nivaarth ki list me nahi mile, import nahi honge: $symbols. ';
  }

  @override
  String get importRenamed =>
      '(Naam badla ho, jaise demerger ke baad, to stock Add Holding se khud daalo.)';

  @override
  String get importBonusNote =>
      'Bonus ya split tradebook me nahi hote. Aise stock ki quantity broker se alag dikhe to us stock ko check karo.';

  @override
  String get importNothingNew => 'Import ke liye kuch naya nahi';

  @override
  String importConfirm(Object trades, Object stocks) {
    return 'Import karo ($trades trades, $stocks stocks)';
  }

  @override
  String get importNotHeld => 'Abhi portfolio me nahi';

  @override
  String importHeldNow(Object qty) {
    return 'Abhi: $qty shares';
  }

  @override
  String get importFromBook => 'Tradebook se banao';

  @override
  String get importOnlyNew => 'Sirf naye jodo';

  @override
  String get importFromBookNote =>
      'Purana opening holding hatega, holding sirf tradebook ke trades se banega.';

  @override
  String get importOnlyNewNote =>
      'Purana holding rahega, tradebook ke trades uske upar judenge (dhyan: purane buys do baar na judein).';

  @override
  String importManualWarn(Object count) {
    return 'Is stock ke $count trades aapne haath se bhi daale hain. Wahi trade tradebook me bhi ho to do baar judega — import ke baad Trade book me check karke dohraya trade hata do.';
  }

  @override
  String importError(Object error) {
    return 'Import nahi hoga: $error';
  }

  @override
  String importResultClosed(Object pl) {
    return 'Import ke baad: poora bika (Closed positions), realized $pl';
  }

  @override
  String importResultOpen(Object qty, Object avg, Object invested) {
    return 'Import ke baad: $qty shares @ $avg · Invested $invested';
  }

  @override
  String get addHolding => 'Holding jodiye';

  @override
  String get portfolioLoadingTitle => 'Holdings load ho rahe hain';

  @override
  String get portfolioLoadingBody =>
      'Aapke live portfolio positions la rahe hain.';

  @override
  String get portfolioUnavailable => 'Portfolio abhi nahi khul raha';

  @override
  String get portfolioEmptyTitle => 'Abhi koi holding nahi';

  @override
  String get portfolioEmptyBody =>
      'Apne investments jodiye, phir real-time valuation, P&L aur AI score dikhenge.';

  @override
  String get portfolioAddFirst => 'Pehla stock jodiye';

  @override
  String get portfolioOpenTradeBook => 'Trade book dekho';

  @override
  String get portfolioImport => 'Zerodha tradebook import';

  @override
  String get tradeBookTitle => 'Trade book';

  @override
  String portfolioTracked(Object count) {
    return '$count holdings track ho rahe hain.';
  }

  @override
  String get sortAlphabetical => 'A se Z';

  @override
  String get sortTodayGainers => 'Aaj ke top gainers (₹)';

  @override
  String get sortTodayLosers => 'Aaj ke top losers (₹)';

  @override
  String get sortOverallGainers => 'Overall top gainers (%)';

  @override
  String get sortOverallLosers => 'Overall top losers (%)';

  @override
  String get sortHighestValue => 'Sabse zyada value (₹)';

  @override
  String get commonShowLess => 'Kam dikhayein';

  @override
  String commonSeeAll(Object count) {
    return 'Sab dekhein ($count)';
  }

  @override
  String get sortShortTodayGainers => 'Aaj ke gainers';

  @override
  String get sortShortTodayLosers => 'Aaj ke losers';

  @override
  String get sortShortGainers => 'Top gainers';

  @override
  String get sortShortLosers => 'Top losers';

  @override
  String get sortShortValue => 'Valuation';

  @override
  String get portfolioValuation => 'PORTFOLIO VALUATION';

  @override
  String get metricInvested => 'Invested';

  @override
  String get metricHoldings => 'Holdings';

  @override
  String metricPositions(Object count) {
    return '$count positions';
  }

  @override
  String get metricWinRatio => 'Win ratio';

  @override
  String get heatReturnTitle => 'Return heatmap';

  @override
  String heatUpDown(Object up, Object down) {
    return '$up upar • $down neeche';
  }

  @override
  String get heatOverall => 'Overall';

  @override
  String get heatTodayPl => 'Aaj ka P&L';

  @override
  String get heatGainersFirst => 'Gainers pehle';

  @override
  String get heatLosersFirst => 'Losers pehle';

  @override
  String get heatEmpty => 'Dikhane ke liye koi holding nahi';

  @override
  String get tradesLoadFailed => 'Trades load nahi hue';

  @override
  String get tradesEmptyTitle => 'Abhi koi trade nahi';

  @override
  String get tradesEmptyBody =>
      'Stock add karne, kharidne ya bechne par har trade yahan din ke hisaab se dikhega.';

  @override
  String get tradesSearchHint => 'Stock se dhundo (jaise POLYCAB)';

  @override
  String tradesCountDays(Object trades, Object days) {
    return '$trades trades · $days din';
  }

  @override
  String get tradesNoMatch => 'Is naam ka koi trade nahi mila.';

  @override
  String get tradeOpeningHolding => 'Shuruaati holding';

  @override
  String get tradeBonusSplit => 'Bonus/split ke shares';

  @override
  String lastTimeTitle(Object symbol) {
    return '$symbol: pichhli baar';
  }

  @override
  String lastTimeDates(Object from, Object to, Object days) {
    return '$from se $to ($days din)';
  }

  @override
  String get lastTimeBought => 'Kharida';

  @override
  String get lastTimeSold => 'Becha';

  @override
  String lastTimeRounds(Object count) {
    return 'Ye stock aap $count baar poora bech chuke ho; upar sabse aakhri baar ka hisaab hai.';
  }

  @override
  String get commonOk => 'Theek hai';

  @override
  String get addSelectStock => 'Stock symbol search karke chuniye.';

  @override
  String get addValidQty => '0 se zyada sahi quantity daaliye.';

  @override
  String get addValidPrice => 'Sahi average buy price daaliye.';

  @override
  String addDone(Object symbol) {
    return '$symbol portfolio mein jud gaya!';
  }

  @override
  String addMerged(Object symbol, Object qty) {
    return '$symbol: $qty shares jud gaye, average update ho gaya.';
  }

  @override
  String get addTitle => 'Stock holding jodiye';

  @override
  String get addSubtitle =>
      'Koi bhi NSE/BSE stock search kijiye, details khud bhar jayengi aur live AI tracking shuru hogi.';

  @override
  String get addSearchHint =>
      'Stock symbol search kijiye (jaise RELIANCE, TITAN, INFY)';

  @override
  String get addCompanyName => 'Company ka naam';

  @override
  String get addFetchingPrice => 'Live price la rahe hain...';

  @override
  String addCurrentPrice(Object price) {
    return 'Current price: $price';
  }

  @override
  String get addUseAsBuy => '[Buy price banayein]';

  @override
  String get commonQuantity => 'Quantity';

  @override
  String get addAvgBuyPrice => 'Avg buy price (₹)';

  @override
  String get commonBuyPrice => 'Buy price (₹)';

  @override
  String get addToPortfolio => 'Portfolio mein jodiye';

  @override
  String get addToPortfolioAvg => 'Portfolio me jodo (avg update)';

  @override
  String get tradeQtyPositive => 'Quantity 0 se zyada honi chahiye.';

  @override
  String get tradePricePositive => 'Price 0 se zyada hona chahiye.';

  @override
  String tradeNotEnough(Object have, Object selling) {
    return 'Itne shares nahi hain: $have hain, $selling bech rahe ho.';
  }

  @override
  String tradeSellSaved(Object symbol, Object qty) {
    return '$symbol: $qty shares ki sell darj ho gayi.';
  }

  @override
  String get tradeRemoveOpening => 'Shuruaati holding hatayein?';

  @override
  String get tradeRemoveThis => 'Ye trade hatayein?';

  @override
  String tradeRemoveOpeningBody(Object qty, Object price) {
    return 'Ye aapki Trade jodo se pehle ki holding hai: $qty shares @ $price. Hatane se ye $qty shares portfolio se hat jayenge.\n\nShares beche hain to isse mat hatao, SELL trade daalo.';
  }

  @override
  String get tradeRebuilt => 'Holding baaki trades se dobara banegi.';

  @override
  String get tradeYesRemove => 'Haan, hatao';

  @override
  String get tradeRemove => 'Hatao';

  @override
  String tradeRemoved(Object symbol) {
    return '$symbol: trade hata diya.';
  }

  @override
  String holdingRemoveBodyFinal(Object symbol) {
    return '$symbol aur uske saare trades portfolio se hat jayenge. Ye wapas nahi hoga.\n\nShares bech diye hain? To Delete nahi, SELL trade daalo, taaki trade history aur \"pichhli baar\" ka hisaab bacha rahe.';
  }

  @override
  String holdingRemovedFull(Object symbol) {
    return '$symbol portfolio se hat gaya.';
  }

  @override
  String tradeAddFor(Object symbol) {
    return 'Trade jodo · $symbol';
  }

  @override
  String get editHolding => 'Holding';

  @override
  String get editTotalInvested => 'Total invested';

  @override
  String get editRealized => 'Realized P&L (avg cost)';

  @override
  String get editLtp => 'Current market price (LTP)';

  @override
  String get commonSellPrice => 'Sell price (₹)';

  @override
  String get tradeAdd => 'Trade jodo';

  @override
  String get tradesHeading => 'Trades';

  @override
  String tradesLoadError(Object error) {
    return 'Trades load nahi hue: $error';
  }

  @override
  String get tradesNoneYet =>
      'Abhi koi trade darj nahi hai. Pehla trade jodte hi aapka abhi ka holding \"Shuruaati holding\" trade ban jayega.';

  @override
  String get tradeRemoveTip => 'Trade hatao';

  @override
  String sellDoneTitle(Object symbol, Object qty) {
    return '$symbol: $qty shares beche';
  }

  @override
  String get sellRealized => 'Is sell ka realized P&L';

  @override
  String sellDetail(Object qty, Object price, Object avg) {
    return '$qty @ $price becha, average $avg tha.';
  }

  @override
  String sellAllGone(Object symbol) {
    return 'Saare shares bik gaye. $symbol ab Closed positions me hai.';
  }

  @override
  String sellRemaining(Object left, Object avg, Object invested) {
    return 'Bache: $left shares @ $avg (sell se average nahi badalta). Invested ab $invested.';
  }

  @override
  String styleFunds(Object pct) {
    return 'ETF / funds $pct';
  }

  @override
  String styleLoss(Object pct) {
    return 'Loss-making $pct';
  }

  @override
  String styleNoData(Object pct) {
    return 'Data nahi $pct';
  }

  @override
  String get styleTitle => 'Investment style';

  @override
  String get styleWhatTip => 'Ye kya hai?';

  @override
  String get styleLargest => 'Sabse bada hissa';

  @override
  String stylePctPortfolio(Object pct) {
    return '$pct% portfolio';
  }

  @override
  String get styleShare => 'Hissa';

  @override
  String get styleRankNote =>
      'Growth aur Value 0 se 100 ke rank hain, jaise class mein rank. 60 ya usse upar yani us taraf mazboot.';

  @override
  String get styleWhatTitle => 'Investment style kya hai?';

  @override
  String get styleWhatIntro =>
      'Ye card aapke portfolio ka aaina hai. Ye batata hai ki aapka paisa kaisi companies mein laga hai. Ye kharidne ya bechne ki salah nahi hai.';

  @override
  String get styleSizeHead => 'Company ka size';

  @override
  String get styleLarge => 'Large: sabse badi 100 companies.';

  @override
  String get styleMid => 'Mid: uske baad ki 150 companies.';

  @override
  String get styleSmall => 'Small: usse chhoti companies.';

  @override
  String get styleMicro => 'Micro: ₹1,000 crore se chhoti companies.';

  @override
  String get styleTypeHead => 'Company ka type';

  @override
  String get styleGrowth =>
      'Growth: tez badh rahi hai, par share sasta nahi hai.';

  @override
  String get styleValue =>
      'Value: share sasta hai, par company khaas tez nahi badh rahi.';

  @override
  String get styleBoth =>
      'Growth + Value: tez bhi badh rahi hai aur sasti bhi hai. Aisi companies kam milti hain.';

  @override
  String get styleOthers => 'Others: na khaas tez, na khaas sasti.';

  @override
  String get styleTableHead => 'Table kaise padhein';

  @override
  String get styleTableBody =>
      'Har dabba batata hai ki portfolio ka kitna hissa us size aur us type mein hai. Maan lo ₹100 lage hain: 18.0% ka matlab ₹18.';

  @override
  String get styleTableBody2 =>
      'Gold border wala dabba sabse bada hissa hai. Rang jitna gehra, hissa utna bada. Kisi dabbe par tap karke uske stocks dekh sakte ho.';

  @override
  String get styleHowHead => 'Type kaise tay hota hai';

  @override
  String get styleHow1 =>
      'Har company ko uske jaise size wali companies se milate hain, jaise class mein rank aati hai.';

  @override
  String get styleHow2 =>
      'Growth rank: pichhle 3 aur 5 saal mein sales aur profit kitna badha.';

  @override
  String get styleHow3 =>
      'Value rank: P/E, P/B aur dividend ke hisaab se share kitna sasta hai.';

  @override
  String get styleHow4 =>
      '60 ya usse upar rank ho to company us type mein gini jaati hai.';

  @override
  String get styleBelowHead => 'Neeche wali line';

  @override
  String get styleBelowBody =>
      'ETF aur fund company nahi hote, aur ghate wali companies ka P/E nahi nikalta. Isliye ye table ke bahar alag likhe hain.';

  @override
  String get styleNoteHead => 'Dhyan rakhein';

  @override
  String get styleNoteBody =>
      'Rank doosri companies ke mukable hai, isliye samay ke saath label badal sakta hai.';

  @override
  String get perfBackcast =>
      'Agar aaj ke holdings poore samay rakhe hote. Yeh aapka asli return nahi hai.';

  @override
  String perfFooter(Object date) {
    return 'Sirf bhav, dividend shamil nahi. Data: $date tak.';
  }

  @override
  String get perfPartial =>
      'Kuch holdings ka poora purana data nahi hai. Unke bina graph baaki holdings par bana hai.';

  @override
  String get movesToday => 'Aaj';

  @override
  String get movesLastSession => 'Pichhla session';

  @override
  String get movesLegend =>
      'Dabbe ka size: portfolio mein hissa. Rang: us din ka badlav.';

  @override
  String get movesGainers => 'Top gainers';

  @override
  String get movesLosers => 'Top losers';

  @override
  String get tradeDateHelp => 'Trade ki date';

  @override
  String get tradeDate => 'Trade date';

  @override
  String get tradeZeroLeft => '0 shares (poora bik jayega)';

  @override
  String get tradeNow => 'Abhi';

  @override
  String get tradeAfter => 'Trade ke baad';

  @override
  String importFailed(Object count) {
    return ' $count stocks nahi hue, unka holding pehle jaisa hai:';
  }

  @override
  String importDuplicates(Object count) {
    return ' · $count pehle se imported (skip)';
  }

  @override
  String importSkipped(Object count) {
    return ' · $count rows skip (F&O / padhi nahi gayi)';
  }

  @override
  String importStockLine(Object count, Object skip) {
    return '$count trades$skip';
  }

  @override
  String savedRemoved(Object symbol) {
    return '$symbol MY SAVED LIST se hat gaya';
  }

  @override
  String savedAdded(Object symbol, Object price) {
    return '$symbol $price par MY SAVED LIST mein jud gaya';
  }

  @override
  String alertButtonCount(Object count) {
    return 'Price alert · $count laga hai';
  }

  @override
  String get alertButton => 'Price alert lagao';

  @override
  String get stockPricePerformance => 'Price performance';

  @override
  String get stockChartSoon => 'Historical chart jald aayega';

  @override
  String get stockWatchlistAsset => 'Watchlist stock';

  @override
  String get stockNotOwned => 'Abhi aapke portfolio mein nahi hai.';

  @override
  String get stockScoreFailed => 'AI Score load nahi hua';

  @override
  String stockAnalyzing(Object symbol) {
    return '$symbol ke signals dekh rahe hain...';
  }

  @override
  String get stockScoring =>
      'Latest data se quality, valuation aur price trend ka score ban raha hai.';

  @override
  String get stockSaved => 'Saved';

  @override
  String get stockSave => '+ Save';

  @override
  String get aiRulesBased => 'Rules par bana research score';

  @override
  String get aiHowWorks => 'NV Score kaise kaam karta hai';

  @override
  String get aiDataPending => 'Data pending';

  @override
  String get aiDataReview => 'Data review mein';

  @override
  String get aiExcluded => 'Score nahi diya';

  @override
  String get aiCreditPending => 'Credit pending';

  @override
  String get aiBrokerLeverage => 'Broker MTF leverage';

  @override
  String get aiDebtNotAssessed => 'Debt ki jaanch nahi';

  @override
  String get aiWhyScore => 'Yeh score kyun';

  @override
  String get aiMethodology => 'Methodology';

  @override
  String aiNoScore(Object reason) {
    return 'Abhi NV Score nahi: $reason. Score ke liye 4 mein se kam se kam 3 quality inputs chahiye, aur yeh andaze par nahi banta.';
  }

  @override
  String get aiReviewBody =>
      'Is stock ka source data exchange se match nahi hua (market cap ya price kisi aur company ka hai), isliye review ho raha hai. Galat numbers par score dene se behtar hai ki score na dikhe.';

  @override
  String get aiInsurance =>
      'Life aur General Insurance companies actuarial float aur statutory accounting par chalti hain. Jab tak Embedded Value (EV) model nahi judta, 1-100 score nahi diya jaata.';

  @override
  String get aiHolding =>
      'Investment holding companies alag-alag NAV discount par trade karti hain. Aam multiples (P/E, ROCE) yahan laagu nahi hote; alag SOTP research chahiye.';

  @override
  String get aiReit =>
      'Real Estate aur Infrastructure Investment Trusts distribution yield aur NAV par chalte hain. Aam score nahi diya jaata.';

  @override
  String get aiSpecialised =>
      'Is stock ka 1-100 score nahi nikalta: iske accounts ke liye alag valuation tareeka chahiye.';

  @override
  String aiScoreOnly(Object score) {
    return 'NV Score $score/100. Pillar breakdown agle score update ke baad dikhega.';
  }

  @override
  String aiHighest(Object score, Object pillar) {
    return 'NV Score $score/100. Sabse zyada: $pillar';
  }

  @override
  String aiLowest(Object pillar) {
    return '; sabse kam: $pillar';
  }

  @override
  String aiRiskCap(Object cap) {
    return ' Ek risk check fail hua, isliye score $cap par ruk gaya.';
  }

  @override
  String get aiHurdle =>
      ' Quality 55 se neeche hai, isliye score kam kiya gaya.';

  @override
  String get companyOverview => 'Company overview';

  @override
  String get companyLabel => 'Company';

  @override
  String get companyIndustry => 'Industry';

  @override
  String get companyStatus => 'Status';

  @override
  String get holdingDetails => 'Holding details';

  @override
  String get holdingAvgPrice => 'Average price';

  @override
  String get holdingCurrentPrice => 'Current price';

  @override
  String get holdingInvested => 'Invested value';

  @override
  String get holdingCurrentValue => 'Current value';

  @override
  String get holdingNetPl => 'Net P&L';

  @override
  String get holdingReturn => 'Return';

  @override
  String get holdingDayPl => 'Aaj ka P&L';

  @override
  String get thesisTitle => 'Investment thesis';

  @override
  String get thesisNone => 'Is stock ka investment thesis abhi nahi hai.';

  @override
  String get thesisReview =>
      'Har quarterly result ke baad yeh thesis dobara dekhiye.';

  @override
  String get newsTitle => 'Latest news';

  @override
  String get newsSub => 'AI ke chune market updates';

  @override
  String get newsEmptyTitle => 'Koi news nahi';

  @override
  String get newsEmptyBody =>
      'Company news aur market updates aane par yahan khud dikhenge.';

  @override
  String get newsAutoRefresh => 'Auto refresh';

  @override
  String get peersTitle => 'Peers se tulna';

  @override
  String get peersAdd => 'Aur peer jodo';

  @override
  String get peersChange => 'Peer badlo';

  @override
  String get peersDashNote =>
      '— yani data nahi. P/E loss-making company ka nahi hota.';

  @override
  String get alertRemoveTip => 'Alert hatao';

  @override
  String get alertRemoveFailed => 'Alert hata nahi paaye. Dobara try karo.';

  @override
  String get alertDuplicate => 'Ye alert pehle se laga hai';

  @override
  String alertMax(Object max) {
    return 'Ek saath $max alert tak laga sakte ho';
  }

  @override
  String get alertSaveFailed => 'Alert save nahi hua. Dobara try karo.';

  @override
  String alertTitle(Object symbol) {
    return 'Price alert · $symbol';
  }

  @override
  String alertCurrent(Object price) {
    return 'Abhi ka bhaav $price';
  }

  @override
  String get alertAbove => 'Upar jaaye';

  @override
  String get alertBelow => 'Neeche aaye';

  @override
  String get alertPriceHint => 'Bhaav (₹)';

  @override
  String get alertSaving => 'Save ho raha hai...';

  @override
  String get alertSet => 'Alert lagao';

  @override
  String get alertNote =>
      'Market ke samay bhaav har 5 minute mein check hota hai. Bhaav pahunchne par Notifications mein dikhega. Saare alerts: Notifications > Mere price alerts.';

  @override
  String get alertsMine => 'Mere price alerts';

  @override
  String get alertsLoadFailed => 'Alerts load nahi hue';

  @override
  String get alertsNone =>
      'Koi active alert nahi. Kisi stock ke page se alert lagao.';

  @override
  String get recSummary => 'DATA SUMMARY';

  @override
  String get recPlaybook => 'Data notes';

  @override
  String get recHeld => 'PORTFOLIO MEIN HAI';

  @override
  String get recDiscovery => 'DISCOVERY MODE';

  @override
  String get recShows => 'Data kya dikhata hai';

  @override
  String get recWatch => 'Dekhne wala number';

  @override
  String get recUpdates => 'Score kis se badalta hai';

  @override
  String recCoverage(Object pct) {
    return 'Data coverage: $pct% • 6 quantitative pillars se bana';
  }

  @override
  String get breakdownPending => 'Breakdown agle score update ke baad dikhega.';

  @override
  String get breakdownNone => 'Is stock ka score nahi, isliye breakdown nahi.';

  @override
  String get breakdownNotCounted => 'gina nahi gaya';

  @override
  String breakdownWeight(Object pct) {
    return '$pct% weight';
  }

  @override
  String get breakdownRiskFlag => 'Risk flag';

  @override
  String breakdownRiskCap(Object cap) {
    return 'Score $cap par ruka (pledge, net worth ya debt check fail)';
  }

  @override
  String get breakdownHurdle => 'Quality hurdle';

  @override
  String breakdownHurdleBody(Object hurdle) {
    return '× $hurdle (quality 55 se neeche)';
  }

  @override
  String get breakdownQualityCap => 'Quality cap';

  @override
  String breakdownQualityCapBody(Object cap) {
    return '$cap par ruka (quality 55 se neeche 54, 65 par koi rok nahi)';
  }

  @override
  String get breakdownLenderCap => 'Lender / broker cap';

  @override
  String breakdownLenderCapBody(Object cap) {
    return 'Credit data aane tak $cap par ruka';
  }

  @override
  String get breakdownNote => 'Note';

  @override
  String get shareDownloaded => 'Image download ho gayi.';

  @override
  String get shareFailed => 'Share nahi ho paaya. Dobara try karo.';

  @override
  String get commonClose => 'Band karo';

  @override
  String get stockSyncing => 'Sync ho raha hai...';

  @override
  String stockAllTime(Object amount, Object pct) {
    return 'Ab tak: $amount   ($pct)';
  }

  @override
  String stockToday(Object amount, Object pct) {
    return 'Aaj: $amount   ($pct)';
  }

  @override
  String get stockExchange => 'Exchange';

  @override
  String get stockTrend => 'Trend';

  @override
  String get chartUpdating => 'Chart update ho raha hai...';

  @override
  String get radarTitle => 'Score ka aakar';

  @override
  String get radarNoteLeverage =>
      'Har score 0–100, bahar ki taraf zyada. Leverage mein zyada score yani kam leverage.';

  @override
  String get radarNoteDebt =>
      'Har score 0–100, bahar ki taraf zyada. Debt mein zyada score yani kam karz.';

  @override
  String get breakdownHintQuality =>
      'Return on capital, debt, cash conversion aur 5 saal ki growth';

  @override
  String get breakdownHintValuation =>
      'Sector peers ke mukable P/E aur earnings yield';

  @override
  String get breakdownHintMomentum =>
      '12 mahine ka return, aakhri mahina chhod kar, saare stocks ke mukable rank';

  @override
  String get shareDisclaimer =>
      'Sirf jaankari ke liye. Ye investment advice nahi hai.';

  @override
  String get searchTitle => 'Search aur Watchlist';

  @override
  String searchTracked(Object count) {
    return '$count track ho rahe';
  }

  @override
  String get searchSub => 'Prices, NV Score aur watchlist tracking.';

  @override
  String get searchExplore => 'Stocks dekhiye';

  @override
  String get searchHint =>
      'Symbol ya naam se stock dhundiye (jaise TAT, KEI, APO)...';

  @override
  String get searchingTitle => 'Market mein dhund rahe hain';

  @override
  String get searchingBody => 'Symbols aur AI scores mila rahe hain.';

  @override
  String get searchUnavailable => 'Search abhi nahi chal raha';

  @override
  String get searchStartTitle => 'Symbol se shuru kijiye';

  @override
  String get searchStartBody =>
      'Koi bhi stock dhundiye aur uska NV Score dekhiye.';

  @override
  String get searchNoneTitle => 'Koi stock nahi mila';

  @override
  String get searchNoneBody => 'Koi aur symbol ya company ka naam try kijiye.';

  @override
  String get watchRemove => 'Watchlist se hatayein';

  @override
  String get watchAdd => 'Watchlist mein jodein';

  @override
  String watchSavedAt(Object symbol, Object price) {
    return '$symbol $price par save hua';
  }

  @override
  String watchAdded(Object symbol) {
    return '$symbol watchlist mein jud gaya';
  }

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get watchRemoveConfirm => 'Watchlist se hatayein?';

  @override
  String watchRemoveBodyPrice(Object name, Object symbol, Object price) {
    return '$name ($symbol) hatana hai? Aapka tracked entry price ($price) bhi hat jayega.';
  }

  @override
  String watchRemoveBody(Object name, Object symbol) {
    return '$name ($symbol) ko watchlist se hatana hai?';
  }

  @override
  String get watchEmptyTitle => 'Watchlist mein koi stock nahi';

  @override
  String get watchEmptyBody =>
      'Koi stock dhundiye aur \"+ Save\" dabaiye.\nRefresh ke liye neeche kheenchiye.';

  @override
  String get watchColCompany => 'Company ⬍';

  @override
  String get watchColScore => 'Score ⬍';

  @override
  String get watchColAdded => 'Added price';

  @override
  String get watchColLatest => 'Latest price ⬍\nBadlav';

  @override
  String get watchColReturns => 'Returns ⬍\nTrack ki date';

  @override
  String get watchColTech => 'Technical aur zaroori baatein';

  @override
  String get watchColAction => 'Action';

  @override
  String get watchEntry => 'Entry point';

  @override
  String get notifMarkAll => 'Sab read karein';

  @override
  String get notifMarked => 'Saare alerts read ho gaye.';

  @override
  String notifFailed(Object error) {
    return 'Notifications load nahi hue:\n$error';
  }

  @override
  String notifActive(Object count) {
    return '$count active';
  }

  @override
  String get notifJustNow => 'Abhi';

  @override
  String notifMinutes(Object n) {
    return '${n}m pehle';
  }

  @override
  String notifHours(Object n) {
    return '${n}h pehle';
  }

  @override
  String notifDays(Object n) {
    return '${n}d pehle';
  }

  @override
  String get notifEmptyTitle => 'Is category mein koi alert nahi';

  @override
  String get notifEmptyBody => 'Aapka portfolio risk limits ke andar hai.';

  @override
  String get advBusy =>
      'NV Advisor filhal busy hai ya connection me issue hai. Kripya thodi der baad dobara poochhein.';

  @override
  String get advNoReply => 'Abhi jawab nahi';

  @override
  String get advHistoryTitle => 'Aaj ki History';

  @override
  String advQueries(Object count) {
    return '$count sawaal';
  }

  @override
  String get advNoHistory => 'Aaj abhi tak koi conversation nahi hui.';

  @override
  String get advSub => 'Aapke holdings ka research assistant';

  @override
  String get advClear => 'Chat saaf karein';

  @override
  String get advReset =>
      'Chat reset. Aap mujhse apne portfolio ke bare me kuch bhi pooch sakte hain!';

  @override
  String get advAnalyzing => 'NV Advisor dekh raha hai...';

  @override
  String get advHint =>
      'NV Advisor se apne portfolio ke baare mein puchhiye...';

  @override
  String get riskLoadFailed => 'Portfolio load nahi hua';

  @override
  String get riskNoStocks => 'Portfolio mein koi stock nahi';

  @override
  String get riskDisclaimer =>
      'Ye pichhle 1 saal ke beta par bana andaaza hai, bhavishyavani nahi. Asli girawat isse alag ho sakti hai. Yahan koi trade nahi hota, aur ye investment advice nahi hai.';

  @override
  String get riskBetaNote =>
      '1.00 yani Nifty jitna hilta hai. 1 se upar yani usse zyada.';

  @override
  String riskNoBeta(Object stocks, Object pct) {
    return '$stocks ka beta nahi hai. Ye $pct portfolio par bana hai.';
  }

  @override
  String riskPeExcluded(Object stocks, Object pct) {
    return '$stocks P/E mein nahi (loss-making ya ETF). P/E $pct portfolio par bana hai.';
  }

  @override
  String get riskIfFalls => 'Agar market gire';

  @override
  String get riskBetaNa =>
      'Beta abhi uplabdh nahi hai, isliye hisaab nahi ban sakta.';

  @override
  String riskEstimated(Object amount) {
    return 'Andaazan badlav $amount';
  }

  @override
  String riskNotCounted(Object stocks) {
    return '$stocks beta na hone se hisaab mein nahi.';
  }

  @override
  String get riskMostImpact => 'Sabse zyada asar';

  @override
  String riskStockShare(Object name) {
    return '$name ka hissa';
  }

  @override
  String get riskStockNoBeta =>
      'Is stock ka beta nahi hai, isliye portfolio beta mein nahi gina.';

  @override
  String get riskIfChange => 'Agar is stock mein badlav ho';

  @override
  String get riskStockField => 'Stock ka naam ya symbol';

  @override
  String get riskYouHold => 'Aapke paas';

  @override
  String get riskAdd => 'Jodo';

  @override
  String get riskReduce => 'Ghatao';

  @override
  String get riskAmount => 'Rakam (₹)';

  @override
  String riskWarnStock(Object symbol, Object pct, Object limit) {
    return '$symbol portfolio ka $pct% hoga, $limit% ki line se upar.';
  }

  @override
  String get alertEnterPrice => 'Sahi bhaav daalo';

  @override
  String get alertMustAbove => 'Bhaav abhi ke bhaav se upar hona chahiye';

  @override
  String get alertMustBelow => 'Bhaav abhi ke bhaav se neeche hona chahiye';

  @override
  String caTitle(Object symbol, Object label) {
    return '$symbol: $label aaya';
  }

  @override
  String caBody(Object before, Object extra) {
    return 'Us din aapke paas $before shares the, to $extra naye shares (₹0 par) judenge.';
  }

  @override
  String caNow(Object qty, Object avg) {
    return 'Abhi: $qty shares @ $avg';
  }

  @override
  String caAfter(Object qty, Object avg) {
    return 'Update ke baad: $qty shares @ $avg';
  }

  @override
  String caInvested(Object amount) {
    return 'Invested wahi rahega: $amount';
  }

  @override
  String get caFraction =>
      'Adhoora share nahi joda: broker uske badle paise deta hai.';

  @override
  String get caMatch =>
      'Broker app me shares ki ginti se mila lo. Galat ho to baad me Trade book se hata sakte ho.';

  @override
  String get caLater => 'Baad me';

  @override
  String get commonNo => 'Nahi';

  @override
  String get caYesAdd => 'Haan, jodo';

  @override
  String cardLtp(Object price) {
    return 'LTP: $price';
  }

  @override
  String alertWeightTitle(Object symbol) {
    return 'Weight alert: $symbol';
  }

  @override
  String alertWeightBody(Object symbol, Object pct) {
    return '$symbol aapke portfolio ka $pct% hai, 25% ki concentration line se upar.';
  }

  @override
  String get alertChecksTitle => 'Portfolio checks chalu';

  @override
  String alertChecksBody(Object count) {
    return 'Har baar alerts load hone par aapke $count holdings ka concentration check hota hai.';
  }

  @override
  String get alertWelcomeBody =>
      'Automatic risk monitoring ke liye Portfolio mein apne holdings jodiye.';

  @override
  String get errNoInternet =>
      'Internet connection nahi hai. Network check karke Try Again dabaiye.';

  @override
  String get errGeneric =>
      'Load karte waqt kuch gadbad hui. Thodi der baad dobara try kijiye.';

  @override
  String get importNotZerodha =>
      'Ye Zerodha tradebook nahi lagti: symbol, trade_date, trade_type, quantity, price, trade_id columns nahi mile.';

  @override
  String get advGreeting =>
      'Namaste! Main hoon **NV Advisor**\n\nMain aapka research assistant hoon. Aapke portfolio holdings, P&L, NV Scores, **Peer Comparisons** aur **Risk Checks** ke numbers samjhata hoon; khareedne ya bechne ki salah nahi deta.\n\nAap mujhse koi bhi portfolio ya stock question pooch sakte hain!';

  @override
  String get advAsk1 =>
      'Mere portfolio ki 3 sabse badi galtiyan aur risk batao';

  @override
  String get advAsk2 => 'Tata Motors vs Maruti kisme better growth hai?';

  @override
  String get advAsk3 => 'Titan vs Trent comparison';

  @override
  String get advAsk4 => 'UltraTech ka rate aur NV score kya hai?';

  @override
  String get advAsk5 => 'Mera portfolio performance kaisa hai?';

  @override
  String get advAsk6 => 'Nifty 50 aur market ka trend kya hai?';

  @override
  String caExDate(Object date, Object multiple) {
    return 'Ex-date $date: har 1 share par ab $multiple shares. ';
  }

  @override
  String get narrEtf => 'Exchange-Traded Fund';

  @override
  String narrEtfBrief(Object name, Object sector) {
    return '$name ek exchange-traded fund hai jo $sector ko track karta hai. Iska price underlying basket ke saath chalta hai, isliye ROCE jaise company ke ratios laagu nahi hote; NV Score isme quality 75 aur valuation 60 fixed rakhta hai aur sirf 12 mahine ke return rank par score deta hai.';
  }

  @override
  String get narrEtfBasket => 'Diversified basket';

  @override
  String get narrEtfBasketBody =>
      'Isme kai securities (ya commodity) hoti hain, isliye ek company ke results ka asar single stock se kam hota hai.';

  @override
  String get narrEtfBenchmark => 'Benchmark ke saath chalta hai';

  @override
  String get narrEtfBenchmarkBody =>
      'Return usi index ya commodity ke saath chalta hai jise yeh track karta hai, girawat mein bhi.';

  @override
  String narrEtfOwned(Object score) {
    return 'Aapke portfolio mein hai. NV Score $score/100, zyadatar 12 mahine ke return rank se bana.';
  }

  @override
  String narrEtfNotOwned(Object score) {
    return 'NV Score $score/100, zyadatar 12 mahine ke return rank se bana.';
  }

  @override
  String get narrEtfWatch =>
      'Benchmark se tracking difference aur expense ratio (fund house ki factsheet mein).';

  @override
  String get narrEtfUpdates =>
      'Daily closing prices se 12 mahine ka return rank update hota hai.';

  @override
  String get narrNotEnough => 'Abhi kaafi quality data nahi';

  @override
  String narrPendingBrief(Object name, Object why) {
    return '$name ka NV Score abhi nahi: $why. Bahut kam inputs par bana score gumrah karega, isliye nahi dikhaya.';
  }

  @override
  String get narrMissing => 'Kya kami hai';

  @override
  String narrMissingBody(Object why) {
    return '$why. Score ke liye 4 mein se kam se kam 3 quality inputs chahiye (return on capital, debt, cash conversion, growth).';
  }

  @override
  String get narrScorePending => 'Score: Pending';

  @override
  String get narrWhyNoScore => 'Score kyun nahi';

  @override
  String get narrNoAssumed => 'Kami wale inputs andaze se nahi bhare jaate.';

  @override
  String get narrInputsIncomplete => 'Inputs: Adhoore';

  @override
  String get narrPendingOwned =>
      'Abhi aapke portfolio mein hai. Holding, price aur P&L par asar nahi; sirf NV Score pending hai.';

  @override
  String get narrPendingNotOwned =>
      'Sirf NV Score pending hai; live price par asar nahi.';

  @override
  String get narrPendingWatch =>
      'Company ke agle annual results, jinse aksar kami wale inputs mil jaate hain.';

  @override
  String get narrPendingUpdates => 'Kaafi data aate hi score khud dikhega.';

  @override
  String narrReviewBrief(Object name) {
    return '$name ke hamare fundamentals exchange data se match nahi hue: market cap ya price kisi aur company ka hai. Data theek hone tak score nahi diya jayega.';
  }

  @override
  String get narrChecked => 'Humne kya jaancha';

  @override
  String get narrCheckedBody =>
      'Saved market cap aur price ko NSE closing price aur ek alag market-cap source se milaya gaya.';

  @override
  String get narrCheckFailed => 'Check: Fail';

  @override
  String get narrWrongNumbers =>
      'Kisi aur company ke numbers par bana score gumrah karega, isliye nahi dikhaya.';

  @override
  String get narrScoreWithheld => 'Score: Roka gaya';

  @override
  String get narrReviewOwned =>
      'Abhi aapke portfolio mein hai. Holding, price aur P&L par asar nahi; sirf NV Score roka gaya hai.';

  @override
  String get narrReviewNotOwned =>
      'Sirf NV Score roka gaya hai; live price par asar nahi.';

  @override
  String get narrReviewWatch =>
      'Data theek hone tak company ke latest results NSE / BSE website par dekhiye.';

  @override
  String get narrReviewUpdates =>
      'Data check pass karte hi score khud wapas aayega.';

  @override
  String get narrHoldingTag => 'Investment Holding Company (SOTP chahiye)';

  @override
  String get narrInsuranceTag =>
      'Actuarial Underwriting Entity (EV model chahiye)';

  @override
  String get narrTrustTag => 'Yield Distribution Trust (NAV chahiye)';

  @override
  String get narrSpecialTag => 'Specialized Asset Class (score nahi diya)';

  @override
  String narrHoldingBrief(Object name) {
    return '$name ek equity investment holding company hai. Holding company discount aur non-operating dividend income se aam ROCE aur P/E ratios bigad jaate hain. Valuation Sum-of-the-Parts (SOTP) net asset value se dekha jaata hai.';
  }

  @override
  String narrInsuranceBrief(Object name) {
    return '$name ek actuarial insurance underwriting portfolio chalati hai. Statutory accounting aur premium float ki wajah se ROCE laagu nahi hota; valuation Value of New Business (VNB) margin aur Embedded Value (EV) se tay hota hai.';
  }

  @override
  String narrTrustBrief(Object name) {
    return '$name ek structured trust hai jo rental/infrastructure cash flows baant-ta hai. Aam score ki jagah Net Asset Value (NAV) aur distribution yield dekha jaata hai.';
  }

  @override
  String get narrHoldingNav => 'Underlying holdings ka NAV';

  @override
  String get narrFloat => 'Float compounding aur VNB expansion';

  @override
  String get narrDistribution => 'Niyamit distribution yield';

  @override
  String get narrHoldingNavBody =>
      'Value listed subsidiaries aur unlisted associates ke market cap growth se judi hai.';

  @override
  String get narrFloatBody =>
      'Lambi avadhi ka customer float aur badhta policyholder retention actuarial book value badhate hain.';

  @override
  String get narrDistributionBody =>
      'Zyada dividend payout ke niyam aur pass-through tax structure se cash distribution milta hai.';

  @override
  String get narrCoverage => 'Coverage: Specialized';

  @override
  String get narrDiscount => 'Holding company discount bana rehna';

  @override
  String get narrClaims => 'Actuarial claims / surrender risk';

  @override
  String get narrRate => 'Interest rate ka asar';

  @override
  String get narrDiscountBody =>
      'Holding company ke share aksar underlying holdings ki value se neeche trade karte hain; yeh farak company aur samay ke saath badalta hai.';

  @override
  String get narrClaimsBody =>
      'Commission ki regulatory seema aur achanak badhe claims quarterly margin par dabav daal sakte hain.';

  @override
  String get narrRateBody =>
      'Benchmark yield badhne se discount rate badhta hai aur trust ki capital value ghat-ti hai.';

  @override
  String get narrRiskSpecial => 'Risk: Specialized';

  @override
  String get narrSpecialOwned =>
      'Abhi aapke portfolio mein hai. Is category ka 1-100 score nahi nikalta; neeche diye metrics dekhiye.';

  @override
  String get narrSpecialNotOwned =>
      'Is category ka 1-100 score nahi nikalta kyunki aam operating ratios laagu nahi hote.';

  @override
  String get narrSpecialMetrics =>
      'Is category ke metrics: NAV discount (holding companies), EV / VNB (insurance), distribution yield (REITs / InvITs).';

  @override
  String get narrSpecialHold =>
      'Core subsidiary holdings ki market value aur parent ka capital allocation record.';

  @override
  String get narrSpecialIns =>
      'VNB margin, persistency ratio aur solvency margin ratio.';

  @override
  String get narrSpecialTrust =>
      'Occupancy rate, weighted average lease expiry (WALE) aur G-Sec par yield spread.';

  @override
  String get narrScoreProfile => 'Score profile';

  @override
  String narrNoScore(Object name) {
    return '$name ka NV Score abhi nahi hai.';
  }

  @override
  String narrScoreNoBreakdown(Object name, Object score) {
    return '$name ka NV Score $score/100 hai. Pillar ka breakdown agle score update ke baad dikhega.';
  }

  @override
  String get narrBreakdownPending => 'Breakdown pending';

  @override
  String get narrBreakdownNext =>
      'Quality, valuation aur price-trend ki details agle raat ke score update ke saath aayengi.';

  @override
  String get narrNoPillars => 'Abhi milane ke liye pillar data nahi.';

  @override
  String narrOwnedScore(Object score) {
    return 'Aapke portfolio mein hai. NV Score $score/100.';
  }

  @override
  String narrScoreLine(Object score) {
    return 'NV Score $score/100.';
  }

  @override
  String get narrBreakdownWatch =>
      'Score ke neeche ka breakdown batata hai kaunsa pillar ise badalta hai.';

  @override
  String narrHasScore(Object name, Object score) {
    return '$name ka NV Score $score/100 hai. ';
  }

  @override
  String narrMissingPillars(Object pillars) {
    return ' $pillars: abhi data nahi, isliye baaki pillars iska weight uthate hain.';
  }

  @override
  String narrRiskCap(Object cap) {
    return ' Ek risk check fail hua (pledge, net worth ya debt), isliye score $cap par ruk gaya.';
  }

  @override
  String narrQualityCap(Object cap) {
    return ' Quality pillar score ko $cap par rokta hai (quality 55 se neeche 54, 65 se koi rok nahi).';
  }

  @override
  String narrHurdle(Object factor) {
    return ' Quality 55 se neeche hai, isliye weighted score ko $factor se guna kiya gaya.';
  }

  @override
  String narrLenderCap(Object cap) {
    return ' Banks, NBFCs aur brokers par credit data aane tak $cap ki rok hai.';
  }

  @override
  String get narrInPortfolio => 'Aapke portfolio mein hai. ';

  @override
  String narrHighLow(Object high, Object low) {
    return 'Sabse zyada pillar: $high. Sabse kam pillar: $low.';
  }

  @override
  String narrHighest(Object pillar) {
    return 'Sabse zyada pillar: $pillar';
  }

  @override
  String narrLowest(Object pillar) {
    return 'Sabse kam pillar: $pillar';
  }

  @override
  String get narrNoDetail => 'Is pillar ki detail nahi hai.';

  @override
  String narrMostRoom(Object pillar) {
    return '$pillar pillar score ko sabse zyada badal sakta hai.';
  }

  @override
  String narrPartScore(Object label, Object points, Object max, Object detail) {
    return '$label ke $max mein se $points ($detail).';
  }

  @override
  String get narrRiskFlag => 'Risk flag';

  @override
  String get narrBelowHurdle => 'Quality hurdle se neeche';

  @override
  String get narrStrongLowVal => 'Mazboot quality, kam valuation';

  @override
  String get narrStrongHighVal => 'Mazboot quality, zyada valuation';

  @override
  String get narrStrongQuality => 'Mazboot quality';

  @override
  String get narrMixed => 'Mixed profile';

  @override
  String get narrNotScored => 'Score nahi';

  @override
  String get narrBandExcellent => 'Score band: Excellent';

  @override
  String get narrBandStrong => 'Score band: Strong';

  @override
  String get narrBandAverage => 'Score band: Average';

  @override
  String get narrBandWeak => 'Score band: Weak';

  @override
  String get commonAnd => 'aur';

  @override
  String get narrUpdates =>
      'Quarterly results se return on capital, debt, cash flow aur growth update hote hain; daily closing prices se valuation aur 12 mahine ka return rank.';

  @override
  String get mWhatTitle => 'Score kya hai';

  @override
  String get mWhatBody =>
      'Sirf published numbers se bana 0-100 score: return on capital, debt, cash flow, growth, valuation aur 12 mahine ka price return. Har stock par same rules lagte hain, aur koi insaan score chunta ya badalta nahi. Yeh company ki financial profile batata hai; yeh forecast nahi aur buy ya sell ki call nahi hai.';

  @override
  String get mBands => 'Score bands';

  @override
  String get mBandExcellent => 'Excellent: zyadatar paimano par mazboot';

  @override
  String get mBandStrong => 'Strong';

  @override
  String get mBandAverage => 'Average';

  @override
  String get mBandWeak => 'Weak: quality hurdle se neeche, ya risk flag';

  @override
  String get mPillars => 'Teen pillars';

  @override
  String get mPillarsBody =>
      'Overall score ek weighted mix hai. Valuation ya momentum ka data na ho to use chhod diya jaata hai aur uska weight baaki pillars mein baant jaata hai; andaze ki value kabhi nahi bhari jaati.';

  @override
  String get mQualityBody =>
      'Return on capital (ROCE) 40, debt to equity 25, operating cash flow vs profit 15, 5 saal ki sales aur profit growth 20 (20% saalana sales aur 25% profit par poore marks; ghatne par 0). ROCE aur debt aadha fixed scale par aur aadha same industry (15 ya zyada companies) ke rank par, warna same sector mein.';

  @override
  String get mValuationBody =>
      'Same industry ki companies se P/E ki tulna 50, apne 5 saal ke average se P/E ki tulna 30 (0.6x ya kam par poore marks, 0.85x par aadhe, 1.3x ya zyada par 0), aur 5 saal ki profit growth ke mukable P/E (PEG) 20 (1 ya kam par poore marks, 3 ya zyada par 0; growth 5% se 40% saalana ke beech gini jaati hai). Jis hisse ka data nahi, wo chhod diya jaata hai. Loss-making company ko 0 milta hai. Jin companies ne bada business demerge kiya ya jinka 5 saal ka average nahi, unme apne average ki jagah 10-year government bond ke mukable earnings yield lagta hai. Banks aur NBFCs mein P/B: banks ya NBFCs ke beech rank 60, apne 5 saal ke average se 40.';

  @override
  String get mMomentumBody =>
      'Pichhle 12 mahine ka price return, aakhri mahina chhod kar, har scored stock ke mukable rank (ek saal se kam listed stocks mein 6 mahine). RSI, MACD aur moving averages sirf jaankari ke liye hain, inka score nahi hota.';

  @override
  String get mHurdleBody =>
      'Quality pillar 55 se neeche ho to overall score 54 par ruk jaata hai. Quality 55 se 65 ke beech rok dheere dheere badhti hai (har quality point par lagbhag 4.6 points) aur 65 par khatam ho jaati hai, isliye quality ke chhote badlav se score nahi uchhalta. Sasta stock ya tez price run kamzor business ko strong bands mein nahi la sakta.';

  @override
  String get mMinData => 'Kam se kam data';

  @override
  String get mMinDataBody =>
      'Quality ke liye 4 mein se kam se kam 3 inputs chahiye (return on capital, debt, cash flow, growth). 2 inputs par overall score 60 par ruk jaata hai; usse kam par, ya return on capital ke bina, score nahi dikhta aur stock par DATA PENDING likha aata hai. Kami wale inputs kabhi maan kar nahi bhare jaate.';

  @override
  String get mRiskFlags => 'Risk flags';

  @override
  String get mRiskBody =>
      'Inme se koi bhi ho to score 28 par ruk jaata hai aur HIGH RISK FLAG dikhta hai, baaki numbers kuch bhi hon:';

  @override
  String get mPledge => 'Pledge';

  @override
  String get mPledgeBody =>
      'Promoter ke 75% ya zyada shares pledge, ya pledged shares company ke 25% ya zyada';

  @override
  String get mNetWorth => 'Net worth';

  @override
  String get mNetWorthBody =>
      'Shareholder equity zero ya negative (fundamentals dataset mein price-to-book positive ho to review mein rakha jaata hai)';

  @override
  String get mDebt => 'Debt';

  @override
  String get mDebtBody => 'Negative debt-to-equity figure (data ki gadbad)';

  @override
  String get mReviewed => 'Jaanche gaye pledges';

  @override
  String get mReviewedBody =>
      'Kuch bade pledges exchange filings se jaanche jaate hain. Agar promoter private-equity owner hai aur usne apne holding-company loan ke liye stake pledge kiya hai, to pledge sirf note ki tarah dikhta hai aur flag nahi lagta. Baaki har pledge par upar wala rule lagta hai.';

  @override
  String get mSpecial => 'Khaas cases';

  @override
  String get mBanks => 'Banks aur NBFCs';

  @override
  String get mBanksBody =>
      'Quality mein return on equity 30, return on assets 25, net interest margin 15 (sirf banks), leverage 10 aur growth 20. Loan quality (NPA) abhi nahi jaanchi jaati, isliye score 75 par rukta hai aur \"provisional\" badge dikhta hai.';

  @override
  String get mBrokers => 'Brokers';

  @override
  String get mBrokersBody =>
      'Debt ka score nahi hota (margin funding borrowings); \"provisional\" badge ke saath 75 par rukta hai.';

  @override
  String get mInsurance => 'Insurance, holding companies, REITs / InvITs';

  @override
  String get mInsuranceBody =>
      'Score nahi. Inke accounts in ratios mein fit nahi hote; inke liye embedded value, NAV ya yield chahiye.';

  @override
  String get mEtfsBody => 'Valuation neutral 60 rakha jaata hai.';

  @override
  String get mReview => 'Data review mein';

  @override
  String get mReviewBody =>
      'Hamare saved fundamentals exchange data ke check mein fail hon (market cap ya price kisi aur company ka) to score nahi. Data theek hote hi score wapas aata hai.';

  @override
  String get mLabels => 'Labels';

  @override
  String get mPositiveTrend => 'Positive trend';

  @override
  String get mPositiveBody =>
      'Momentum rank 50+. Positive side wala stock tab tak positive rehta hai jab tak rank 45 se neeche na gire; weak side wale ko paar karne ke liye 55 chahiye, isliye chhote daily badlav se label nahi palat-ta.';

  @override
  String get mHighStrength => 'Quality 70+, valuation 65+, positive trend';

  @override
  String get mConsolidation => 'Quality 70+, valuation 65+, weak trend';

  @override
  String get mFair => 'Quality 70+, valuation 35-64';

  @override
  String get mExtended => 'Quality 70+, valuation 35 se neeche, positive trend';

  @override
  String get mElevated => 'Quality 70+, valuation 35 se neeche, weak trend';

  @override
  String get mNeutral => 'Quality 55-69';

  @override
  String get mBelow => 'Quality 55 se neeche';

  @override
  String get mNegative => 'Quality 70+, par company loss-making hai';

  @override
  String get mUnavailable =>
      'Quality 70+, par 6 mahine se kam price history ya valuation data nahi';

  @override
  String get mUnconfirmed =>
      'Pledge data nahi hai, isliye risk check nahi chal paaya';

  @override
  String get mDataPending => 'Score ke liye abhi kaafi data nahi';

  @override
  String get mFreshness => 'Data aur freshness';

  @override
  String get mFreshnessBody =>
      'Fundamentals companies ke published results se bane dataset se aate hain; koi figure na ho to debt aur cash flow Yahoo Finance se liye jaate hain; net worth, margins aur bank balance-sheet figures Yahoo Finance se aate hain. Closing prices NSE ki daily bhavcopy se aate hain; market ke samay ke prices Yahoo Finance se aate hain aur der se ho sakte hain. Score har trading day ke close ke baad dobara banta hai. Data adhoora ya galat ho sakta hai; kisi number par bharosa karne se pehle company ki filings dekhiye.';

  @override
  String get syncStepAuth => 'Login check ho raha hai';

  @override
  String get syncStepHoldings => 'Portfolio holdings load ho rahe hain';

  @override
  String get syncStepPrices => 'Latest prices aur health sync ho rahe hain';

  @override
  String get syncLoading => 'Portfolio load ho raha hai...';

  @override
  String get dashToday => 'AAJ';

  @override
  String get signalWeakest => 'SABSE KAMZOR';

  @override
  String get recoStrong => 'Mazboot returns';

  @override
  String recoAbove(Object ret) {
    return 'Aapke holdings apni total cost se $ret upar hain.';
  }

  @override
  String get recoPositive => 'Positive returns';

  @override
  String get recoNearCost => 'Cost ke aas-paas';

  @override
  String recoAgainst(Object ret) {
    return 'Aapke holdings apni total cost ke mukable $ret hain.';
  }

  @override
  String get recoMild => 'Halki girawat';

  @override
  String recoBelow(Object ret) {
    return 'Aapke holdings apni total cost se $ret neeche hain.';
  }

  @override
  String get recoBelowCost => 'Cost se neeche';

  @override
  String recoOverall(Object ret) {
    return 'Overall return: $ret.';
  }

  @override
  String recoAboveBuy(Object profit, Object total) {
    return '$total mein se $profit holdings apne buy price se upar hain.';
  }

  @override
  String recoHealth(Object score) {
    return 'NV Health Index $score/100 (value ke hisaab se average NV Score).';
  }

  @override
  String recoLoss(Object count) {
    return '$count holdings apne buy price se neeche hain; har ek ke \"Yeh score kyun\" mein uska sabse kam pillar dikhta hai.';
  }

  @override
  String recoLargestFall(Object symbol, Object pct) {
    return 'Sabse badi girawat: $symbol ($pct).';
  }

  @override
  String recoUnpriced(Object count) {
    return '$count holdings ka current price nahi hai, isliye total mein shaamil nahi.';
  }

  @override
  String recoStale(Object count) {
    return '$count holdings aakhri saved price dikha rahe hain, live nahi.';
  }

  @override
  String get recoNoneBelow => 'Koi holding apne buy price se neeche nahi hai.';

  @override
  String get errSymbolNotListed =>
      'Ye symbol NSE list mein nahi mila. Search se stock chuno.';

  @override
  String get errLoginRequired => 'Login zaroori hai.';
}
