import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
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
    Locale('am'),
    Locale('en')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Efoy - Patient Relief'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Efoy'**
  String get welcome;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @opdQueue.
  ///
  /// In en, this message translates to:
  /// **'OPD Queue'**
  String get opdQueue;

  /// No description provided for @digitalCard.
  ///
  /// In en, this message translates to:
  /// **'Digital Card'**
  String get digitalCard;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @staffDashboard.
  ///
  /// In en, this message translates to:
  /// **'Staff Dashboard'**
  String get staffDashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @patientLogin.
  ///
  /// In en, this message translates to:
  /// **'Patient Login'**
  String get patientLogin;

  /// No description provided for @registerToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Register to get started'**
  String get registerToGetStarted;

  /// No description provided for @checkYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Check your turn'**
  String get checkYourTurn;

  /// No description provided for @viewYourCard.
  ///
  /// In en, this message translates to:
  /// **'View your digital card'**
  String get viewYourCard;

  /// No description provided for @viewInstructions.
  ///
  /// In en, this message translates to:
  /// **'View instructions from nurse'**
  String get viewInstructions;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions to rooms'**
  String get getDirections;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @nameCannotContainNumbers.
  ///
  /// In en, this message translates to:
  /// **'Name cannot contain numbers'**
  String get nameCannotContainNumbers;

  /// No description provided for @nameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMustBeAtLeast2Characters;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @phoneNumberCanOnlyContainDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone number can only contain digits'**
  String get phoneNumberCanOnlyContainDigits;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number (9-10 digits)'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'A patient with the same name and phone number is already registered. Please login instead.'**
  String get alreadyRegistered;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered! Your ID: {id}'**
  String registered(String id);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @joinQueue.
  ///
  /// In en, this message translates to:
  /// **'Join Queue'**
  String get joinQueue;

  /// No description provided for @pleaseEnterRoomName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a room name'**
  String get pleaseEnterRoomName;

  /// No description provided for @successfullyJoinedQueue.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined queue!'**
  String get successfullyJoinedQueue;

  /// No description provided for @errorJoiningQueue.
  ///
  /// In en, this message translates to:
  /// **'Error joining queue'**
  String get errorJoiningQueue;

  /// No description provided for @queueNumber.
  ///
  /// In en, this message translates to:
  /// **'Queue #{number}'**
  String queueNumber(int number);

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @estimatedWait.
  ///
  /// In en, this message translates to:
  /// **'Estimated Wait'**
  String get estimatedWait;

  /// No description provided for @yourTurnNow.
  ///
  /// In en, this message translates to:
  /// **'Your turn now!'**
  String get yourTurnNow;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String minutes(int count);

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutes(int hours, int minutes);

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your Turn!'**
  String get yourTurn;

  /// No description provided for @goToRoom.
  ///
  /// In en, this message translates to:
  /// **'Go to {room} now'**
  String goToRoom(String room);

  /// No description provided for @buttonPhoneUsersCheckSMS.
  ///
  /// In en, this message translates to:
  /// **'Button phone users: Check SMS for notification'**
  String get buttonPhoneUsersCheckSMS;

  /// No description provided for @reportPain.
  ///
  /// In en, this message translates to:
  /// **'Report Pain'**
  String get reportPain;

  /// No description provided for @liveQueue.
  ///
  /// In en, this message translates to:
  /// **'Live Queue'**
  String get liveQueue;

  /// No description provided for @noPatientsInQueue.
  ///
  /// In en, this message translates to:
  /// **'No patients in queue'**
  String get noPatientsInQueue;

  /// No description provided for @queueWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Queue will appear here when patients join'**
  String get queueWillAppearHere;

  /// No description provided for @callNextPatient.
  ///
  /// In en, this message translates to:
  /// **'Call Next Patient'**
  String get callNextPatient;

  /// No description provided for @nextPatientCalled.
  ///
  /// In en, this message translates to:
  /// **'Next patient called'**
  String get nextPatientCalled;

  /// No description provided for @markAsServed.
  ///
  /// In en, this message translates to:
  /// **'Mark as served'**
  String get markAsServed;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @patientMarkedAsServed.
  ///
  /// In en, this message translates to:
  /// **'Patient marked as served. Next patient notified.'**
  String get patientMarkedAsServed;

  /// No description provided for @removeFromQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Queue'**
  String get removeFromQueueTitle;

  /// No description provided for @areYouSureRemove.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the queue?'**
  String areYouSureRemove(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removedFromQueue.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from queue. Next patient notified.'**
  String removedFromQueue(String name);

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joined;

  /// No description provided for @estWait.
  ///
  /// In en, this message translates to:
  /// **'Est. Wait'**
  String get estWait;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @downloadAsPNG.
  ///
  /// In en, this message translates to:
  /// **'Download as PNG'**
  String get downloadAsPNG;

  /// No description provided for @preparingCard.
  ///
  /// In en, this message translates to:
  /// **'Preparing card...'**
  String get preparingCard;

  /// No description provided for @cardReadyToSave.
  ///
  /// In en, this message translates to:
  /// **'Card ready to save/share!'**
  String get cardReadyToSave;

  /// No description provided for @cardSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Card saved to: {path}'**
  String cardSavedTo(String path);

  /// No description provided for @errorSavingCard.
  ///
  /// In en, this message translates to:
  /// **'Error saving card'**
  String get errorSavingCard;

  /// No description provided for @patientID.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientID;

  /// No description provided for @nextAppointment.
  ///
  /// In en, this message translates to:
  /// **'Next Appointment'**
  String get nextAppointment;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet'**
  String get noInstructions;

  /// No description provided for @instructionsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Instructions from your nurse will appear here'**
  String get instructionsWillAppearHere;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @switchToAmharic.
  ///
  /// In en, this message translates to:
  /// **'ወደ አማርኛ ቀይር'**
  String get switchToAmharic;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered? Register here'**
  String get notRegistered;

  /// No description provided for @enterRoomName.
  ///
  /// In en, this message translates to:
  /// **'Enter room name (e.g., OPD Room 1)'**
  String get enterRoomName;

  /// No description provided for @liveQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Queue - {room}'**
  String liveQueueTitle(String room);

  /// No description provided for @refreshQueue.
  ///
  /// In en, this message translates to:
  /// **'Refresh queue'**
  String get refreshQueue;

  /// No description provided for @unableToLoadQueue.
  ///
  /// In en, this message translates to:
  /// **'Unable to load queue'**
  String get unableToLoadQueue;

  /// No description provided for @staffLogin.
  ///
  /// In en, this message translates to:
  /// **'Staff Login'**
  String get staffLogin;

  /// No description provided for @nursesDoctorsOnly.
  ///
  /// In en, this message translates to:
  /// **'Nurses & Doctors Only'**
  String get nursesDoctorsOnly;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @patientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Patient not found. Please register first.'**
  String get patientNotFound;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String welcomeBack(String name);

  /// No description provided for @enterPhoneToView.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to view your queue and instructions'**
  String get enterPhoneToView;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterValidPhoneNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumberShort;

  /// No description provided for @smartphoneMode.
  ///
  /// In en, this message translates to:
  /// **'Smartphone Mode'**
  String get smartphoneMode;

  /// No description provided for @smartphoneModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable for smartphones, disable for button phones (SMS-only mode)'**
  String get smartphoneModeDescription;

  /// No description provided for @smartphoneModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Smartphone mode enabled'**
  String get smartphoneModeEnabled;

  /// No description provided for @buttonPhoneModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Button phone mode enabled (SMS-only)'**
  String get buttonPhoneModeEnabled;

  /// No description provided for @useLanguageToggle.
  ///
  /// In en, this message translates to:
  /// **'Use language toggle in app bar'**
  String get useLanguageToggle;
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
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
