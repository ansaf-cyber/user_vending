import 'package:flutter/material.dart';

class FFLocalizations {
  final Locale locale;

  FFLocalizations(this.locale);

  static FFLocalizations of(BuildContext context) {
    return Localizations.of<FFLocalizations>(context, FFLocalizations)!;
  }

  static const LocalizationsDelegate<FFLocalizations> delegate =
      _FFLocalizationsDelegate();
  String getText(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "aboutUs": "About Us",

      "locationPermissionDenied": "Location permission denied.",
      "goToSettingsToEnable": "Please enable location from settings.",

      'termsOfUse': 'Terms Of Use',
      "support": "Support",
      "openAppleAccount": "Open Apple Account",

      "emailRequired": "Email is required",
      "enterValidEmail": "Enter a valid email",
      "passwordTooShort": "Password must be at least 6 characters",
      "passwordsDoNotMatch": "Passwords do not match",

      "userNotLoggedIn": "User not logged in",

      "enterPin": "Please enter a PIN",
      "addressDetails": "Address Details",
      "enterPinLink": "Enter a PIN",

      "profileUpdated": "Profile updated",
      "noLoggedInUser": "No logged in user found.",
      "verificationEmailSent":
          "Verification email sent. Please verify it to complete the email change",
      "incorrectPassword": "Incorrect password",
      "emailInUse": "This email is already in use.",
      "reloginTryAgain": "Please re-login and try again.",
      "errorOccurred": "An error occurred.",
      "unexpectedError": "Unexpected error. Please try again.",
      "passwordUpdated": "Password updated successfully.",
      "incorrectCurrentPassword": "Incorrect current password.",
      "weakPassword": "The new password is too weak.",
      "googleSignInFailed": "Google Sign-In failed",
      "locationServicesDisabled":
          "Location services are disabled. Please enable them.",
      "locationPermissionRequired":
          "Location permissions are required to determine your country.",

      "accountCreated": "Account created successfully!",
      "noUserWithEmail": "No user found with this email.",
      "invalidEmail": "The email address is not valid.",
      "userDisabled": "This account has been disabled.",
      "signInFailed": "Sign-in failed",
      "signUpFailed": "Sign-up failed",
      "emailInvalid": "Invalid email address",

      'settings': 'Settings',
      'accountInfo': 'Account Info',
      'savedAddresses': 'Saved Addresses',
      'changeEmail': 'Change Email',
      'changePassword': 'Change Password',
      'notifications': 'Notifications',
      'language': 'Language',
      'country': 'Country',
      'logout': 'Log Out',
      'disabled': 'Disabled',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'introText': 'Lets get started by filling out the form below',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password',
      'confirmPassword': 'Confirm Password',
      'createAccount': 'Create Account',
      'orSignUpWith': 'Or sign up with',
      'continueWithGoogle': 'Continue with Google',
      'continueWithApple': 'Continue with Apple',
      'continueWithFacebook': 'Continue with Facebook',
      'welcome': 'Welcome',

      'edit': 'Edit',
      'firstName': 'First name',
      'lastName': 'Last name',
      'dobOptional': 'Date of birth (optional)',
      'genderOptional': 'Gender (optional)',
      'male': 'Male',
      'female': 'Female',
      'receiveOffers': 'Yes, I want to receive offers and discounts',
      'subscribeNewsletter': 'Subscribe to newsletter',
      'deleteAccount': 'Delete account',
      'deleteAccountConfirmation':
          'Are you sure you want to delete your account? This action cannot be undone.',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'newEmail': 'New Email',
      'confirmEmail': 'Confirm Email',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'logoutConfirmation': 'Are you sure you want to log out?',

      "searchDeliveryUpdates": "Search delivery updates",

      'change': 'Change',

      'reauthenticate': 'Re-authenticate',
      'enterPassword': 'Enter your password',
      'accountDeleted': 'Account successfully deleted',

      'enterYourPin': 'Enter Your PIN',
      'pleaseEnterPin': 'Please Enter PIN',
      'incorrectPin': 'Incorrect PIN',
      'submit': 'Submit',
      'active': "active",
      "errorLoading": "Error loading data",
      "selectLanguage": "Select a language",
      "selectCountry": "Select a country",
      "noChanges": "No changes found",

      "delete": "Delete",

      "views": "Views",

      "from": "From:",
      "to": "To:",

      "privacyPolicy": "Privacy Policy",
      'forgotPasswordTitle': 'Reset Your Password',
      'forgotPasswordSubtitle':
          'Enter your email to receive a password reset link',

      'sendResetLink': 'Send Reset Link',
      'resetLinkSent': 'Reset link sent successfully!',
      'backToSignIn': 'Back to Sign In',

      "locationPermissionPermanentlyDenied":
          "Location permission permanently denied. Please enable it from settings.",
      "locationFetchFailed": "Failed to fetch location.",

      "storeRequired": "Store name is required",
      "storeTitle": "Store Information",
      "enterPhoneNumberTitle": "Enter your phone number",
      "enterOtpTitle": "Enter OTP",
      "otpHint": "Enter 6-digit OTP",
      "getOtpVia": "Get OTP via",
      "sms": "SMS",
      "whatsapp": "WhatsApp",
      "sendOtp": "Send OTP",
      "verifyOtp": "Verify OTP",
      "resendOtp": "Resend OTP",
      "otpSentSuccess": "OTP sent successfully ",
      "otpVerifiedSuccess": "OTP verified successfully!",
      "otpInvalid": "Invalid OTP. Please try again.",
      "sendOtpFailed": "Failed to send OTP: {error}",
      "verifyOtpFailed": "Failed to verify OTP: {error}",
      "phoneNumberAlreadyLinked":
          "This phone number is already linked to another account.",
      "verifyPhoneTitle": "Verify Your Phone Number to Continue",
      "invalidOtp": "Invalid OTP. Please try again.",

      "enterOtp": "Please enter the OTP",
      "phoneSameAsBefore":
          "This phone number is already linked to your account.",
      "phoneChangeLimitExceeded":
          "You can only change your phone number once every 30 days.",
      "resendIn": "Resend in",
      "linkQRCode": "Link QR Code",
      "downloadQR": "Download QR",
      "accessCode": "Access Code",
      "pleaseEnterAccessCode": "Please enter an access code",
      "totalBalance": "Total Balance",
      "deposit": "Deposite",
      "buy": "Buy",
      "pickup": "Pickup",
      "newItems": "New Items",

      // English
    },
    'ar': {
      "aboutUs": "معلومات عنا",
      "locationPermissionDenied": "تم رفض إذن الموقع.",
      "goToSettingsToEnable": "يرجى تمكين الموقع من الإعدادات.",
      'termsOfUse': 'شروط الاستخدام',
      "support": "الدعم",
      "openAppleAccount": "افتح حساب Apple",
      "emailRequired": "البريد الإلكتروني مطلوب",
      "enterValidEmail": "يرجى إدخال بريد إلكتروني صالح",
      "passwordTooShort": "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل",
      "passwordsDoNotMatch": "كلمتا المرور غير متطابقتين",
      "userNotLoggedIn": "المستخدم غير مسجل الدخول",
      "enterPin": "يرجى إدخال رمز PIN",
      "addressDetails": "تفاصيل العنوان",
      "enterPinLink": "أدخل الرقم السري",
      "profileUpdated": "تم تحديث الملف الشخصي",
      "noLoggedInUser": "لم يتم العثور على مستخدم مسجل الدخول.",
      "verificationEmailSent":
          "تم إرسال بريد التحقق. يرجى التحقق لإكمال تغيير البريد الإلكتروني",
      "incorrectPassword": "كلمة المرور غير صحيحة",
      "emailInUse": "هذا البريد الإلكتروني مستخدم بالفعل.",
      "reloginTryAgain": "يرجى تسجيل الدخول مرة أخرى والمحاولة.",
      "errorOccurred": "حدث خطأ.",
      "unexpectedError": "حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.",
      "passwordUpdated": "تم تحديث كلمة المرور بنجاح.",
      "incorrectCurrentPassword": "كلمة المرور الحالية غير صحيحة.",
      "weakPassword": "كلمة المرور الجديدة ضعيفة جدًا.",
      "googleSignInFailed": "فشل تسجيل الدخول باستخدام Google",
      "locationServicesDisabled": "تم تعطيل خدمات الموقع.",
      "locationPermissionRequired": "مطلوب إذن الموقع لتحديد بلدك.",
      "accountCreated": "تم إنشاء الحساب بنجاح!",
      "noUserWithEmail": "لا يوجد مستخدم بهذا البريد الإلكتروني.",
      "invalidEmail": "عنوان البريد الإلكتروني غير صالح.",
      "userDisabled": "تم تعطيل هذا الحساب.",
      "signInFailed": "فشل في تسجيل الدخول",
      "signUpFailed": "فشل في إنشاء الحساب",
      "emailInvalid": "عنوان البريد الإلكتروني غير صالح",
      'settings': 'الإعدادات',
      'accountInfo': 'معلومات الحساب',
      'savedAddresses': 'العناوين المحفوظة',
      'changeEmail': 'تغيير البريد الإلكتروني',
      'changePassword': 'تغيير كلمة المرور',
      'notifications': 'الإشعارات',
      'language': 'اللغة',
      'country': 'الدولة',
      'logout': 'تسجيل الخروج',
      'disabled': 'معطل',
      'signIn': 'تسجيل الدخول',
      'signUp': 'التسجيل',
      'introText': 'لنبدأ...',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'createAccount': 'إنشاء حساب',
      'orSignUpWith': 'أو سجل باستخدام',
      'continueWithGoogle': 'المتابعة باستخدام جوجل',
      'continueWithApple': 'المتابعة باستخدام أبل',
      'continueWithFacebook': 'المتابعة باستخدام فيسبوك',
      'welcome': 'مرحباً',
      'edit': 'تعديل',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'dobOptional': 'تاريخ الميلاد (اختياري)',
      'genderOptional': 'الجنس (اختياري)',
      'male': 'ذكر',
      'female': 'أنثى',
      'receiveOffers': 'نعم، أود استلام العروض والخصومات',
      'subscribeNewsletter': 'الاشتراك في النشرة الإخبارية',
      'deleteAccount': 'حذف الحساب',
      'deleteAccountConfirmation':
          'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'newEmail': 'البريد الإلكتروني الجديد',
      'confirmEmail': 'تأكيد البريد الإلكتروني',
      'currentPassword': 'الرقم السري الحالي',
      'newPassword': 'الرقم السري الجديد',
      'logoutConfirmation': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      "searchDeliveryUpdates": "ابحث في تحديثات التوصيل",
      'change': 'تغيير',
      'reauthenticate': 'إعادة التحقق',
      'enterPassword': 'أدخل كلمة المرور',
      'accountDeleted': 'تم حذف الحساب بنجاح',
      'enterYourPin': 'أدخل الرقم السري الخاص بك',
      'pleaseEnterPin': 'يرجى إدخال الرقم السري',
      'incorrectPin': 'الرقم السري غير صحيح',
      'submit': 'إرسال',
      'active': 'نشط',
      "errorLoading": "خطأ في تحميل البيانات",
      "selectLanguage": "اختر لغة",
      "selectCountry": "اختر دولة",
      "noChanges": "لم يتم العثور على تغييرات",
      "delete": "حذف",
      "views": "المشاهدات",
      "from": "من:",
      "to": "إلى:",
      "privacyPolicy": "سياسة الخصوصية",
      'forgotPasswordTitle': 'إعادة تعيين كلمة المرور',
      'forgotPasswordSubtitle':
          'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور',
      'sendResetLink': 'إرسال رابط إعادة التعيين',
      'resetLinkSent': 'تم إرسال رابط إعادة التعيين بنجاح!',
      'backToSignIn': 'العودة إلى تسجيل الدخول',
      "locationPermissionPermanentlyDenied":
          "تم رفض إذن الموقع بشكل دائم. يرجى تمكينه من الإعدادات.",
      "locationFetchFailed": "فشل في جلب الموقع.",
      "storeRequired": "اسم المتجر مطلوب",
      "storeTitle": "معلومات المتجر",
      "enterPhoneNumberTitle": "أدخل رقم هاتفك",
      "enterOtpTitle": "أدخل رمز التحقق",
      "otpHint": "أدخل رمز التحقق المكون من 6 أرقام",
      "getOtpVia": "الحصول على رمز التحقق عبر",
      "sms": "رسالة نصية",
      "whatsapp": "واتساب",
      "sendOtp": "إرسال رمز التحقق",
      "verifyOtp": "تحقق من الرمز",
      "resendOtp": "إعادة إرسال رمز التحقق",
      "otpSentSuccess": "تم إرسال رمز التحقق بنجاح عبر",
      "otpVerifiedSuccess": "تم التحقق من الرمز بنجاح!",
      "otpInvalid": "رمز التحقق غير صحيح. يرجى المحاولة مرة أخرى.",
      "sendOtpFailed": "فشل في إرسال رمز التحقق: {error}",
      "verifyOtpFailed": "فشل في التحقق من الرمز: {error}",
      "phoneNumberAlreadyLinked": "رقم الهاتف هذا مرتبط بالفعل بحساب آخر.",
      "verifyPhoneTitle": "تحقق من رقم هاتفك للمتابعة",
      "invalidOtp": "رمز التحقق غير صالح. يرجى المحاولة مرة أخرى.",
      "enterOtp": "يرجى إدخال رمز التحقق",
      "phoneSameAsBefore": "رقم الهاتف هذا مرتبط بالفعل بحسابك.",
      "phoneChangeLimitExceeded":
          "يمكنك تغيير رقم الهاتف مرة واحدة فقط كل 30 يومًا.",
      "resendIn": "إعادة الإرسال خلال",
      "linkQRCode": "رمز الاستجابة السريعة للرابط",
      "downloadQR": "تحميل الرمز",
      "accessCode": "رمز الوصول",
      "pleaseEnterAccessCode": "Please enter lيرجى إدخال رمز الوصول",
      "totalBalance": "إجمالي الرصيد",
      "deposit": "إيداع",
      "buy": "شراء",
      "pickup": "استلام",
      "newItems": "أصناف جديدة",
    },
  };
}

class _FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const _FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<FFLocalizations> load(Locale locale) async {
    return FFLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<FFLocalizations> old) => false;
}
