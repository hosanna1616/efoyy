// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'እፎይ - የታካሚ ምቾት';

  @override
  String get welcome => 'እንኳን ደህና መጡ ወደ እፎይ';

  @override
  String get register => 'ተመዝግብ';

  @override
  String get opdQueue => 'የOPD ወረፋ';

  @override
  String get digitalCard => 'ዲጂታል ካርድ';

  @override
  String get instructions => 'መመሪያዎች';

  @override
  String get navigation => 'መሪ';

  @override
  String get staffDashboard => 'የሰራተኞች ዳሽቦርድ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get logout => 'ውጣ';

  @override
  String get login => 'ግባ';

  @override
  String get patientLogin => 'የታካሚ መግቢያ';

  @override
  String get registerToGetStarted => 'ለመጀመር ይመዝግቡ';

  @override
  String get checkYourTurn => 'የእርስዎን ተራ ይፈትሹ';

  @override
  String get viewYourCard => 'ዲጂታል ካርድዎን ይመልከቱ';

  @override
  String get viewInstructions => 'ከነርስ የተላኩ መመሪያዎችን ይመልከቱ';

  @override
  String get getDirections => 'ወደ ክፍሎች አቅጣጫ ያግኙ';

  @override
  String get name => 'ስም';

  @override
  String get phoneNumber => 'የስልክ ቁጥር';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get enterYourName => 'ስምዎን ያስገቡ';

  @override
  String get enterPhoneNumber => 'የስልክ ቁጥርዎን ያስገቡ';

  @override
  String get pleaseEnterYourName => 'እባክዎ ስምዎን ያስገቡ';

  @override
  String get nameCannotContainNumbers => 'ስም ቁጥሮችን ሊይዝ አይችልም';

  @override
  String get nameMustBeAtLeast2Characters => 'ስም ቢያንስ 2 ቁምፊዎች መሆን አለበት';

  @override
  String get pleaseEnterYourPhoneNumber => 'እባክዎ የስልክ ቁጥርዎን ያስገቡ';

  @override
  String get phoneNumberCanOnlyContainDigits => 'የስልክ ቁጥር ቁጥሮችን ብቻ ሊይዝ ይችላል';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'እባክዎ ትክክለኛ የስልክ ቁጥር ያስገቡ (9-10 አሃዞች)';

  @override
  String get alreadyRegistered =>
      'ተመሳሳይ ስም እና የስልክ ቁጥር ያለው ታካሚ ቀድሞውኑ ተመዝግቧል። እባክዎ ይግቡ።';

  @override
  String registered(String id) {
    return 'ተመዝግበዋል! የእርስዎ መለያ: $id';
  }

  @override
  String get error => 'ስህተት';

  @override
  String get room => 'ክፍል';

  @override
  String get joinQueue => 'ወደ ወረፋ ይቀላቀሉ';

  @override
  String get pleaseEnterRoomName => 'እባክዎ የክፍል ስም ያስገቡ';

  @override
  String get successfullyJoinedQueue => 'በተሳካ ሁኔታ ወደ ወረፋ ተቀላቀሉ!';

  @override
  String get errorJoiningQueue => 'ወደ ወረፋ በመቀላቀል ላይ ስህተት';

  @override
  String queueNumber(int number) {
    return 'የወረፋ ቁጥር #$number';
  }

  @override
  String get position => 'ቦታ';

  @override
  String get estimatedWait => 'የታሰበ የጥበቃ ጊዜ';

  @override
  String get yourTurnNow => 'አሁን ተራዎ ነው!';

  @override
  String minutes(int count) {
    return '$count ደቂቃዎች';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hoursሰ $minutesደ';
  }

  @override
  String get yourTurn => 'ተራዎ ነው!';

  @override
  String goToRoom(String room) {
    return 'አሁን ወደ $room ይሂዱ';
  }

  @override
  String get buttonPhoneUsersCheckSMS => 'የአሞሌ ስልክ ተጠቃሚዎች: ለማሳወቂያ SMS ይፈትሹ';

  @override
  String get reportPain => 'ስቃይ ሪፖርት ያድርጉ';

  @override
  String get liveQueue => 'የቀጥታ ወረፋ';

  @override
  String get noPatientsInQueue => 'በወረፋ ውስጥ ታካሚዎች የሉም';

  @override
  String get queueWillAppearHere => 'ታካሚዎች ሲቀላቀሉ ወረፋው እዚህ ይታያል';

  @override
  String get callNextPatient => 'ቀጣዩን ታካሚ ይጥሩ';

  @override
  String get nextPatientCalled => 'ቀጣዩ ታካሚ ተጠርቷል';

  @override
  String get markAsServed => 'እንደ አገልግሎት የተሰጠ ምልክት ያድርጉ';

  @override
  String get removeFromQueue => 'ከወረፋ ያስወግዱ';

  @override
  String get patientMarkedAsServed =>
      'ታካሚ እንደ አገልግሎት የተሰጠ ምልክት ተደርጎታል። ቀጣዩ ታካሚ ተጠቅሟል።';

  @override
  String get removeFromQueueTitle => 'ከወረፋ ማስወገድ';

  @override
  String areYouSureRemove(String name) {
    return 'እርግጠኛ ነዎት $nameን ከወረፋ ማስወገድ ይፈልጋሉ?';
  }

  @override
  String get cancel => 'ተወው';

  @override
  String get remove => 'ያስወግዱ';

  @override
  String removedFromQueue(String name) {
    return '$name ከወረፋ ተወግዷል። ቀጣዩ ታካሚ ተጠቅሟል።';
  }

  @override
  String get joined => 'ተቀላቅሏል';

  @override
  String get estWait => 'የታሰበ ጥበቃ';

  @override
  String get now => 'አሁን';

  @override
  String get downloadAsPNG => 'እንደ PNG ያውርዱ';

  @override
  String get preparingCard => 'ካርድ እየተዘጋጀ ነው...';

  @override
  String get cardReadyToSave => 'ካርድ ለማስቀመጥ/ለማጋራት ዝግጁ ነው!';

  @override
  String cardSavedTo(String path) {
    return 'ካርድ ተቀምጧል በ: $path';
  }

  @override
  String get errorSavingCard => 'ካርድን በማስቀመጥ ላይ ስህተት';

  @override
  String get patientID => 'የታካሚ መለያ';

  @override
  String get nextAppointment => 'ቀጣይ ቀጠሮ';

  @override
  String get memberSince => 'አባል ከ';

  @override
  String get medicalHistory => 'የጤና ታሪክ';

  @override
  String get noInstructions => 'እስካሁን ምንም መመሪያዎች የሉም';

  @override
  String get instructionsWillAppearHere => 'ከነርስዎ የተላኩ መመሪያዎች እዚህ ይታያሉ';

  @override
  String get switchToEnglish => 'ወደ እንግሊዝኛ ቀይር';

  @override
  String get switchToAmharic => 'ወደ አማርኛ ቀይር';

  @override
  String get notRegistered => 'አልተመዘገቡም? እዚህ ይመዝግቡ';

  @override
  String get enterRoomName => 'የክፍል ስም ያስገቡ (ለምሳሌ፣ OPD Room 1)';

  @override
  String liveQueueTitle(String room) {
    return 'የቀጥታ ወረፋ - $room';
  }

  @override
  String get refreshQueue => 'ወረፋውን ያድሱ';

  @override
  String get unableToLoadQueue => 'ወረፋውን ማስገባት አልቻለም';

  @override
  String get staffLogin => 'የሰራተኞች መግቢያ';

  @override
  String get nursesDoctorsOnly => 'ነርሶች እና ዶክተሮች ብቻ';

  @override
  String get username => 'የተጠቃሚ ስም';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get pleaseEnterUsername => 'እባክዎ የተጠቃሚ ስም ያስገቡ';

  @override
  String get pleaseEnterPassword => 'እባክዎ የይለፍ ቃል ያስገቡ';

  @override
  String get invalidCredentials => 'ትክክል ያልሆነ የመግቢያ መረጃ። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get backToHome => 'ወደ መነሻ ተመለስ';

  @override
  String get patientNotFound => 'ታካሚ አልተገኘም። እባክዎ በመጀመሪያ ይመዝግቡ።';

  @override
  String welcomeBack(String name) {
    return 'እንኳን ደህና መጡ፣ $name!';
  }

  @override
  String get enterPhoneToView => 'የወረፋዎን እና መመሪያዎችዎን ለማየት የስልክ ቁጥርዎን ያስገቡ';

  @override
  String get pleaseEnterPhoneNumber => 'እባክዎ የስልክ ቁጥርዎን ያስገቡ';

  @override
  String get pleaseEnterValidPhoneNumberShort => 'እባክዎ ትክክለኛ የስልክ ቁጥር ያስገቡ';

  @override
  String get smartphoneMode => 'የስማርትፎን ሁነታ';

  @override
  String get smartphoneModeDescription =>
      'ለስማርትፎኖች ይክፈቱ፣ ለአሞሌ ስልኮች ይዝጉ (SMS ብቻ)';

  @override
  String get smartphoneModeEnabled => 'የስማርትፎን ሁነታ ተክቷል';

  @override
  String get buttonPhoneModeEnabled => 'የአሞሌ ስልክ ሁነታ ተክቷል (SMS ብቻ)';

  @override
  String get useLanguageToggle => 'በመተግበሪያ አሞሌ ውስጥ የቋንቋ መቀያየሪያ ይጠቀሙ';
}
