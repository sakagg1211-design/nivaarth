import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'IN'),
  ];

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset link. Please check your email and try again.'**
  String get authResetFailed;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetTitle;

  /// No description provided for @authResetCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for a recovery link.'**
  String get authResetCheckInbox;

  /// No description provided for @authResetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the email linked to your Nivaarth account to receive a reset link.'**
  String get authResetPrompt;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Link Sent'**
  String get authResetSent;

  /// No description provided for @authResetSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent instructions to {email}.'**
  String authResetSentTo(Object email);

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @authRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered Email'**
  String get authRegisteredEmail;

  /// No description provided for @authSendReset.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authSendReset;

  /// No description provided for @authEnterBoth.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password.'**
  String get authEnterBoth;

  /// No description provided for @authWrongCreds.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authWrongCreds;

  /// No description provided for @commonNetworkIssue.
  ///
  /// In en, this message translates to:
  /// **'Network issue. Please check your internet connection.'**
  String get commonNetworkIssue;

  /// No description provided for @authTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again shortly.'**
  String get authTooMany;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please verify your details.'**
  String get authSignInFailed;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Private portfolio intelligence for focused investors.'**
  String get authTagline;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgot;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get authEnterName;

  /// No description provided for @authPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get authPasswordShort;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @authAcceptRisk.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge that stock investments carry market risks and accept the terms.'**
  String get authAcceptRisk;

  /// No description provided for @authEmailExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Please log in.'**
  String get authEmailExists;

  /// No description provided for @authCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create account. Please try again.'**
  String get authCreateFailed;

  /// No description provided for @authAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get authAccountCreated;

  /// No description provided for @authAccountReady.
  ///
  /// In en, this message translates to:
  /// **'Your Nivaarth account is ready! If verification is requested, check {email} to confirm.'**
  String authAccountReady(Object email);

  /// No description provided for @authProceedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Sign In'**
  String get authProceedSignIn;

  /// No description provided for @authJoinBeta.
  ///
  /// In en, this message translates to:
  /// **'Join the private closed beta of Nivaarth.'**
  String get authJoinBeta;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHaveAccount;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Quantitative portfolio intelligence for serious Indian investors.'**
  String get welcomeTagline;

  /// No description provided for @welcomePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private & Isolated'**
  String get welcomePrivateTitle;

  /// No description provided for @welcomePrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio data is isolated and protected with zero cross-user access.'**
  String get welcomePrivateBody;

  /// No description provided for @welcomeScoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Factor AI Scoring'**
  String get welcomeScoringTitle;

  /// No description provided for @welcomeScoringBody.
  ///
  /// In en, this message translates to:
  /// **'Fundamental, technical, management, and risk dimensions ranked continuously.'**
  String get welcomeScoringBody;

  /// No description provided for @welcomeCockpitTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Cockpit'**
  String get welcomeCockpitTitle;

  /// No description provided for @welcomeCockpitBody.
  ///
  /// In en, this message translates to:
  /// **'Instant P&L tracking, live prices, and actionable explainable signals.'**
  String get welcomeCockpitBody;

  /// No description provided for @authCreateAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get authCreateAnAccount;

  /// No description provided for @homeBackToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit Nivaarth'**
  String get homeBackToExit;

  /// No description provided for @legalAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Acknowledge'**
  String get legalAcknowledge;

  /// No description provided for @syncFetchingPrices.
  ///
  /// In en, this message translates to:
  /// **'Fetching Latest Market Prices...'**
  String get syncFetchingPrices;

  /// No description provided for @syncReady.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Ready'**
  String get syncReady;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Portfolio could not be loaded. Tap Try Again on the Portfolio tab.'**
  String get syncFailed;

  /// No description provided for @syncPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your portfolio intelligence'**
  String get syncPreparing;

  /// No description provided for @syncDontClose.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t close the app.\nWe\'re preparing the latest market intelligence.'**
  String get syncDontClose;

  /// No description provided for @menuFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Feedback / Report Bug'**
  String get menuFeedbackTitle;

  /// No description provided for @menuFeedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Direct channel to the engineering team'**
  String get menuFeedbackBody;

  /// No description provided for @menuLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Compliance & Legal Disclaimers'**
  String get menuLegalTitle;

  /// No description provided for @menuLegalBody.
  ///
  /// In en, this message translates to:
  /// **'SEBI non-advisory notice & platform terms'**
  String get menuLegalBody;

  /// No description provided for @menuLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menuLogOut;

  /// No description provided for @menuLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'Sign out and return to welcome screen'**
  String get menuLogOutBody;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends Beta Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Found a bug or have a suggestion? Let us know directly:'**
  String get feedbackPrompt;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue or idea...'**
  String get feedbackHint;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback has been noted for the next release.'**
  String get feedbackThanks;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of Nivaarth?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to view your private portfolio cockpit.'**
  String get logoutConfirmBody;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetEvening;

  /// No description provided for @tipShowValues.
  ///
  /// In en, this message translates to:
  /// **'Show Values'**
  String get tipShowValues;

  /// No description provided for @tipHideValues.
  ///
  /// In en, this message translates to:
  /// **'Hide Values (Privacy Mode)'**
  String get tipHideValues;

  /// No description provided for @tipProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile & Details'**
  String get tipProfile;

  /// No description provided for @tipNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tipNotifications;

  /// No description provided for @dashLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Building portfolio cockpit'**
  String get dashLoadingTitle;

  /// No description provided for @dashLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Fetching live valuation, health scores and AI signals.'**
  String get dashLoadingBody;

  /// No description provided for @dashUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dashboard unavailable'**
  String get dashUnavailable;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @dashBriefingSub.
  ///
  /// In en, this message translates to:
  /// **'What the numbers of your holdings show today.'**
  String get dashBriefingSub;

  /// No description provided for @dashWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nivaarth Cockpit'**
  String get dashWelcome;

  /// No description provided for @dashTools.
  ///
  /// In en, this message translates to:
  /// **'Nivaarth research tools'**
  String get dashTools;

  /// No description provided for @dashAddPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add your current equity holdings to activate real-time analytics:'**
  String get dashAddPrompt;

  /// No description provided for @dashToolScore.
  ///
  /// In en, this message translates to:
  /// **'Rules-based NV Score (0-100)'**
  String get dashToolScore;

  /// No description provided for @dashToolScoreSub.
  ///
  /// In en, this message translates to:
  /// **'Quality 50%, Valuation 30%, Price trend 20%'**
  String get dashToolScoreSub;

  /// No description provided for @dashToolHealth.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Portfolio Health & Risk Radar'**
  String get dashToolHealth;

  /// No description provided for @dashToolHealthSub.
  ///
  /// In en, this message translates to:
  /// **'Concentration, sector mix and holdings below their buy price'**
  String get dashToolHealthSub;

  /// No description provided for @dashToolAdvisor.
  ///
  /// In en, this message translates to:
  /// **'NV Advisor Contextual Co-Pilot'**
  String get dashToolAdvisor;

  /// No description provided for @dashToolAdvisorSub.
  ///
  /// In en, this message translates to:
  /// **'Ask about your holdings; answers use your data and NV Scores'**
  String get dashToolAdvisorSub;

  /// No description provided for @dashAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Holding'**
  String get dashAddFirst;

  /// No description provided for @indexMarketClosed.
  ///
  /// In en, this message translates to:
  /// **'MARKET CLOSED'**
  String get indexMarketClosed;

  /// No description provided for @indexPerformance.
  ///
  /// In en, this message translates to:
  /// **'Market Index Performance'**
  String get indexPerformance;

  /// No description provided for @indexChartUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Index chart unavailable right now'**
  String get indexChartUnavailable;

  /// No description provided for @indexRanges.
  ///
  /// In en, this message translates to:
  /// **'Price Spectrum & Ranges'**
  String get indexRanges;

  /// No description provided for @indexTodayRange.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Range'**
  String get indexTodayRange;

  /// No description provided for @indexTodayRangeNa.
  ///
  /// In en, this message translates to:
  /// **'Today\'s range unavailable'**
  String get indexTodayRangeNa;

  /// No description provided for @index52wRange.
  ///
  /// In en, this message translates to:
  /// **'52-Week Range'**
  String get index52wRange;

  /// No description provided for @index52wLoading.
  ///
  /// In en, this message translates to:
  /// **'52-week range loading…'**
  String get index52wLoading;

  /// No description provided for @index52wNa.
  ///
  /// In en, this message translates to:
  /// **'52-week range unavailable'**
  String get index52wNa;

  /// No description provided for @indexAbout.
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String indexAbout(Object name);

  /// No description provided for @indexAboutNifty.
  ///
  /// In en, this message translates to:
  /// **'The NIFTY 50 is India\'s benchmark stock market index representing the weighted average of 50 of the largest and most liquid Indian companies listed on the National Stock Exchange. It serves as the primary gauge of India\'s broader economy and capital markets.'**
  String get indexAboutNifty;

  /// No description provided for @indexAboutSensex.
  ///
  /// In en, this message translates to:
  /// **'The BSE SENSEX is India\'s oldest and premier market barometer comprising 30 prominent, financially sound, and actively traded companies listed on the Bombay Stock Exchange, covering major sectors of the Indian economy.'**
  String get indexAboutSensex;

  /// No description provided for @indexLargestSectors.
  ///
  /// In en, this message translates to:
  /// **'Largest sectors in the index'**
  String get indexLargestSectors;

  /// No description provided for @indexWeightsNifty.
  ///
  /// In en, this message translates to:
  /// **'Current sector weights are in the monthly NIFTY 50 factsheet on niftyindices.com.'**
  String get indexWeightsNifty;

  /// No description provided for @indexWeightsSensex.
  ///
  /// In en, this message translates to:
  /// **'Current sector weights are in the BSE SENSEX factsheet on bseindia.com.'**
  String get indexWeightsSensex;

  /// No description provided for @indexTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical Indicators'**
  String get indexTechnical;

  /// No description provided for @indexTechnicalSub.
  ///
  /// In en, this message translates to:
  /// **'Calculated from daily closing prices over the last year.'**
  String get indexTechnicalSub;

  /// No description provided for @indexLoadingDaily.
  ///
  /// In en, this message translates to:
  /// **'Loading daily prices…'**
  String get indexLoadingDaily;

  /// No description provided for @indexIndicatorsNa.
  ///
  /// In en, this message translates to:
  /// **'Indicators unavailable right now.'**
  String get indexIndicatorsNa;

  /// No description provided for @indexPriceAbove.
  ///
  /// In en, this message translates to:
  /// **'Price above'**
  String get indexPriceAbove;

  /// No description provided for @indexPriceBelow.
  ///
  /// In en, this message translates to:
  /// **'Price below'**
  String get indexPriceBelow;

  /// No description provided for @indexEma20.
  ///
  /// In en, this message translates to:
  /// **'20-day EMA'**
  String get indexEma20;

  /// No description provided for @indexAvg50.
  ///
  /// In en, this message translates to:
  /// **'50-day average'**
  String get indexAvg50;

  /// No description provided for @indexAvg200.
  ///
  /// In en, this message translates to:
  /// **'200-day average'**
  String get indexAvg200;

  /// No description provided for @indexOverbought.
  ///
  /// In en, this message translates to:
  /// **'Overbought zone (70+)'**
  String get indexOverbought;

  /// No description provided for @indexOversold.
  ///
  /// In en, this message translates to:
  /// **'Oversold zone (30-)'**
  String get indexOversold;

  /// No description provided for @indexNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral zone'**
  String get indexNeutral;

  /// No description provided for @indexRsi.
  ///
  /// In en, this message translates to:
  /// **'RSI (14 days)'**
  String get indexRsi;

  /// No description provided for @indexNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough daily prices yet.'**
  String get indexNotEnough;

  /// No description provided for @briefCoverageNa.
  ///
  /// In en, this message translates to:
  /// **'Data coverage —'**
  String get briefCoverageNa;

  /// No description provided for @briefCoverage.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Data coverage'**
  String briefCoverage(Object pct);

  /// No description provided for @briefReasons.
  ///
  /// In en, this message translates to:
  /// **'Reasons'**
  String get briefReasons;

  /// No description provided for @briefToCheck.
  ///
  /// In en, this message translates to:
  /// **'What to check'**
  String get briefToCheck;

  /// No description provided for @allocTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio split'**
  String get allocTitle;

  /// No description provided for @allocMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market cap'**
  String get allocMarketCap;

  /// No description provided for @allocSector.
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get allocSector;

  /// No description provided for @allocCapNote.
  ///
  /// In en, this message translates to:
  /// **'Large: top 100 companies by market cap · Mid: 101–250 · Small: the rest'**
  String get allocCapNote;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @allocShareSector.
  ///
  /// In en, this message translates to:
  /// **'Portfolio: by sector'**
  String get allocShareSector;

  /// No description provided for @allocShareCap.
  ///
  /// In en, this message translates to:
  /// **'Portfolio: by market cap'**
  String get allocShareCap;

  /// No description provided for @signalWinner.
  ///
  /// In en, this message translates to:
  /// **'BIGGEST WINNER'**
  String get signalWinner;

  /// No description provided for @signalStrongest.
  ///
  /// In en, this message translates to:
  /// **'STRONGEST HOLDING'**
  String get signalStrongest;

  /// No description provided for @signalNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'Not assessed'**
  String get signalNotAssessed;

  /// No description provided for @signalDiversification.
  ///
  /// In en, this message translates to:
  /// **'DIVERSIFICATION'**
  String get signalDiversification;

  /// No description provided for @signalTopSector.
  ///
  /// In en, this message translates to:
  /// **'Top sector {pct}%'**
  String signalTopSector(Object pct);

  /// No description provided for @topHoldingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Holdings'**
  String get topHoldingsTitle;

  /// No description provided for @topHoldingsSub.
  ///
  /// In en, this message translates to:
  /// **'Ranked by highest current valuation (₹)'**
  String get topHoldingsSub;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @macroBreadth.
  ///
  /// In en, this message translates to:
  /// **'Breadth'**
  String get macroBreadth;

  /// No description provided for @macroAdvances.
  ///
  /// In en, this message translates to:
  /// **'{n} up'**
  String macroAdvances(Object n);

  /// No description provided for @macroDeclines.
  ///
  /// In en, this message translates to:
  /// **'{n} down'**
  String macroDeclines(Object n);

  /// No description provided for @macroWhatIf.
  ///
  /// In en, this message translates to:
  /// **'If this happens'**
  String get macroWhatIf;

  /// No description provided for @healthIndex.
  ///
  /// In en, this message translates to:
  /// **'NV HEALTH INDEX'**
  String get healthIndex;

  /// No description provided for @commonLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get commonLive;

  /// No description provided for @commonMarketClosed.
  ///
  /// In en, this message translates to:
  /// **'Market closed'**
  String get commonMarketClosed;

  /// No description provided for @healthCoverageNa.
  ///
  /// In en, this message translates to:
  /// **'Data coverage: —'**
  String get healthCoverageNa;

  /// No description provided for @healthCoverage.
  ///
  /// In en, this message translates to:
  /// **'Data coverage: {pct}%'**
  String healthCoverage(Object pct);

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String healthStatus(Object status);

  /// No description provided for @healthExplain.
  ///
  /// In en, this message translates to:
  /// **'Average NV Score of your scored holdings, weighted by value.'**
  String get healthExplain;

  /// No description provided for @healthOpenAdvisorHint.
  ///
  /// In en, this message translates to:
  /// **'Open NV Advisor from the bottom bar.'**
  String get healthOpenAdvisorHint;

  /// No description provided for @healthOpenAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Open Advisor'**
  String get healthOpenAdvisor;

  /// No description provided for @healthMarketOpenNote.
  ///
  /// In en, this message translates to:
  /// **'Market open: prices refresh every few minutes. NV Scores update every evening.'**
  String get healthMarketOpenNote;

  /// No description provided for @healthMarketClosedNote.
  ///
  /// In en, this message translates to:
  /// **'Market closed: prices are the last close. NV Scores update every evening.'**
  String get healthMarketClosedNote;

  /// No description provided for @heroQuiet.
  ///
  /// In en, this message translates to:
  /// **'{count} stocks had no trade in 15 min ({names}) — the price is from the last trade'**
  String heroQuiet(Object count, Object names);

  /// No description provided for @heroClosedNote.
  ///
  /// In en, this message translates to:
  /// **'Market closed · today\'s closing prices'**
  String get heroClosedNote;

  /// No description provided for @heroUnpriced.
  ///
  /// In en, this message translates to:
  /// **'No price for {count} stocks — not included in the total'**
  String heroUnpriced(Object count);

  /// No description provided for @heroStale.
  ///
  /// In en, this message translates to:
  /// **'{count} stocks did not update in this refresh — showing the last saved price'**
  String heroStale(Object count);

  /// No description provided for @heroValue.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO VALUE'**
  String get heroValue;

  /// No description provided for @heroTotalPl.
  ///
  /// In en, this message translates to:
  /// **'Total P&L'**
  String get heroTotalPl;

  /// No description provided for @heroToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get heroToday;

  /// No description provided for @holdingRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {symbol}?'**
  String holdingRemoveTitle(Object symbol);

  /// No description provided for @holdingRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{symbol} and all its trades will be removed from the portfolio.\n\nSold the shares? Then don\'t delete: open the stock and add a SELL trade, so the trade history and the \"last time\" figures stay.'**
  String holdingRemoveBody(Object symbol);

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @holdingRemoved.
  ///
  /// In en, this message translates to:
  /// **'{symbol} removed.'**
  String holdingRemoved(Object symbol);

  /// No description provided for @commonPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get commonPriceUnavailable;

  /// No description provided for @holdingEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Holding'**
  String get holdingEdit;

  /// No description provided for @holdingDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Holding'**
  String get holdingDelete;

  /// No description provided for @heroClosedOn.
  ///
  /// In en, this message translates to:
  /// **'Market closed · closing prices of {date}'**
  String heroClosedOn(Object date);

  /// No description provided for @heroRefreshedAt.
  ///
  /// In en, this message translates to:
  /// **'Refreshed at {time}'**
  String heroRefreshedAt(Object time);

  /// No description provided for @heroRefreshedOn.
  ///
  /// In en, this message translates to:
  /// **'Refreshed {date}, {time}'**
  String heroRefreshedOn(Object date, Object time);

  /// No description provided for @closedTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed positions'**
  String get closedTitle;

  /// No description provided for @closedLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Closed positions could not be loaded'**
  String get closedLoadFailed;

  /// No description provided for @commonCheckInternet.
  ///
  /// In en, this message translates to:
  /// **'Check your internet and try again.'**
  String get commonCheckInternet;

  /// No description provided for @closedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No closed positions'**
  String get closedEmptyTitle;

  /// No description provided for @closedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you fully sell a stock, it will appear here with its realized P&L.'**
  String get closedEmptyBody;

  /// No description provided for @closedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stocks fully sold'**
  String closedCount(Object count);

  /// No description provided for @closedRealized.
  ///
  /// In en, this message translates to:
  /// **'Realized {amount}'**
  String closedRealized(Object amount);

  /// No description provided for @tradeBought.
  ///
  /// In en, this message translates to:
  /// **'Bought {amount}'**
  String tradeBought(Object amount);

  /// No description provided for @tradeSold.
  ///
  /// In en, this message translates to:
  /// **'Sold {amount}'**
  String tradeSold(Object amount);

  /// No description provided for @closedLastSell.
  ///
  /// In en, this message translates to:
  /// **'Last sell {date}'**
  String closedLastSell(Object date);

  /// No description provided for @closedTrades.
  ///
  /// In en, this message translates to:
  /// **'{count} trades'**
  String closedTrades(Object count);

  /// No description provided for @importStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get importStarting;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Tradebook import'**
  String get importTitle;

  /// No description provided for @importHeading.
  ///
  /// In en, this message translates to:
  /// **'Zerodha tradebook (CSV or Excel)'**
  String get importHeading;

  /// No description provided for @importSteps.
  ///
  /// In en, this message translates to:
  /// **'Console → Reports → Tradebook → Segment: Equity → Download (CSV or XLSX). You will see a preview first; nothing is saved until you tap \"Import\". Adding the same file again will not add the earlier trades twice.'**
  String get importSteps;

  /// No description provided for @importPickFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file (CSV / XLSX)'**
  String get importPickFile;

  /// No description provided for @importPickOther.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importPickOther;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'{count} trades imported ({stocks} stocks).'**
  String importDone(Object count, Object stocks);

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'{stocks} stocks · {trades} new trades'**
  String importSummary(Object stocks, Object trades);

  /// No description provided for @importUnlisted.
  ///
  /// In en, this message translates to:
  /// **'These symbols are not in Nivaarth\'s list and will not be imported: {symbols}. '**
  String importUnlisted(Object symbols);

  /// No description provided for @importRenamed.
  ///
  /// In en, this message translates to:
  /// **'(If the name changed, as after a demerger, add the stock yourself from Add Holding.)'**
  String get importRenamed;

  /// No description provided for @importBonusNote.
  ///
  /// In en, this message translates to:
  /// **'Bonuses and splits are not in the tradebook. If such a stock\'s quantity differs from your broker\'s, check that stock.'**
  String get importBonusNote;

  /// No description provided for @importNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to import'**
  String get importNothingNew;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import ({trades} trades, {stocks} stocks)'**
  String importConfirm(Object trades, Object stocks);

  /// No description provided for @importNotHeld.
  ///
  /// In en, this message translates to:
  /// **'Not in the portfolio now'**
  String get importNotHeld;

  /// No description provided for @importHeldNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {qty} shares'**
  String importHeldNow(Object qty);

  /// No description provided for @importFromBook.
  ///
  /// In en, this message translates to:
  /// **'Build from tradebook'**
  String get importFromBook;

  /// No description provided for @importOnlyNew.
  ///
  /// In en, this message translates to:
  /// **'Add new only'**
  String get importOnlyNew;

  /// No description provided for @importFromBookNote.
  ///
  /// In en, this message translates to:
  /// **'The old opening holding goes away; the holding is built only from tradebook trades.'**
  String get importFromBookNote;

  /// No description provided for @importOnlyNewNote.
  ///
  /// In en, this message translates to:
  /// **'The old holding stays and tradebook trades are added on top (careful: old buys must not be added twice).'**
  String get importOnlyNewNote;

  /// No description provided for @importManualWarn.
  ///
  /// In en, this message translates to:
  /// **'You also entered {count} trades of this stock by hand. If the same trade is in the tradebook, it will be added twice; after import, check Trade book and remove the repeated trade.'**
  String importManualWarn(Object count);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Will not be imported: {error}'**
  String importError(Object error);

  /// No description provided for @importResultClosed.
  ///
  /// In en, this message translates to:
  /// **'After import: fully sold (Closed positions), realized {pl}'**
  String importResultClosed(Object pl);

  /// No description provided for @importResultOpen.
  ///
  /// In en, this message translates to:
  /// **'After import: {qty} shares @ {avg} · Invested {invested}'**
  String importResultOpen(Object qty, Object avg, Object invested);

  /// No description provided for @addHolding.
  ///
  /// In en, this message translates to:
  /// **'Add Holding'**
  String get addHolding;

  /// No description provided for @portfolioLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading holdings'**
  String get portfolioLoadingTitle;

  /// No description provided for @portfolioLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Pulling your live portfolio positions.'**
  String get portfolioLoadingBody;

  /// No description provided for @portfolioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Portfolio unavailable'**
  String get portfolioUnavailable;

  /// No description provided for @portfolioEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Portfolio Holdings Yet'**
  String get portfolioEmptyTitle;

  /// No description provided for @portfolioEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your investment positions to unlock real-time Indian stock valuations, P&L, and AI scores.'**
  String get portfolioEmptyBody;

  /// No description provided for @portfolioAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Stock'**
  String get portfolioAddFirst;

  /// No description provided for @portfolioOpenTradeBook.
  ///
  /// In en, this message translates to:
  /// **'View trade book'**
  String get portfolioOpenTradeBook;

  /// No description provided for @portfolioImport.
  ///
  /// In en, this message translates to:
  /// **'Zerodha tradebook import'**
  String get portfolioImport;

  /// No description provided for @tradeBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade book'**
  String get tradeBookTitle;

  /// No description provided for @portfolioTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} holdings under active tracking.'**
  String portfolioTracked(Object count);

  /// No description provided for @sortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (A-Z)'**
  String get sortAlphabetical;

  /// No description provided for @sortTodayGainers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Top Gainers (₹)'**
  String get sortTodayGainers;

  /// No description provided for @sortTodayLosers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Top Losers (₹)'**
  String get sortTodayLosers;

  /// No description provided for @sortOverallGainers.
  ///
  /// In en, this message translates to:
  /// **'Overall Top Gainers (%)'**
  String get sortOverallGainers;

  /// No description provided for @sortOverallLosers.
  ///
  /// In en, this message translates to:
  /// **'Overall Top Losers (%)'**
  String get sortOverallLosers;

  /// No description provided for @sortHighestValue.
  ///
  /// In en, this message translates to:
  /// **'Highest Value (₹)'**
  String get sortHighestValue;

  /// No description provided for @commonShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get commonShowLess;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all ({count})'**
  String commonSeeAll(Object count);

  /// No description provided for @sortShortTodayGainers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Gainers'**
  String get sortShortTodayGainers;

  /// No description provided for @sortShortTodayLosers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Losers'**
  String get sortShortTodayLosers;

  /// No description provided for @sortShortGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers'**
  String get sortShortGainers;

  /// No description provided for @sortShortLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers'**
  String get sortShortLosers;

  /// No description provided for @sortShortValue.
  ///
  /// In en, this message translates to:
  /// **'Valuation'**
  String get sortShortValue;

  /// No description provided for @portfolioValuation.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO VALUATION'**
  String get portfolioValuation;

  /// No description provided for @metricInvested.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get metricInvested;

  /// No description provided for @metricHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get metricHoldings;

  /// No description provided for @metricPositions.
  ///
  /// In en, this message translates to:
  /// **'{count} Positions'**
  String metricPositions(Object count);

  /// No description provided for @metricWinRatio.
  ///
  /// In en, this message translates to:
  /// **'Win Ratio'**
  String get metricWinRatio;

  /// No description provided for @heatReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Heatmap'**
  String get heatReturnTitle;

  /// No description provided for @heatUpDown.
  ///
  /// In en, this message translates to:
  /// **'{up} Up • {down} Down'**
  String heatUpDown(Object up, Object down);

  /// No description provided for @heatOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get heatOverall;

  /// No description provided for @heatTodayPl.
  ///
  /// In en, this message translates to:
  /// **'Today\'s P&L'**
  String get heatTodayPl;

  /// No description provided for @heatGainersFirst.
  ///
  /// In en, this message translates to:
  /// **'Gainers first'**
  String get heatGainersFirst;

  /// No description provided for @heatLosersFirst.
  ///
  /// In en, this message translates to:
  /// **'Losers first'**
  String get heatLosersFirst;

  /// No description provided for @heatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No holdings to display'**
  String get heatEmpty;

  /// No description provided for @tradesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Trades could not be loaded'**
  String get tradesLoadFailed;

  /// No description provided for @tradesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trades yet'**
  String get tradesEmptyTitle;

  /// No description provided for @tradesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every trade you add, buy or sell will appear here by day.'**
  String get tradesEmptyBody;

  /// No description provided for @tradesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by stock (e.g. POLYCAB)'**
  String get tradesSearchHint;

  /// No description provided for @tradesCountDays.
  ///
  /// In en, this message translates to:
  /// **'{trades} trades · {days} days'**
  String tradesCountDays(Object trades, Object days);

  /// No description provided for @tradesNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No trade found with this name.'**
  String get tradesNoMatch;

  /// No description provided for @tradeOpeningHolding.
  ///
  /// In en, this message translates to:
  /// **'Opening holding'**
  String get tradeOpeningHolding;

  /// No description provided for @tradeBonusSplit.
  ///
  /// In en, this message translates to:
  /// **'Shares from bonus/split'**
  String get tradeBonusSplit;

  /// No description provided for @lastTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: last time'**
  String lastTimeTitle(Object symbol);

  /// No description provided for @lastTimeDates.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to} ({days} days)'**
  String lastTimeDates(Object from, Object to, Object days);

  /// No description provided for @lastTimeBought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get lastTimeBought;

  /// No description provided for @lastTimeSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get lastTimeSold;

  /// No description provided for @lastTimeRounds.
  ///
  /// In en, this message translates to:
  /// **'You have fully sold this stock {count} times; the figures above are for the latest one.'**
  String lastTimeRounds(Object count);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @addSelectStock.
  ///
  /// In en, this message translates to:
  /// **'Please search and select a stock symbol.'**
  String get addSelectStock;

  /// No description provided for @addValidQty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity greater than 0.'**
  String get addValidQty;

  /// No description provided for @addValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid average buy price.'**
  String get addValidPrice;

  /// No description provided for @addDone.
  ///
  /// In en, this message translates to:
  /// **'{symbol} added to portfolio successfully!'**
  String addDone(Object symbol);

  /// No description provided for @addMerged.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: {qty} shares added, average updated.'**
  String addMerged(Object symbol, Object qty);

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Stock Holding'**
  String get addTitle;

  /// No description provided for @addSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search any NSE/BSE stock to auto-fill details and start live AI tracking.'**
  String get addSubtitle;

  /// No description provided for @addSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Stock Symbol (e.g. RELIANCE, TITAN, INFY)'**
  String get addSearchHint;

  /// No description provided for @addCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get addCompanyName;

  /// No description provided for @addFetchingPrice.
  ///
  /// In en, this message translates to:
  /// **'Fetching live price...'**
  String get addFetchingPrice;

  /// No description provided for @addCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price: {price}'**
  String addCurrentPrice(Object price);

  /// No description provided for @addUseAsBuy.
  ///
  /// In en, this message translates to:
  /// **'[Use as Buy Price]'**
  String get addUseAsBuy;

  /// No description provided for @commonQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get commonQuantity;

  /// No description provided for @addAvgBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Avg Buy Price (₹)'**
  String get addAvgBuyPrice;

  /// No description provided for @commonBuyPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy Price (₹)'**
  String get commonBuyPrice;

  /// No description provided for @addToPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add to Portfolio'**
  String get addToPortfolio;

  /// No description provided for @addToPortfolioAvg.
  ///
  /// In en, this message translates to:
  /// **'Add to portfolio (update avg)'**
  String get addToPortfolioAvg;

  /// No description provided for @tradeQtyPositive.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be more than 0.'**
  String get tradeQtyPositive;

  /// No description provided for @tradePricePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be more than 0.'**
  String get tradePricePositive;

  /// No description provided for @tradeNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough shares: you have {have}, selling {selling}.'**
  String tradeNotEnough(Object have, Object selling);

  /// No description provided for @tradeSellSaved.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: sale of {qty} shares recorded.'**
  String tradeSellSaved(Object symbol, Object qty);

  /// No description provided for @tradeRemoveOpening.
  ///
  /// In en, this message translates to:
  /// **'Remove opening holding?'**
  String get tradeRemoveOpening;

  /// No description provided for @tradeRemoveThis.
  ///
  /// In en, this message translates to:
  /// **'Remove this trade?'**
  String get tradeRemoveThis;

  /// No description provided for @tradeRemoveOpeningBody.
  ///
  /// In en, this message translates to:
  /// **'This is your holding from before Trade entry: {qty} shares @ {price}. Removing it takes these {qty} shares out of the portfolio.\n\nIf you sold the shares, don\'t remove this; add a SELL trade.'**
  String tradeRemoveOpeningBody(Object qty, Object price);

  /// No description provided for @tradeRebuilt.
  ///
  /// In en, this message translates to:
  /// **'The holding will be rebuilt from the remaining trades.'**
  String get tradeRebuilt;

  /// No description provided for @tradeYesRemove.
  ///
  /// In en, this message translates to:
  /// **'Yes, remove'**
  String get tradeYesRemove;

  /// No description provided for @tradeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tradeRemove;

  /// No description provided for @tradeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: trade removed.'**
  String tradeRemoved(Object symbol);

  /// No description provided for @holdingRemoveBodyFinal.
  ///
  /// In en, this message translates to:
  /// **'{symbol} and all its trades will be removed from the portfolio. This cannot be undone.\n\nSold the shares? Then don\'t delete; add a SELL trade, so the trade history and the \"last time\" figures stay.'**
  String holdingRemoveBodyFinal(Object symbol);

  /// No description provided for @holdingRemovedFull.
  ///
  /// In en, this message translates to:
  /// **'{symbol} removed from portfolio.'**
  String holdingRemovedFull(Object symbol);

  /// No description provided for @tradeAddFor.
  ///
  /// In en, this message translates to:
  /// **'Add trade · {symbol}'**
  String tradeAddFor(Object symbol);

  /// No description provided for @editHolding.
  ///
  /// In en, this message translates to:
  /// **'Holding'**
  String get editHolding;

  /// No description provided for @editTotalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total Invested'**
  String get editTotalInvested;

  /// No description provided for @editRealized.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L (avg cost)'**
  String get editRealized;

  /// No description provided for @editLtp.
  ///
  /// In en, this message translates to:
  /// **'Current Market Price (LTP)'**
  String get editLtp;

  /// No description provided for @commonSellPrice.
  ///
  /// In en, this message translates to:
  /// **'Sell Price (₹)'**
  String get commonSellPrice;

  /// No description provided for @tradeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add trade'**
  String get tradeAdd;

  /// No description provided for @tradesHeading.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get tradesHeading;

  /// No description provided for @tradesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Trades could not be loaded: {error}'**
  String tradesLoadError(Object error);

  /// No description provided for @tradesNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No trades recorded yet. As soon as you add the first trade, your current holding becomes an \"Opening holding\" trade.'**
  String get tradesNoneYet;

  /// No description provided for @tradeRemoveTip.
  ///
  /// In en, this message translates to:
  /// **'Remove trade'**
  String get tradeRemoveTip;

  /// No description provided for @sellDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: {qty} shares sold'**
  String sellDoneTitle(Object symbol, Object qty);

  /// No description provided for @sellRealized.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L of this sale'**
  String get sellRealized;

  /// No description provided for @sellDetail.
  ///
  /// In en, this message translates to:
  /// **'Sold {qty} @ {price}; the average was {avg}.'**
  String sellDetail(Object qty, Object price, Object avg);

  /// No description provided for @sellAllGone.
  ///
  /// In en, this message translates to:
  /// **'All shares sold. {symbol} is now in Closed positions.'**
  String sellAllGone(Object symbol);

  /// No description provided for @sellRemaining.
  ///
  /// In en, this message translates to:
  /// **'Left: {left} shares @ {avg} (a sale does not change the average). Invested now {invested}.'**
  String sellRemaining(Object left, Object avg, Object invested);

  /// No description provided for @styleFunds.
  ///
  /// In en, this message translates to:
  /// **'ETF / funds {pct}'**
  String styleFunds(Object pct);

  /// No description provided for @styleLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss-making {pct}'**
  String styleLoss(Object pct);

  /// No description provided for @styleNoData.
  ///
  /// In en, this message translates to:
  /// **'No data {pct}'**
  String styleNoData(Object pct);

  /// No description provided for @styleTitle.
  ///
  /// In en, this message translates to:
  /// **'Investment style'**
  String get styleTitle;

  /// No description provided for @styleWhatTip.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get styleWhatTip;

  /// No description provided for @styleLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest share'**
  String get styleLargest;

  /// No description provided for @stylePctPortfolio.
  ///
  /// In en, this message translates to:
  /// **'{pct}% portfolio'**
  String stylePctPortfolio(Object pct);

  /// No description provided for @styleShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get styleShare;

  /// No description provided for @styleRankNote.
  ///
  /// In en, this message translates to:
  /// **'Growth and Value are ranks from 0 to 100, like a rank in class. 60 or above means strong on that side.'**
  String get styleRankNote;

  /// No description provided for @styleWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is Investment style?'**
  String get styleWhatTitle;

  /// No description provided for @styleWhatIntro.
  ///
  /// In en, this message translates to:
  /// **'This card is a mirror of your portfolio. It shows what kind of companies your money is in. It is not a suggestion to buy or sell.'**
  String get styleWhatIntro;

  /// No description provided for @styleSizeHead.
  ///
  /// In en, this message translates to:
  /// **'Company size'**
  String get styleSizeHead;

  /// No description provided for @styleLarge.
  ///
  /// In en, this message translates to:
  /// **'Large: the 100 biggest companies.'**
  String get styleLarge;

  /// No description provided for @styleMid.
  ///
  /// In en, this message translates to:
  /// **'Mid: the next 150 companies.'**
  String get styleMid;

  /// No description provided for @styleSmall.
  ///
  /// In en, this message translates to:
  /// **'Small: companies smaller than that.'**
  String get styleSmall;

  /// No description provided for @styleMicro.
  ///
  /// In en, this message translates to:
  /// **'Micro: companies under ₹1,000 crore.'**
  String get styleMicro;

  /// No description provided for @styleTypeHead.
  ///
  /// In en, this message translates to:
  /// **'Company type'**
  String get styleTypeHead;

  /// No description provided for @styleGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth: growing fast, but the share is not cheap.'**
  String get styleGrowth;

  /// No description provided for @styleValue.
  ///
  /// In en, this message translates to:
  /// **'Value: the share is cheap, but the company is not growing especially fast.'**
  String get styleValue;

  /// No description provided for @styleBoth.
  ///
  /// In en, this message translates to:
  /// **'Growth + Value: growing fast and cheap too. Such companies are rare.'**
  String get styleBoth;

  /// No description provided for @styleOthers.
  ///
  /// In en, this message translates to:
  /// **'Others: neither especially fast nor especially cheap.'**
  String get styleOthers;

  /// No description provided for @styleTableHead.
  ///
  /// In en, this message translates to:
  /// **'How to read the table'**
  String get styleTableHead;

  /// No description provided for @styleTableBody.
  ///
  /// In en, this message translates to:
  /// **'Each box shows how much of the portfolio is in that size and type. Say ₹100 is invested: 18.0% means ₹18.'**
  String get styleTableBody;

  /// No description provided for @styleTableBody2.
  ///
  /// In en, this message translates to:
  /// **'The box with a gold border is the largest share. The darker the colour, the bigger the share. Tap a box to see its stocks.'**
  String get styleTableBody2;

  /// No description provided for @styleHowHead.
  ///
  /// In en, this message translates to:
  /// **'How the type is decided'**
  String get styleHowHead;

  /// No description provided for @styleHow1.
  ///
  /// In en, this message translates to:
  /// **'Each company is compared with companies of its own size, like a rank in class.'**
  String get styleHow1;

  /// No description provided for @styleHow2.
  ///
  /// In en, this message translates to:
  /// **'Growth rank: how much sales and profit grew over the last 3 and 5 years.'**
  String get styleHow2;

  /// No description provided for @styleHow3.
  ///
  /// In en, this message translates to:
  /// **'Value rank: how cheap the share is by P/E, P/B and dividend.'**
  String get styleHow3;

  /// No description provided for @styleHow4.
  ///
  /// In en, this message translates to:
  /// **'A rank of 60 or above puts the company in that type.'**
  String get styleHow4;

  /// No description provided for @styleBelowHead.
  ///
  /// In en, this message translates to:
  /// **'The line below'**
  String get styleBelowHead;

  /// No description provided for @styleBelowBody.
  ///
  /// In en, this message translates to:
  /// **'ETFs and funds are not companies, and loss-making companies have no P/E. So they are listed separately, outside the table.'**
  String get styleBelowBody;

  /// No description provided for @styleNoteHead.
  ///
  /// In en, this message translates to:
  /// **'Keep in mind'**
  String get styleNoteHead;

  /// No description provided for @styleNoteBody.
  ///
  /// In en, this message translates to:
  /// **'The rank is against other companies, so the label can change over time.'**
  String get styleNoteBody;

  /// No description provided for @perfBackcast.
  ///
  /// In en, this message translates to:
  /// **'If today\'s holdings had been held the whole time. This is not your actual return.'**
  String get perfBackcast;

  /// No description provided for @perfFooter.
  ///
  /// In en, this message translates to:
  /// **'Price only, dividends not included. Data up to {date}.'**
  String perfFooter(Object date);

  /// No description provided for @perfPartial.
  ///
  /// In en, this message translates to:
  /// **'Some holdings lack full past data. The graph is built on the remaining holdings without them.'**
  String get perfPartial;

  /// No description provided for @movesToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get movesToday;

  /// No description provided for @movesLastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get movesLastSession;

  /// No description provided for @movesLegend.
  ///
  /// In en, this message translates to:
  /// **'Box size: share of the portfolio. Colour: that day\'s change.'**
  String get movesLegend;

  /// No description provided for @movesGainers.
  ///
  /// In en, this message translates to:
  /// **'Top gainers'**
  String get movesGainers;

  /// No description provided for @movesLosers.
  ///
  /// In en, this message translates to:
  /// **'Top losers'**
  String get movesLosers;

  /// No description provided for @tradeDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Trade date'**
  String get tradeDateHelp;

  /// No description provided for @tradeDate.
  ///
  /// In en, this message translates to:
  /// **'Trade date'**
  String get tradeDate;

  /// No description provided for @tradeZeroLeft.
  ///
  /// In en, this message translates to:
  /// **'0 shares (fully sold)'**
  String get tradeZeroLeft;

  /// No description provided for @tradeNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get tradeNow;

  /// No description provided for @tradeAfter.
  ///
  /// In en, this message translates to:
  /// **'After the trade'**
  String get tradeAfter;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **' {count} stocks failed; their holdings are unchanged:'**
  String importFailed(Object count);

  /// No description provided for @importDuplicates.
  ///
  /// In en, this message translates to:
  /// **' · {count} already imported (skipped)'**
  String importDuplicates(Object count);

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **' · {count} rows skipped (F&O / unreadable)'**
  String importSkipped(Object count);

  /// No description provided for @importStockLine.
  ///
  /// In en, this message translates to:
  /// **'{count} trades{skip}'**
  String importStockLine(Object count, Object skip);

  /// No description provided for @savedRemoved.
  ///
  /// In en, this message translates to:
  /// **'{symbol} removed from MY SAVED LIST'**
  String savedRemoved(Object symbol);

  /// No description provided for @savedAdded.
  ///
  /// In en, this message translates to:
  /// **'{symbol} saved to MY SAVED LIST at {price}'**
  String savedAdded(Object symbol, Object price);

  /// No description provided for @alertButtonCount.
  ///
  /// In en, this message translates to:
  /// **'Price alert · {count} set'**
  String alertButtonCount(Object count);

  /// No description provided for @alertButton.
  ///
  /// In en, this message translates to:
  /// **'Set price alert'**
  String get alertButton;

  /// No description provided for @stockPricePerformance.
  ///
  /// In en, this message translates to:
  /// **'Price Performance'**
  String get stockPricePerformance;

  /// No description provided for @stockChartSoon.
  ///
  /// In en, this message translates to:
  /// **'Historical Chart Coming Soon'**
  String get stockChartSoon;

  /// No description provided for @stockWatchlistAsset.
  ///
  /// In en, this message translates to:
  /// **'Watchlist Asset'**
  String get stockWatchlistAsset;

  /// No description provided for @stockNotOwned.
  ///
  /// In en, this message translates to:
  /// **'Not currently in your owned portfolio.'**
  String get stockNotOwned;

  /// No description provided for @stockScoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load AI Score'**
  String get stockScoreFailed;

  /// No description provided for @stockAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing {symbol} signals...'**
  String stockAnalyzing(Object symbol);

  /// No description provided for @stockScoring.
  ///
  /// In en, this message translates to:
  /// **'Scoring quality, valuation and price trend from the latest data.'**
  String get stockScoring;

  /// No description provided for @stockSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get stockSaved;

  /// No description provided for @stockSave.
  ///
  /// In en, this message translates to:
  /// **'+ Save'**
  String get stockSave;

  /// No description provided for @aiRulesBased.
  ///
  /// In en, this message translates to:
  /// **'Rules-based research score'**
  String get aiRulesBased;

  /// No description provided for @aiHowWorks.
  ///
  /// In en, this message translates to:
  /// **'How the NV Score works'**
  String get aiHowWorks;

  /// No description provided for @aiDataPending.
  ///
  /// In en, this message translates to:
  /// **'Data Pending'**
  String get aiDataPending;

  /// No description provided for @aiDataReview.
  ///
  /// In en, this message translates to:
  /// **'Data Under Review'**
  String get aiDataReview;

  /// No description provided for @aiExcluded.
  ///
  /// In en, this message translates to:
  /// **'Score Excluded'**
  String get aiExcluded;

  /// No description provided for @aiCreditPending.
  ///
  /// In en, this message translates to:
  /// **'Credit Pending'**
  String get aiCreditPending;

  /// No description provided for @aiBrokerLeverage.
  ///
  /// In en, this message translates to:
  /// **'Broker MTF Leverage'**
  String get aiBrokerLeverage;

  /// No description provided for @aiDebtNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'Debt Not Assessed'**
  String get aiDebtNotAssessed;

  /// No description provided for @aiWhyScore.
  ///
  /// In en, this message translates to:
  /// **'Why this score'**
  String get aiWhyScore;

  /// No description provided for @aiMethodology.
  ///
  /// In en, this message translates to:
  /// **'Methodology'**
  String get aiMethodology;

  /// No description provided for @aiNoScore.
  ///
  /// In en, this message translates to:
  /// **'No NV Score yet: {reason}. The score needs at least 3 of 4 quality inputs and is not built on assumed values.'**
  String aiNoScore(Object reason);

  /// No description provided for @aiReviewBody.
  ///
  /// In en, this message translates to:
  /// **'The source data for this stock did not match the exchange (market cap or price belong to a different company), so it is being reviewed. No score is shown rather than a score built on wrong numbers.'**
  String get aiReviewBody;

  /// No description provided for @aiInsurance.
  ///
  /// In en, this message translates to:
  /// **'Life and General Insurance firms operate on actuarial float and statutory accounting. Quantitative 1-100 scoring is withheld until dedicated Embedded Value (EV) models are integrated.'**
  String get aiInsurance;

  /// No description provided for @aiHolding.
  ///
  /// In en, this message translates to:
  /// **'Investment holding companies trade at variable net asset value (NAV) discounts. Standard operating multiples (P/E, ROCE) are not applicable; specialized SOTP research is recommended.'**
  String get aiHolding;

  /// No description provided for @aiReit.
  ///
  /// In en, this message translates to:
  /// **'Real Estate & Infrastructure Investment Trusts operate on distribution yield and Net Asset Value (NAV). Standard industrial scoring is withheld.'**
  String get aiReit;

  /// No description provided for @aiSpecialised.
  ///
  /// In en, this message translates to:
  /// **'The 1-100 score is not calculated for this stock: its accounts need a specialised valuation method.'**
  String get aiSpecialised;

  /// No description provided for @aiScoreOnly.
  ///
  /// In en, this message translates to:
  /// **'NV Score {score}/100. The pillar breakdown appears after the next score update.'**
  String aiScoreOnly(Object score);

  /// No description provided for @aiHighest.
  ///
  /// In en, this message translates to:
  /// **'NV Score {score}/100. Highest: {pillar}'**
  String aiHighest(Object score, Object pillar);

  /// No description provided for @aiLowest.
  ///
  /// In en, this message translates to:
  /// **'; lowest: {pillar}'**
  String aiLowest(Object pillar);

  /// No description provided for @aiRiskCap.
  ///
  /// In en, this message translates to:
  /// **' A risk check failed, which caps the score at {cap}.'**
  String aiRiskCap(Object cap);

  /// No description provided for @aiHurdle.
  ///
  /// In en, this message translates to:
  /// **' Quality is below 55, so the score is scaled down.'**
  String get aiHurdle;

  /// No description provided for @companyOverview.
  ///
  /// In en, this message translates to:
  /// **'Company Overview'**
  String get companyOverview;

  /// No description provided for @companyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabel;

  /// No description provided for @companyIndustry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get companyIndustry;

  /// No description provided for @companyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get companyStatus;

  /// No description provided for @holdingDetails.
  ///
  /// In en, this message translates to:
  /// **'Holding Details'**
  String get holdingDetails;

  /// No description provided for @holdingAvgPrice.
  ///
  /// In en, this message translates to:
  /// **'Average Price'**
  String get holdingAvgPrice;

  /// No description provided for @holdingCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get holdingCurrentPrice;

  /// No description provided for @holdingInvested.
  ///
  /// In en, this message translates to:
  /// **'Invested Value'**
  String get holdingInvested;

  /// No description provided for @holdingCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get holdingCurrentValue;

  /// No description provided for @holdingNetPl.
  ///
  /// In en, this message translates to:
  /// **'Net P&L'**
  String get holdingNetPl;

  /// No description provided for @holdingReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get holdingReturn;

  /// No description provided for @holdingDayPl.
  ///
  /// In en, this message translates to:
  /// **'Day\'s P&L'**
  String get holdingDayPl;

  /// No description provided for @thesisTitle.
  ///
  /// In en, this message translates to:
  /// **'Investment Thesis'**
  String get thesisTitle;

  /// No description provided for @thesisNone.
  ///
  /// In en, this message translates to:
  /// **'No investment thesis available for this stock yet.'**
  String get thesisNone;

  /// No description provided for @thesisReview.
  ///
  /// In en, this message translates to:
  /// **'Review this thesis after every quarterly result.'**
  String get thesisReview;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get newsTitle;

  /// No description provided for @newsSub.
  ///
  /// In en, this message translates to:
  /// **'AI curated market updates'**
  String get newsSub;

  /// No description provided for @newsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No News Available'**
  String get newsEmptyTitle;

  /// No description provided for @newsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Latest company news and market updates will automatically appear here when available.'**
  String get newsEmptyBody;

  /// No description provided for @newsAutoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto Refresh'**
  String get newsAutoRefresh;

  /// No description provided for @peersTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with peers'**
  String get peersTitle;

  /// No description provided for @peersAdd.
  ///
  /// In en, this message translates to:
  /// **'Add another peer'**
  String get peersAdd;

  /// No description provided for @peersChange.
  ///
  /// In en, this message translates to:
  /// **'Change peer'**
  String get peersChange;

  /// No description provided for @peersDashNote.
  ///
  /// In en, this message translates to:
  /// **'— means no data. A loss-making company has no P/E.'**
  String get peersDashNote;

  /// No description provided for @alertRemoveTip.
  ///
  /// In en, this message translates to:
  /// **'Remove alert'**
  String get alertRemoveTip;

  /// No description provided for @alertRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the alert. Please try again.'**
  String get alertRemoveFailed;

  /// No description provided for @alertDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This alert is already set'**
  String get alertDuplicate;

  /// No description provided for @alertMax.
  ///
  /// In en, this message translates to:
  /// **'You can have up to {max} alerts at once'**
  String alertMax(Object max);

  /// No description provided for @alertSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the alert. Please try again.'**
  String get alertSaveFailed;

  /// No description provided for @alertTitle.
  ///
  /// In en, this message translates to:
  /// **'Price alert · {symbol}'**
  String alertTitle(Object symbol);

  /// No description provided for @alertCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current price {price}'**
  String alertCurrent(Object price);

  /// No description provided for @alertAbove.
  ///
  /// In en, this message translates to:
  /// **'Goes above'**
  String get alertAbove;

  /// No description provided for @alertBelow.
  ///
  /// In en, this message translates to:
  /// **'Falls below'**
  String get alertBelow;

  /// No description provided for @alertPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Price (₹)'**
  String get alertPriceHint;

  /// No description provided for @alertSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get alertSaving;

  /// No description provided for @alertSet.
  ///
  /// In en, this message translates to:
  /// **'Set alert'**
  String get alertSet;

  /// No description provided for @alertNote.
  ///
  /// In en, this message translates to:
  /// **'During market hours the price is checked every 5 minutes. When it reaches your price, it shows in Notifications. All alerts: Notifications > My price alerts.'**
  String get alertNote;

  /// No description provided for @alertsMine.
  ///
  /// In en, this message translates to:
  /// **'My price alerts'**
  String get alertsMine;

  /// No description provided for @alertsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Alerts could not be loaded'**
  String get alertsLoadFailed;

  /// No description provided for @alertsNone.
  ///
  /// In en, this message translates to:
  /// **'No active alerts. Set one from any stock\'s page.'**
  String get alertsNone;

  /// No description provided for @recSummary.
  ///
  /// In en, this message translates to:
  /// **'DATA SUMMARY'**
  String get recSummary;

  /// No description provided for @recPlaybook.
  ///
  /// In en, this message translates to:
  /// **'Tactical Playbook'**
  String get recPlaybook;

  /// No description provided for @recHeld.
  ///
  /// In en, this message translates to:
  /// **'HELD IN PORTFOLIO'**
  String get recHeld;

  /// No description provided for @recDiscovery.
  ///
  /// In en, this message translates to:
  /// **'DISCOVERY MODE'**
  String get recDiscovery;

  /// No description provided for @recShows.
  ///
  /// In en, this message translates to:
  /// **'What the data shows'**
  String get recShows;

  /// No description provided for @recWatch.
  ///
  /// In en, this message translates to:
  /// **'Number to watch'**
  String get recWatch;

  /// No description provided for @recUpdates.
  ///
  /// In en, this message translates to:
  /// **'What updates the score'**
  String get recUpdates;

  /// No description provided for @recCoverage.
  ///
  /// In en, this message translates to:
  /// **'Data coverage: {pct}% • Synthesized from 6 quantitative pillars'**
  String recCoverage(Object pct);

  /// No description provided for @breakdownPending.
  ///
  /// In en, this message translates to:
  /// **'The breakdown appears after the next score update.'**
  String get breakdownPending;

  /// No description provided for @breakdownNone.
  ///
  /// In en, this message translates to:
  /// **'No score for this stock, so there is no breakdown.'**
  String get breakdownNone;

  /// No description provided for @breakdownNotCounted.
  ///
  /// In en, this message translates to:
  /// **'not counted'**
  String get breakdownNotCounted;

  /// No description provided for @breakdownWeight.
  ///
  /// In en, this message translates to:
  /// **'{pct}% weight'**
  String breakdownWeight(Object pct);

  /// No description provided for @breakdownRiskFlag.
  ///
  /// In en, this message translates to:
  /// **'Risk flag'**
  String get breakdownRiskFlag;

  /// No description provided for @breakdownRiskCap.
  ///
  /// In en, this message translates to:
  /// **'Score capped at {cap} (pledge, net worth or debt check failed)'**
  String breakdownRiskCap(Object cap);

  /// No description provided for @breakdownHurdle.
  ///
  /// In en, this message translates to:
  /// **'Quality hurdle'**
  String get breakdownHurdle;

  /// No description provided for @breakdownHurdleBody.
  ///
  /// In en, this message translates to:
  /// **'× {hurdle} (quality below 55)'**
  String breakdownHurdleBody(Object hurdle);

  /// No description provided for @breakdownQualityCap.
  ///
  /// In en, this message translates to:
  /// **'Quality cap'**
  String get breakdownQualityCap;

  /// No description provided for @breakdownQualityCapBody.
  ///
  /// In en, this message translates to:
  /// **'Capped at {cap} (54 below quality 55, rising to no cap at 65)'**
  String breakdownQualityCapBody(Object cap);

  /// No description provided for @breakdownLenderCap.
  ///
  /// In en, this message translates to:
  /// **'Lender / broker cap'**
  String get breakdownLenderCap;

  /// No description provided for @breakdownLenderCapBody.
  ///
  /// In en, this message translates to:
  /// **'Capped at {cap} until credit data is added'**
  String breakdownLenderCapBody(Object cap);

  /// No description provided for @breakdownNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get breakdownNote;

  /// No description provided for @shareDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Image downloaded.'**
  String get shareDownloaded;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share. Please try again.'**
  String get shareFailed;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @stockSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get stockSyncing;

  /// No description provided for @stockAllTime.
  ///
  /// In en, this message translates to:
  /// **'All-Time: {amount}   ({pct})'**
  String stockAllTime(Object amount, Object pct);

  /// No description provided for @stockToday.
  ///
  /// In en, this message translates to:
  /// **'Today: {amount}   ({pct})'**
  String stockToday(Object amount, Object pct);

  /// No description provided for @stockExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get stockExchange;

  /// No description provided for @stockTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get stockTrend;

  /// No description provided for @chartUpdating.
  ///
  /// In en, this message translates to:
  /// **'Chart updating...'**
  String get chartUpdating;

  /// No description provided for @radarTitle.
  ///
  /// In en, this message translates to:
  /// **'Score shape'**
  String get radarTitle;

  /// No description provided for @radarNoteLeverage.
  ///
  /// In en, this message translates to:
  /// **'Each score is 0–100, higher toward the outside. In Leverage a higher score means less leverage.'**
  String get radarNoteLeverage;

  /// No description provided for @radarNoteDebt.
  ///
  /// In en, this message translates to:
  /// **'Each score is 0–100, higher toward the outside. In Debt a higher score means less debt.'**
  String get radarNoteDebt;

  /// No description provided for @breakdownHintQuality.
  ///
  /// In en, this message translates to:
  /// **'Return on capital, debt, cash conversion and 5-year growth'**
  String get breakdownHintQuality;

  /// No description provided for @breakdownHintValuation.
  ///
  /// In en, this message translates to:
  /// **'P/E vs sector peers and earnings yield'**
  String get breakdownHintValuation;

  /// No description provided for @breakdownHintMomentum.
  ///
  /// In en, this message translates to:
  /// **'12-month return, latest month left out, ranked against all stocks'**
  String get breakdownHintMomentum;

  /// No description provided for @shareDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'For information only. This is not investment advice.'**
  String get shareDisclaimer;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & Watchlist'**
  String get searchTitle;

  /// No description provided for @searchTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} Tracked'**
  String searchTracked(Object count);

  /// No description provided for @searchSub.
  ///
  /// In en, this message translates to:
  /// **'Prices, NV Scores and watchlist tracking.'**
  String get searchSub;

  /// No description provided for @searchExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Stocks'**
  String get searchExplore;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search stock by symbol or name (e.g. TAT, KEI, APO)...'**
  String get searchHint;

  /// No description provided for @searchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Searching market universe'**
  String get searchingTitle;

  /// No description provided for @searchingBody.
  ///
  /// In en, this message translates to:
  /// **'Matching symbols and AI scores.'**
  String get searchingBody;

  /// No description provided for @searchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search unavailable'**
  String get searchUnavailable;

  /// No description provided for @searchStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a symbol'**
  String get searchStartTitle;

  /// No description provided for @searchStartBody.
  ///
  /// In en, this message translates to:
  /// **'Search any stock to see its NV Score.'**
  String get searchStartBody;

  /// No description provided for @searchNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No stock found'**
  String get searchNoneTitle;

  /// No description provided for @searchNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Try another instrument or company name.'**
  String get searchNoneBody;

  /// No description provided for @watchRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from Watchlist'**
  String get watchRemove;

  /// No description provided for @watchAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to Watchlist'**
  String get watchAdd;

  /// No description provided for @watchSavedAt.
  ///
  /// In en, this message translates to:
  /// **'{symbol} saved at {price}'**
  String watchSavedAt(Object symbol, Object price);

  /// No description provided for @watchAdded.
  ///
  /// In en, this message translates to:
  /// **'{symbol} added to watchlist'**
  String watchAdded(Object symbol);

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @watchRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove from Watchlist?'**
  String get watchRemoveConfirm;

  /// No description provided for @watchRemoveBodyPrice.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} ({symbol})? Your tracked entry price ({price}) will be cleared.'**
  String watchRemoveBodyPrice(Object name, Object symbol, Object price);

  /// No description provided for @watchRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} ({symbol}) from your watchlist?'**
  String watchRemoveBody(Object name, Object symbol);

  /// No description provided for @watchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stocks in watchlist'**
  String get watchEmptyTitle;

  /// No description provided for @watchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Search any stock and tap \"+ Save\" to track it here.\nPull down to sync and refresh.'**
  String get watchEmptyBody;

  /// No description provided for @watchColCompany.
  ///
  /// In en, this message translates to:
  /// **'Company ⬍'**
  String get watchColCompany;

  /// No description provided for @watchColScore.
  ///
  /// In en, this message translates to:
  /// **'Score ⬍'**
  String get watchColScore;

  /// No description provided for @watchColAdded.
  ///
  /// In en, this message translates to:
  /// **'Added Price'**
  String get watchColAdded;

  /// No description provided for @watchColLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest Price ⬍\nChange'**
  String get watchColLatest;

  /// No description provided for @watchColReturns.
  ///
  /// In en, this message translates to:
  /// **'Returns ⬍\nTracked Date'**
  String get watchColReturns;

  /// No description provided for @watchColTech.
  ///
  /// In en, this message translates to:
  /// **'Technical & Things you should know'**
  String get watchColTech;

  /// No description provided for @watchColAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get watchColAction;

  /// No description provided for @watchEntry.
  ///
  /// In en, this message translates to:
  /// **'Entry Point'**
  String get watchEntry;

  /// No description provided for @notifMarkAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifMarkAll;

  /// No description provided for @notifMarked.
  ///
  /// In en, this message translates to:
  /// **'All alerts marked as read.'**
  String get notifMarked;

  /// No description provided for @notifFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications:\n{error}'**
  String notifFailed(Object error);

  /// No description provided for @notifActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String notifActive(Object count);

  /// No description provided for @notifJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifJustNow;

  /// No description provided for @notifMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String notifMinutes(Object n);

  /// No description provided for @notifHours.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String notifHours(Object n);

  /// No description provided for @notifDays.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String notifDays(Object n);

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Alerts in this Category'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is stable and within risk limits.'**
  String get notifEmptyBody;

  /// No description provided for @advBusy.
  ///
  /// In en, this message translates to:
  /// **'NV Advisor is busy or there is a connection issue. Please ask again in a little while.'**
  String get advBusy;

  /// No description provided for @advNoReply.
  ///
  /// In en, this message translates to:
  /// **'No reply yet'**
  String get advNoReply;

  /// No description provided for @advHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s History'**
  String get advHistoryTitle;

  /// No description provided for @advQueries.
  ///
  /// In en, this message translates to:
  /// **'{count} Queries'**
  String advQueries(Object count);

  /// No description provided for @advNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No conversation yet today.'**
  String get advNoHistory;

  /// No description provided for @advSub.
  ///
  /// In en, this message translates to:
  /// **'Research assistant for your holdings'**
  String get advSub;

  /// No description provided for @advClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get advClear;

  /// No description provided for @advReset.
  ///
  /// In en, this message translates to:
  /// **'Chat reset. You can ask me anything about your portfolio!'**
  String get advReset;

  /// No description provided for @advAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'NV Advisor analyzing...'**
  String get advAnalyzing;

  /// No description provided for @advHint.
  ///
  /// In en, this message translates to:
  /// **'Ask NV Advisor anything about your portfolio...'**
  String get advHint;

  /// No description provided for @riskLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Portfolio could not be loaded'**
  String get riskLoadFailed;

  /// No description provided for @riskNoStocks.
  ///
  /// In en, this message translates to:
  /// **'No stocks in the portfolio'**
  String get riskNoStocks;

  /// No description provided for @riskDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an estimate from the past 1 year\'s beta, not a prediction. The actual fall can differ. No trade happens here, and this is not investment advice.'**
  String get riskDisclaimer;

  /// No description provided for @riskBetaNote.
  ///
  /// In en, this message translates to:
  /// **'1.00 means it moves as much as Nifty. Above 1 means more.'**
  String get riskBetaNote;

  /// No description provided for @riskNoBeta.
  ///
  /// In en, this message translates to:
  /// **'{stocks} have no beta. Built on {pct} of the portfolio.'**
  String riskNoBeta(Object stocks, Object pct);

  /// No description provided for @riskPeExcluded.
  ///
  /// In en, this message translates to:
  /// **'{stocks} not in P/E (loss-making or ETF). P/E is built on {pct} of the portfolio.'**
  String riskPeExcluded(Object stocks, Object pct);

  /// No description provided for @riskIfFalls.
  ///
  /// In en, this message translates to:
  /// **'If the market falls'**
  String get riskIfFalls;

  /// No description provided for @riskBetaNa.
  ///
  /// In en, this message translates to:
  /// **'Beta is not available right now, so this cannot be worked out.'**
  String get riskBetaNa;

  /// No description provided for @riskEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated change {amount}'**
  String riskEstimated(Object amount);

  /// No description provided for @riskNotCounted.
  ///
  /// In en, this message translates to:
  /// **'{stocks} not counted, as they have no beta.'**
  String riskNotCounted(Object stocks);

  /// No description provided for @riskMostImpact.
  ///
  /// In en, this message translates to:
  /// **'Biggest effect'**
  String get riskMostImpact;

  /// No description provided for @riskStockShare.
  ///
  /// In en, this message translates to:
  /// **'{name} share'**
  String riskStockShare(Object name);

  /// No description provided for @riskStockNoBeta.
  ///
  /// In en, this message translates to:
  /// **'This stock has no beta, so it is not counted in portfolio beta.'**
  String get riskStockNoBeta;

  /// No description provided for @riskIfChange.
  ///
  /// In en, this message translates to:
  /// **'If this stock changes'**
  String get riskIfChange;

  /// No description provided for @riskStockField.
  ///
  /// In en, this message translates to:
  /// **'Stock name or symbol'**
  String get riskStockField;

  /// No description provided for @riskYouHold.
  ///
  /// In en, this message translates to:
  /// **'You hold'**
  String get riskYouHold;

  /// No description provided for @riskAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get riskAdd;

  /// No description provided for @riskReduce.
  ///
  /// In en, this message translates to:
  /// **'Reduce'**
  String get riskReduce;

  /// No description provided for @riskAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get riskAmount;

  /// No description provided for @riskWarnStock.
  ///
  /// In en, this message translates to:
  /// **'{symbol} would be {pct}% of the portfolio, above the {limit}% line.'**
  String riskWarnStock(Object symbol, Object pct, Object limit);

  /// No description provided for @alertEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get alertEnterPrice;

  /// No description provided for @alertMustAbove.
  ///
  /// In en, this message translates to:
  /// **'The price must be above the current price'**
  String get alertMustAbove;

  /// No description provided for @alertMustBelow.
  ///
  /// In en, this message translates to:
  /// **'The price must be below the current price'**
  String get alertMustBelow;

  /// No description provided for @caTitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol}: {label} announced'**
  String caTitle(Object symbol, Object label);

  /// No description provided for @caBody.
  ///
  /// In en, this message translates to:
  /// **'You held {before} shares that day, so {extra} new shares (at ₹0) will be added.'**
  String caBody(Object before, Object extra);

  /// No description provided for @caNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {qty} shares @ {avg}'**
  String caNow(Object qty, Object avg);

  /// No description provided for @caAfter.
  ///
  /// In en, this message translates to:
  /// **'After update: {qty} shares @ {avg}'**
  String caAfter(Object qty, Object avg);

  /// No description provided for @caInvested.
  ///
  /// In en, this message translates to:
  /// **'Invested stays the same: {amount}'**
  String caInvested(Object amount);

  /// No description provided for @caFraction.
  ///
  /// In en, this message translates to:
  /// **'Fractional shares not added: the broker pays cash for them.'**
  String get caFraction;

  /// No description provided for @caMatch.
  ///
  /// In en, this message translates to:
  /// **'Match the share count with your broker app. If it is wrong, you can remove it later from Trade book.'**
  String get caMatch;

  /// No description provided for @caLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get caLater;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @caYesAdd.
  ///
  /// In en, this message translates to:
  /// **'Yes, add'**
  String get caYesAdd;

  /// No description provided for @cardLtp.
  ///
  /// In en, this message translates to:
  /// **'LTP: {price}'**
  String cardLtp(Object price);

  /// No description provided for @alertWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight Alert: {symbol}'**
  String alertWeightTitle(Object symbol);

  /// No description provided for @alertWeightBody.
  ///
  /// In en, this message translates to:
  /// **'{symbol} accounts for {pct}% of your portfolio value, above the 25% concentration line.'**
  String alertWeightBody(Object symbol, Object pct);

  /// No description provided for @alertChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio checks on'**
  String get alertChecksTitle;

  /// No description provided for @alertChecksBody.
  ///
  /// In en, this message translates to:
  /// **'Concentration is checked across your {count} holdings each time alerts load.'**
  String alertChecksBody(Object count);

  /// No description provided for @alertWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Add your holdings in Portfolio to enable automated algorithmic risk monitoring and technical pivot tracking.'**
  String get alertWelcomeBody;

  /// No description provided for @errNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and tap Try Again.'**
  String get errNoInternet;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading. Please try again in a moment.'**
  String get errGeneric;

  /// No description provided for @importNotZerodha.
  ///
  /// In en, this message translates to:
  /// **'This does not look like a Zerodha tradebook: the symbol, trade_date, trade_type, quantity, price and trade_id columns were not found.'**
  String get importNotZerodha;

  /// No description provided for @advGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste! I am **NV Advisor**\n\nI am your research assistant. I explain the numbers of your portfolio holdings, P&L, NV Scores, **Peer Comparisons** and **Risk Checks**; I do not give advice to buy or sell.\n\nYou can ask me any portfolio or stock question!'**
  String get advGreeting;

  /// No description provided for @advAsk1.
  ///
  /// In en, this message translates to:
  /// **'Show my portfolio\'s 3 biggest mistakes and risks'**
  String get advAsk1;

  /// No description provided for @advAsk2.
  ///
  /// In en, this message translates to:
  /// **'Tata Motors vs Maruti: which has better growth?'**
  String get advAsk2;

  /// No description provided for @advAsk3.
  ///
  /// In en, this message translates to:
  /// **'Titan vs Trent comparison'**
  String get advAsk3;

  /// No description provided for @advAsk4.
  ///
  /// In en, this message translates to:
  /// **'What are UltraTech\'s price and NV Score?'**
  String get advAsk4;

  /// No description provided for @advAsk5.
  ///
  /// In en, this message translates to:
  /// **'How is my portfolio performing?'**
  String get advAsk5;

  /// No description provided for @advAsk6.
  ///
  /// In en, this message translates to:
  /// **'What is the trend of Nifty 50 and the market?'**
  String get advAsk6;

  /// No description provided for @caExDate.
  ///
  /// In en, this message translates to:
  /// **'Ex-date {date}: each 1 share is now {multiple} shares. '**
  String caExDate(Object date, Object multiple);

  /// No description provided for @narrEtf.
  ///
  /// In en, this message translates to:
  /// **'Exchange-Traded Fund'**
  String get narrEtf;

  /// No description provided for @narrEtfBrief.
  ///
  /// In en, this message translates to:
  /// **'{name} is an exchange-traded fund that tracks {sector}. Its price follows the underlying basket, so company-level ratios such as ROCE do not apply; the NV Score gives it a fixed quality of 75 and valuation of 60 and scores only its 12-month return rank.'**
  String narrEtfBrief(Object name, Object sector);

  /// No description provided for @narrEtfBasket.
  ///
  /// In en, this message translates to:
  /// **'Diversified basket'**
  String get narrEtfBasket;

  /// No description provided for @narrEtfBasketBody.
  ///
  /// In en, this message translates to:
  /// **'Holds many securities (or a commodity), so the results of one company move it less than a single stock.'**
  String get narrEtfBasketBody;

  /// No description provided for @narrEtfBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Moves with its benchmark'**
  String get narrEtfBenchmark;

  /// No description provided for @narrEtfBenchmarkBody.
  ///
  /// In en, this message translates to:
  /// **'Returns follow the index or commodity it tracks, including its falls.'**
  String get narrEtfBenchmarkBody;

  /// No description provided for @narrEtfOwned.
  ///
  /// In en, this message translates to:
  /// **'In your portfolio. NV Score {score}/100, set mostly by its 12-month return rank.'**
  String narrEtfOwned(Object score);

  /// No description provided for @narrEtfNotOwned.
  ///
  /// In en, this message translates to:
  /// **'NV Score {score}/100, set mostly by its 12-month return rank.'**
  String narrEtfNotOwned(Object score);

  /// No description provided for @narrEtfWatch.
  ///
  /// In en, this message translates to:
  /// **'Tracking difference against its benchmark and the expense ratio (from the fund house factsheet).'**
  String get narrEtfWatch;

  /// No description provided for @narrEtfUpdates.
  ///
  /// In en, this message translates to:
  /// **'Daily closing prices update the 12-month return rank.'**
  String get narrEtfUpdates;

  /// No description provided for @narrNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough quality data yet'**
  String get narrNotEnough;

  /// No description provided for @narrPendingBrief.
  ///
  /// In en, this message translates to:
  /// **'No NV Score for {name} yet: {why}. A score built on too few inputs would be misleading, so none is shown.'**
  String narrPendingBrief(Object name, Object why);

  /// No description provided for @narrMissing.
  ///
  /// In en, this message translates to:
  /// **'What is missing'**
  String get narrMissing;

  /// No description provided for @narrMissingBody.
  ///
  /// In en, this message translates to:
  /// **'{why}. The score needs at least 3 of 4 quality inputs (return on capital, debt, cash conversion, growth).'**
  String narrMissingBody(Object why);

  /// No description provided for @narrScorePending.
  ///
  /// In en, this message translates to:
  /// **'Score: Pending'**
  String get narrScorePending;

  /// No description provided for @narrWhyNoScore.
  ///
  /// In en, this message translates to:
  /// **'Why no score'**
  String get narrWhyNoScore;

  /// No description provided for @narrNoAssumed.
  ///
  /// In en, this message translates to:
  /// **'Missing inputs are not filled with assumed values.'**
  String get narrNoAssumed;

  /// No description provided for @narrInputsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Inputs: Incomplete'**
  String get narrInputsIncomplete;

  /// No description provided for @narrPendingOwned.
  ///
  /// In en, this message translates to:
  /// **'Currently in your portfolio. Your holding, price and P&L are unaffected; only the NV Score is pending.'**
  String get narrPendingOwned;

  /// No description provided for @narrPendingNotOwned.
  ///
  /// In en, this message translates to:
  /// **'Only the NV Score is pending; the live price is unaffected.'**
  String get narrPendingNotOwned;

  /// No description provided for @narrPendingWatch.
  ///
  /// In en, this message translates to:
  /// **'The next annual results of the company, which usually fill the missing inputs.'**
  String get narrPendingWatch;

  /// No description provided for @narrPendingUpdates.
  ///
  /// In en, this message translates to:
  /// **'The score appears automatically once enough data is available.'**
  String get narrPendingUpdates;

  /// No description provided for @narrReviewBrief.
  ///
  /// In en, this message translates to:
  /// **'The fundamentals we hold for {name} did not match exchange data: the market cap or price belongs to a different company. The score is withheld until the data is corrected.'**
  String narrReviewBrief(Object name);

  /// No description provided for @narrChecked.
  ///
  /// In en, this message translates to:
  /// **'What we checked'**
  String get narrChecked;

  /// No description provided for @narrCheckedBody.
  ///
  /// In en, this message translates to:
  /// **'Stored market cap and price were compared with the NSE closing price and an independent market-cap source.'**
  String get narrCheckedBody;

  /// No description provided for @narrCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Check: Failed'**
  String get narrCheckFailed;

  /// No description provided for @narrWrongNumbers.
  ///
  /// In en, this message translates to:
  /// **'A score built on another company\'s numbers would be misleading, so none is shown.'**
  String get narrWrongNumbers;

  /// No description provided for @narrScoreWithheld.
  ///
  /// In en, this message translates to:
  /// **'Score: Withheld'**
  String get narrScoreWithheld;

  /// No description provided for @narrReviewOwned.
  ///
  /// In en, this message translates to:
  /// **'Currently in your portfolio. Your holding, price and P&L are unaffected; only the NV Score is withheld.'**
  String get narrReviewOwned;

  /// No description provided for @narrReviewNotOwned.
  ///
  /// In en, this message translates to:
  /// **'Only the NV Score is withheld; the live price is unaffected.'**
  String get narrReviewNotOwned;

  /// No description provided for @narrReviewWatch.
  ///
  /// In en, this message translates to:
  /// **'Check the company\'s latest results on the NSE / BSE website until the data is corrected.'**
  String get narrReviewWatch;

  /// No description provided for @narrReviewUpdates.
  ///
  /// In en, this message translates to:
  /// **'The score returns automatically once the data passes the check.'**
  String get narrReviewUpdates;

  /// No description provided for @narrHoldingTag.
  ///
  /// In en, this message translates to:
  /// **'Investment Holding Company (SOTP Required)'**
  String get narrHoldingTag;

  /// No description provided for @narrInsuranceTag.
  ///
  /// In en, this message translates to:
  /// **'Actuarial Underwriting Entity (EV Model Required)'**
  String get narrInsuranceTag;

  /// No description provided for @narrTrustTag.
  ///
  /// In en, this message translates to:
  /// **'Yield Distribution Trust (NAV Required)'**
  String get narrTrustTag;

  /// No description provided for @narrSpecialTag.
  ///
  /// In en, this message translates to:
  /// **'Specialized Asset Class (Score Excluded)'**
  String get narrSpecialTag;

  /// No description provided for @narrHoldingBrief.
  ///
  /// In en, this message translates to:
  /// **'{name} functions as an equity investment holding company. Standard operating ROCE and P/E ratios are mathematically distorted by holding company discounts and non-operating dividend income. Valuation must be assessed via Sum-of-the-Parts (SOTP) net asset value.'**
  String narrHoldingBrief(Object name);

  /// No description provided for @narrInsuranceBrief.
  ///
  /// In en, this message translates to:
  /// **'{name} operates an actuarial insurance underwriting portfolio. Statutory accounting and premium float dynamics make industrial ROCE metrics non-applicable; valuation is driven by Value of New Business (VNB) margins and Embedded Value (EV).'**
  String narrInsuranceBrief(Object name);

  /// No description provided for @narrTrustBrief.
  ///
  /// In en, this message translates to:
  /// **'{name} is a structured trust vehicle distributing rental/infrastructure cash flows. Standard industrial scoring is withheld in favor of Net Asset Value (NAV) and distribution yield.'**
  String narrTrustBrief(Object name);

  /// No description provided for @narrHoldingNav.
  ///
  /// In en, this message translates to:
  /// **'Underlying Portfolio Holdings NAV'**
  String get narrHoldingNav;

  /// No description provided for @narrFloat.
  ///
  /// In en, this message translates to:
  /// **'Float Compounding & VNB Expansion'**
  String get narrFloat;

  /// No description provided for @narrDistribution.
  ///
  /// In en, this message translates to:
  /// **'Predictable Distribution Yield'**
  String get narrDistribution;

  /// No description provided for @narrHoldingNavBody.
  ///
  /// In en, this message translates to:
  /// **'Value realization is linked to the market capitalization growth of listed subsidiaries and unlisted associates.'**
  String get narrHoldingNavBody;

  /// No description provided for @narrFloatBody.
  ///
  /// In en, this message translates to:
  /// **'Long-duration customer float and growing policyholder retention fuel actuarial book value expansion.'**
  String get narrFloatBody;

  /// No description provided for @narrDistributionBody.
  ///
  /// In en, this message translates to:
  /// **'High dividend payout mandates and pass-through tax structures provide tangible cash distribution.'**
  String get narrDistributionBody;

  /// No description provided for @narrCoverage.
  ///
  /// In en, this message translates to:
  /// **'Coverage: Specialized'**
  String get narrCoverage;

  /// No description provided for @narrDiscount.
  ///
  /// In en, this message translates to:
  /// **'Holding Company Discount Persistence'**
  String get narrDiscount;

  /// No description provided for @narrClaims.
  ///
  /// In en, this message translates to:
  /// **'Actuarial Claims / Surrender Risk'**
  String get narrClaims;

  /// No description provided for @narrRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate Sensitivity'**
  String get narrRate;

  /// No description provided for @narrDiscountBody.
  ///
  /// In en, this message translates to:
  /// **'Holding company share prices often trade below the value of their underlying holdings; the gap varies by company and over time.'**
  String get narrDiscountBody;

  /// No description provided for @narrClaimsBody.
  ///
  /// In en, this message translates to:
  /// **'Regulatory commission caps and sudden mortality/morbidity claims spikes can pressure quarterly margins.'**
  String get narrClaimsBody;

  /// No description provided for @narrRateBody.
  ///
  /// In en, this message translates to:
  /// **'Rising benchmark yields increase the discount rate and compress trust capital value.'**
  String get narrRateBody;

  /// No description provided for @narrRiskSpecial.
  ///
  /// In en, this message translates to:
  /// **'Risk: Specialized'**
  String get narrRiskSpecial;

  /// No description provided for @narrSpecialOwned.
  ///
  /// In en, this message translates to:
  /// **'Currently in your portfolio. The 1-100 score is not calculated for this category; review it on the metrics listed below.'**
  String get narrSpecialOwned;

  /// No description provided for @narrSpecialNotOwned.
  ///
  /// In en, this message translates to:
  /// **'The 1-100 score is not calculated for this category because standard operating ratios do not apply.'**
  String get narrSpecialNotOwned;

  /// No description provided for @narrSpecialMetrics.
  ///
  /// In en, this message translates to:
  /// **'Relevant metrics for this category: NAV discount (holding companies), EV / VNB (insurance), distribution yield (REITs / InvITs).'**
  String get narrSpecialMetrics;

  /// No description provided for @narrSpecialHold.
  ///
  /// In en, this message translates to:
  /// **'Market value of core subsidiary holdings and parent capital allocation track record.'**
  String get narrSpecialHold;

  /// No description provided for @narrSpecialIns.
  ///
  /// In en, this message translates to:
  /// **'VNB margins, persistency ratios, and solvency margin ratio.'**
  String get narrSpecialIns;

  /// No description provided for @narrSpecialTrust.
  ///
  /// In en, this message translates to:
  /// **'Occupancy rates, weighted average lease expiry (WALE), and yield spreads over G-Sec.'**
  String get narrSpecialTrust;

  /// No description provided for @narrScoreProfile.
  ///
  /// In en, this message translates to:
  /// **'Score Profile'**
  String get narrScoreProfile;

  /// No description provided for @narrNoScore.
  ///
  /// In en, this message translates to:
  /// **'{name} has no NV Score yet.'**
  String narrNoScore(Object name);

  /// No description provided for @narrScoreNoBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{name} has an NV Score of {score}/100. The pillar-by-pillar breakdown appears after the next score update.'**
  String narrScoreNoBreakdown(Object name, Object score);

  /// No description provided for @narrBreakdownPending.
  ///
  /// In en, this message translates to:
  /// **'Breakdown pending'**
  String get narrBreakdownPending;

  /// No description provided for @narrBreakdownNext.
  ///
  /// In en, this message translates to:
  /// **'Quality, valuation and price-trend details load with the next nightly score update.'**
  String get narrBreakdownNext;

  /// No description provided for @narrNoPillars.
  ///
  /// In en, this message translates to:
  /// **'No pillar data to compare yet.'**
  String get narrNoPillars;

  /// No description provided for @narrOwnedScore.
  ///
  /// In en, this message translates to:
  /// **'In your portfolio. NV Score {score}/100.'**
  String narrOwnedScore(Object score);

  /// No description provided for @narrScoreLine.
  ///
  /// In en, this message translates to:
  /// **'NV Score {score}/100.'**
  String narrScoreLine(Object score);

  /// No description provided for @narrBreakdownWatch.
  ///
  /// In en, this message translates to:
  /// **'The breakdown below the score shows which pillar moves it.'**
  String get narrBreakdownWatch;

  /// No description provided for @narrHasScore.
  ///
  /// In en, this message translates to:
  /// **'{name} has an NV Score of {score}/100. '**
  String narrHasScore(Object name, Object score);

  /// No description provided for @narrMissingPillars.
  ///
  /// In en, this message translates to:
  /// **' {pillars}: no data yet, so the other pillars carry its weight.'**
  String narrMissingPillars(Object pillars);

  /// No description provided for @narrRiskCap.
  ///
  /// In en, this message translates to:
  /// **' A risk check failed (pledge, net worth or debt), which caps the score at {cap}.'**
  String narrRiskCap(Object cap);

  /// No description provided for @narrQualityCap.
  ///
  /// In en, this message translates to:
  /// **' Its quality pillar caps the score at {cap} (54 below quality 55, no cap from 65).'**
  String narrQualityCap(Object cap);

  /// No description provided for @narrHurdle.
  ///
  /// In en, this message translates to:
  /// **' Quality is below 55, so the weighted score is multiplied by {factor}.'**
  String narrHurdle(Object factor);

  /// No description provided for @narrLenderCap.
  ///
  /// In en, this message translates to:
  /// **' Banks, NBFCs and brokers are capped at {cap} until credit data is added.'**
  String narrLenderCap(Object cap);

  /// No description provided for @narrInPortfolio.
  ///
  /// In en, this message translates to:
  /// **'In your portfolio. '**
  String get narrInPortfolio;

  /// No description provided for @narrHighLow.
  ///
  /// In en, this message translates to:
  /// **'Highest pillar: {high}. Lowest pillar: {low}.'**
  String narrHighLow(Object high, Object low);

  /// No description provided for @narrHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest pillar: {pillar}'**
  String narrHighest(Object pillar);

  /// No description provided for @narrLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest pillar: {pillar}'**
  String narrLowest(Object pillar);

  /// No description provided for @narrNoDetail.
  ///
  /// In en, this message translates to:
  /// **'No detail available for this pillar.'**
  String get narrNoDetail;

  /// No description provided for @narrMostRoom.
  ///
  /// In en, this message translates to:
  /// **'The {pillar} pillar has the most room to move the score.'**
  String narrMostRoom(Object pillar);

  /// No description provided for @narrPartScore.
  ///
  /// In en, this message translates to:
  /// **'{label} scores {points} of {max} ({detail}).'**
  String narrPartScore(Object label, Object points, Object max, Object detail);

  /// No description provided for @narrRiskFlag.
  ///
  /// In en, this message translates to:
  /// **'Risk Flag'**
  String get narrRiskFlag;

  /// No description provided for @narrBelowHurdle.
  ///
  /// In en, this message translates to:
  /// **'Below Quality Hurdle'**
  String get narrBelowHurdle;

  /// No description provided for @narrStrongLowVal.
  ///
  /// In en, this message translates to:
  /// **'Strong Quality, Lower Valuation'**
  String get narrStrongLowVal;

  /// No description provided for @narrStrongHighVal.
  ///
  /// In en, this message translates to:
  /// **'Strong Quality, High Valuation'**
  String get narrStrongHighVal;

  /// No description provided for @narrStrongQuality.
  ///
  /// In en, this message translates to:
  /// **'Strong Quality'**
  String get narrStrongQuality;

  /// No description provided for @narrMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed Profile'**
  String get narrMixed;

  /// No description provided for @narrNotScored.
  ///
  /// In en, this message translates to:
  /// **'Not Scored'**
  String get narrNotScored;

  /// No description provided for @narrBandExcellent.
  ///
  /// In en, this message translates to:
  /// **'Score Band: Excellent'**
  String get narrBandExcellent;

  /// No description provided for @narrBandStrong.
  ///
  /// In en, this message translates to:
  /// **'Score Band: Strong'**
  String get narrBandStrong;

  /// No description provided for @narrBandAverage.
  ///
  /// In en, this message translates to:
  /// **'Score Band: Average'**
  String get narrBandAverage;

  /// No description provided for @narrBandWeak.
  ///
  /// In en, this message translates to:
  /// **'Score Band: Weak'**
  String get narrBandWeak;

  /// No description provided for @commonAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get commonAnd;

  /// No description provided for @narrUpdates.
  ///
  /// In en, this message translates to:
  /// **'Quarterly results update return on capital, debt, cash flow and growth; daily closing prices update valuation and the 12-month return rank.'**
  String get narrUpdates;

  /// No description provided for @mWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What the score is'**
  String get mWhatTitle;

  /// No description provided for @mWhatBody.
  ///
  /// In en, this message translates to:
  /// **'A 0-100 score built only from published numbers: return on capital, debt, cash flow, growth, valuation and the 12-month price return. The same rules apply to every stock, and no person picks or adjusts a score. It describes a company\'s financial profile; it is not a forecast and not a buy or sell call.'**
  String get mWhatBody;

  /// No description provided for @mBands.
  ///
  /// In en, this message translates to:
  /// **'Score bands'**
  String get mBands;

  /// No description provided for @mBandExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent: strong on most measures'**
  String get mBandExcellent;

  /// No description provided for @mBandStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get mBandStrong;

  /// No description provided for @mBandAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get mBandAverage;

  /// No description provided for @mBandWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak: below the quality hurdle, or a risk flag'**
  String get mBandWeak;

  /// No description provided for @mPillars.
  ///
  /// In en, this message translates to:
  /// **'Three pillars'**
  String get mPillars;

  /// No description provided for @mPillarsBody.
  ///
  /// In en, this message translates to:
  /// **'The overall score is a weighted mix. If valuation or momentum has no data it is left out and its weight is shared by the others; it is never filled with a guessed value.'**
  String get mPillarsBody;

  /// No description provided for @mQualityBody.
  ///
  /// In en, this message translates to:
  /// **'Return on capital (ROCE) 40, debt to equity 25, operating cash flow vs profit 15, 5-year sales and profit growth 20 (full marks at 20% a year sales and 25% profit; shrinking scores 0). ROCE and debt count half on a fixed scale and half on the rank among companies in the same industry (15 or more), else the same sector.'**
  String get mQualityBody;

  /// No description provided for @mValuationBody.
  ///
  /// In en, this message translates to:
  /// **'P/E compared with companies in the same industry 50, P/E compared with its own 5-year average 30 (0.6x or lower full marks, 0.85x half, 1.3x or higher none), and P/E against 5-year profit growth (PEG) 20 (1 or lower full marks, 3 or higher none; growth counted between 5% and 40% a year). A part with no data is left out. A loss-making company scores 0. Companies that demerged a large business, or have no 5-year average, use the earnings yield vs the 10-year government bond instead of their own average. Banks and NBFCs use P/B: rank within banks or NBFCs 60, against their own 5-year average 40.'**
  String get mValuationBody;

  /// No description provided for @mMomentumBody.
  ///
  /// In en, this message translates to:
  /// **'Price return over the last 12 months, leaving out the latest month, ranked against every scored stock (6 months for stocks listed under a year). RSI, MACD and moving averages are shown for information and are not scored.'**
  String get mMomentumBody;

  /// No description provided for @mHurdleBody.
  ///
  /// In en, this message translates to:
  /// **'When the quality pillar is below 55, the overall score is capped at 54. From quality 55 to 65 the cap rises step by step (about 4.6 points per quality point) and disappears at 65, so a small change in quality never makes the score jump. A cheap stock or a strong price run cannot lift a weak business into the strong bands.'**
  String get mHurdleBody;

  /// No description provided for @mMinData.
  ///
  /// In en, this message translates to:
  /// **'Minimum data'**
  String get mMinData;

  /// No description provided for @mMinDataBody.
  ///
  /// In en, this message translates to:
  /// **'Quality needs at least 3 of its 4 inputs (return on capital, debt, cash flow, growth). With 2 inputs the overall score is capped at 60; with fewer, or without return on capital, no score is shown and the stock reads DATA PENDING. Missing inputs are never assumed.'**
  String get mMinDataBody;

  /// No description provided for @mRiskFlags.
  ///
  /// In en, this message translates to:
  /// **'Risk flags'**
  String get mRiskFlags;

  /// No description provided for @mRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Any of these caps the score at 28 and shows HIGH RISK FLAG, whatever the other numbers say:'**
  String get mRiskBody;

  /// No description provided for @mPledge.
  ///
  /// In en, this message translates to:
  /// **'Pledge'**
  String get mPledge;

  /// No description provided for @mPledgeBody.
  ///
  /// In en, this message translates to:
  /// **'75% or more of promoter shares pledged, or pledged shares at 25% or more of the company'**
  String get mPledgeBody;

  /// No description provided for @mNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get mNetWorth;

  /// No description provided for @mNetWorthBody.
  ///
  /// In en, this message translates to:
  /// **'Zero or negative shareholder equity (held for review instead when the price-to-book in the fundamentals dataset is positive)'**
  String get mNetWorthBody;

  /// No description provided for @mDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get mDebt;

  /// No description provided for @mDebtBody.
  ///
  /// In en, this message translates to:
  /// **'A negative debt-to-equity figure (a data anomaly)'**
  String get mDebtBody;

  /// No description provided for @mReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed pledges'**
  String get mReviewed;

  /// No description provided for @mReviewedBody.
  ///
  /// In en, this message translates to:
  /// **'Some large pledges are checked against exchange filings. When the promoter is a private-equity owner that pledged its stake for its own holding-company loan, the pledge is shown as a note and does not trigger the flag. Every other pledge follows the rule above.'**
  String get mReviewedBody;

  /// No description provided for @mSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special cases'**
  String get mSpecial;

  /// No description provided for @mBanks.
  ///
  /// In en, this message translates to:
  /// **'Banks and NBFCs'**
  String get mBanks;

  /// No description provided for @mBanksBody.
  ///
  /// In en, this message translates to:
  /// **'Quality is return on equity 30, return on assets 25, net interest margin 15 (banks only), leverage 10 and growth 20. Loan quality (NPA) is not assessed yet, so the score is capped at 75 and shows a \"provisional\" badge.'**
  String get mBanksBody;

  /// No description provided for @mBrokers.
  ///
  /// In en, this message translates to:
  /// **'Brokers'**
  String get mBrokers;

  /// No description provided for @mBrokersBody.
  ///
  /// In en, this message translates to:
  /// **'Debt is not scored (margin funding borrowings); capped at 75 with a \"provisional\" badge.'**
  String get mBrokersBody;

  /// No description provided for @mInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance, holding companies, REITs / InvITs'**
  String get mInsurance;

  /// No description provided for @mInsuranceBody.
  ///
  /// In en, this message translates to:
  /// **'No score. Their accounts do not fit these ratios; they need embedded value, NAV or yield instead.'**
  String get mInsuranceBody;

  /// No description provided for @mEtfsBody.
  ///
  /// In en, this message translates to:
  /// **'Valuation is set to a neutral 60.'**
  String get mEtfsBody;

  /// No description provided for @mReview.
  ///
  /// In en, this message translates to:
  /// **'Data under review'**
  String get mReview;

  /// No description provided for @mReviewBody.
  ///
  /// In en, this message translates to:
  /// **'No score when our stored fundamentals fail a check against exchange data (market cap or price of a different company). It returns once the data is corrected.'**
  String get mReviewBody;

  /// No description provided for @mLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get mLabels;

  /// No description provided for @mPositiveTrend.
  ///
  /// In en, this message translates to:
  /// **'Positive trend'**
  String get mPositiveTrend;

  /// No description provided for @mPositiveBody.
  ///
  /// In en, this message translates to:
  /// **'Momentum rank 50+. A stock already on the positive side keeps it until the rank falls below 45; one on the weak side needs 55 to cross, so a label does not flip on small daily moves.'**
  String get mPositiveBody;

  /// No description provided for @mHighStrength.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, valuation 65+, positive trend'**
  String get mHighStrength;

  /// No description provided for @mConsolidation.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, valuation 65+, weak trend'**
  String get mConsolidation;

  /// No description provided for @mFair.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, valuation 35-64'**
  String get mFair;

  /// No description provided for @mExtended.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, valuation below 35, positive trend'**
  String get mExtended;

  /// No description provided for @mElevated.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, valuation below 35, weak trend'**
  String get mElevated;

  /// No description provided for @mNeutral.
  ///
  /// In en, this message translates to:
  /// **'Quality 55-69'**
  String get mNeutral;

  /// No description provided for @mBelow.
  ///
  /// In en, this message translates to:
  /// **'Quality below 55'**
  String get mBelow;

  /// No description provided for @mNegative.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, but the company is loss-making'**
  String get mNegative;

  /// No description provided for @mUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Quality 70+, but under 6 months of price history or no valuation data'**
  String get mUnavailable;

  /// No description provided for @mUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Pledge data is missing, so the risk check could not run'**
  String get mUnconfirmed;

  /// No description provided for @mDataPending.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to score yet'**
  String get mDataPending;

  /// No description provided for @mFreshness.
  ///
  /// In en, this message translates to:
  /// **'Data and freshness'**
  String get mFreshness;

  /// No description provided for @mFreshnessBody.
  ///
  /// In en, this message translates to:
  /// **'Fundamentals come from a dataset compiled from companies\' published results; where a figure is missing, debt and cash flow are taken from Yahoo Finance; net worth, margins and bank balance-sheet figures come from Yahoo Finance. Closing prices come from the NSE daily bhavcopy; prices during market hours come from Yahoo Finance and can be delayed. Scores are recalculated after each trading day\'s close. Data can be incomplete or wrong; check the company\'s filings before relying on any number.'**
  String get mFreshnessBody;

  /// No description provided for @syncStepAuth.
  ///
  /// In en, this message translates to:
  /// **'Verifying Authentication'**
  String get syncStepAuth;

  /// No description provided for @syncStepHoldings.
  ///
  /// In en, this message translates to:
  /// **'Loading Portfolio Holdings'**
  String get syncStepHoldings;

  /// No description provided for @syncStepPrices.
  ///
  /// In en, this message translates to:
  /// **'Syncing Latest Prices & Health'**
  String get syncStepPrices;

  /// No description provided for @syncLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Portfolio...'**
  String get syncLoading;

  /// No description provided for @dashToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get dashToday;

  /// No description provided for @signalWeakest.
  ///
  /// In en, this message translates to:
  /// **'WEAKEST'**
  String get signalWeakest;

  /// No description provided for @recoStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong Returns'**
  String get recoStrong;

  /// No description provided for @recoAbove.
  ///
  /// In en, this message translates to:
  /// **'Your holdings are {ret} above their total cost.'**
  String recoAbove(Object ret);

  /// No description provided for @recoPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive Returns'**
  String get recoPositive;

  /// No description provided for @recoNearCost.
  ///
  /// In en, this message translates to:
  /// **'Near Cost'**
  String get recoNearCost;

  /// No description provided for @recoAgainst.
  ///
  /// In en, this message translates to:
  /// **'Your holdings are {ret} against their total cost.'**
  String recoAgainst(Object ret);

  /// No description provided for @recoMild.
  ///
  /// In en, this message translates to:
  /// **'Mild Drawdown'**
  String get recoMild;

  /// No description provided for @recoBelow.
  ///
  /// In en, this message translates to:
  /// **'Your holdings are {ret} below their total cost.'**
  String recoBelow(Object ret);

  /// No description provided for @recoBelowCost.
  ///
  /// In en, this message translates to:
  /// **'Below Cost'**
  String get recoBelowCost;

  /// No description provided for @recoOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall return: {ret}.'**
  String recoOverall(Object ret);

  /// No description provided for @recoAboveBuy.
  ///
  /// In en, this message translates to:
  /// **'{profit} of {total} holdings are above their buy price.'**
  String recoAboveBuy(Object profit, Object total);

  /// No description provided for @recoHealth.
  ///
  /// In en, this message translates to:
  /// **'NV Health Index {score}/100 (value-weighted average NV Score).'**
  String recoHealth(Object score);

  /// No description provided for @recoLoss.
  ///
  /// In en, this message translates to:
  /// **'{count} holdings are below their buy price; each one\'s \"Why this score\" shows its lowest pillar.'**
  String recoLoss(Object count);

  /// No description provided for @recoLargestFall.
  ///
  /// In en, this message translates to:
  /// **'Largest fall: {symbol} ({pct}).'**
  String recoLargestFall(Object symbol, Object pct);

  /// No description provided for @recoUnpriced.
  ///
  /// In en, this message translates to:
  /// **'{count} holdings have no current price and are left out of the totals.'**
  String recoUnpriced(Object count);

  /// No description provided for @recoStale.
  ///
  /// In en, this message translates to:
  /// **'{count} holdings show their last saved price, not a live one.'**
  String recoStale(Object count);

  /// No description provided for @recoNoneBelow.
  ///
  /// In en, this message translates to:
  /// **'No holding is below its buy price.'**
  String get recoNoneBelow;

  /// No description provided for @errSymbolNotListed.
  ///
  /// In en, this message translates to:
  /// **'This symbol is not in the NSE list. Choose the stock from search.'**
  String get errSymbolNotListed;

  /// No description provided for @errLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in first.'**
  String get errLoginRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'IN':
            return AppLocalizationsEnIn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
