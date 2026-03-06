// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Efoy - Patient Relief';

  @override
  String get welcome => 'Welcome to Efoy';

  @override
  String get register => 'Register';

  @override
  String get opdQueue => 'OPD Queue';

  @override
  String get digitalCard => 'Digital Card';

  @override
  String get instructions => 'Instructions';

  @override
  String get navigation => 'Navigation';

  @override
  String get staffDashboard => 'Staff Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get patientLogin => 'Patient Login';

  @override
  String get registerToGetStarted => 'Register to get started';

  @override
  String get checkYourTurn => 'Check your turn';

  @override
  String get viewYourCard => 'View your digital card';

  @override
  String get viewInstructions => 'View instructions from nurse';

  @override
  String get getDirections => 'Get directions to rooms';

  @override
  String get name => 'Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get nameCannotContainNumbers => 'Name cannot contain numbers';

  @override
  String get nameMustBeAtLeast2Characters =>
      'Name must be at least 2 characters';

  @override
  String get pleaseEnterYourPhoneNumber => 'Please enter your phone number';

  @override
  String get phoneNumberCanOnlyContainDigits =>
      'Phone number can only contain digits';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'Please enter a valid phone number (9-10 digits)';

  @override
  String get alreadyRegistered =>
      'A patient with the same name and phone number is already registered. Please login instead.';

  @override
  String registered(String id) {
    return 'Registered! Your ID: $id';
  }

  @override
  String get error => 'Error';

  @override
  String get room => 'Room';

  @override
  String get joinQueue => 'Join Queue';

  @override
  String get pleaseEnterRoomName => 'Please enter a room name';

  @override
  String get successfullyJoinedQueue => 'Successfully joined queue!';

  @override
  String get errorJoiningQueue => 'Error joining queue';

  @override
  String queueNumber(int number) {
    return 'Queue #$number';
  }

  @override
  String get position => 'Position';

  @override
  String get estimatedWait => 'Estimated Wait';

  @override
  String get yourTurnNow => 'Your turn now!';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get yourTurn => 'Your Turn!';

  @override
  String goToRoom(String room) {
    return 'Go to $room now';
  }

  @override
  String get buttonPhoneUsersCheckSMS =>
      'Button phone users: Check SMS for notification';

  @override
  String get reportPain => 'Report Pain';

  @override
  String get liveQueue => 'Live Queue';

  @override
  String get noPatientsInQueue => 'No patients in queue';

  @override
  String get queueWillAppearHere => 'Queue will appear here when patients join';

  @override
  String get callNextPatient => 'Call Next Patient';

  @override
  String get nextPatientCalled => 'Next patient called';

  @override
  String get markAsServed => 'Mark as served';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get patientMarkedAsServed =>
      'Patient marked as served. Next patient notified.';

  @override
  String get removeFromQueueTitle => 'Remove from Queue';

  @override
  String areYouSureRemove(String name) {
    return 'Are you sure you want to remove $name from the queue?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String removedFromQueue(String name) {
    return '$name removed from queue. Next patient notified.';
  }

  @override
  String get joined => 'Joined';

  @override
  String get estWait => 'Est. Wait';

  @override
  String get now => 'Now';

  @override
  String get downloadAsPNG => 'Download as PNG';

  @override
  String get preparingCard => 'Preparing card...';

  @override
  String get cardReadyToSave => 'Card ready to save/share!';

  @override
  String cardSavedTo(String path) {
    return 'Card saved to: $path';
  }

  @override
  String get errorSavingCard => 'Error saving card';

  @override
  String get patientID => 'Patient ID';

  @override
  String get nextAppointment => 'Next Appointment';

  @override
  String get memberSince => 'Member Since';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get noInstructions => 'No instructions yet';

  @override
  String get instructionsWillAppearHere =>
      'Instructions from your nurse will appear here';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToAmharic => 'ወደ አማርኛ ቀይር';

  @override
  String get notRegistered => 'Not registered? Register here';

  @override
  String get enterRoomName => 'Enter room name (e.g., OPD Room 1)';

  @override
  String liveQueueTitle(String room) {
    return 'Live Queue - $room';
  }

  @override
  String get refreshQueue => 'Refresh queue';

  @override
  String get unableToLoadQueue => 'Unable to load queue';

  @override
  String get staffLogin => 'Staff Login';

  @override
  String get nursesDoctorsOnly => 'Nurses & Doctors Only';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get invalidCredentials => 'Invalid credentials. Please try again.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get patientNotFound => 'Patient not found. Please register first.';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get enterPhoneToView =>
      'Enter your phone number to view your queue and instructions';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterValidPhoneNumberShort =>
      'Please enter a valid phone number';

  @override
  String get smartphoneMode => 'Smartphone Mode';

  @override
  String get smartphoneModeDescription =>
      'Enable for smartphones, disable for button phones (SMS-only mode)';

  @override
  String get smartphoneModeEnabled => 'Smartphone mode enabled';

  @override
  String get buttonPhoneModeEnabled => 'Button phone mode enabled (SMS-only)';

  @override
  String get useLanguageToggle => 'Use language toggle in app bar';
}
