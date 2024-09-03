// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

void main() {
  setupFirebaseAuthMocks();

  late FirebaseAuth auth;

  const String kMockActionCode = '12345';
  const String kMockEmail = 'test@example.com';
  const String kMockPassword = 'passw0rd';
  const String kMockIdToken = '12345';
  const String kMockRawNonce = 'abcde12345';
  const String kMockAccessToken = '67890';
  const String kMockGithubToken = 'github';
  const String kMockCustomToken = '12345';
  const String kMockPhoneNumber = '5555555555';
  const String kMockVerificationId = '12345';
  const String kMockSmsCode = '123456';
  const String kMockLanguage = 'en';
  const String kMockOobCode = 'oobcode';
  const String kMockURL = 'http://www.example.com';
  const String kMockHost = 'www.example.com';
  const int kMockPort = 31337;

  final TestAuthProvider testAuthProvider = TestAuthProvider();
  final int kMockCreationTimestamp =
      DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch;
  final int kMockLastSignInTimestamp =
      DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

  final kMockUser = PigeonUserDetails(
    userInfo: PigeonUserInfo(
      uid: '12345',
      displayName: 'displayName',
      creationTimestamp: kMockCreationTimestamp,
      lastSignInTimestamp: kMockLastSignInTimestamp,
      isAnonymous: true,
      isEmailVerified: false,
    ),
    providerData: [
      {
        'providerId': 'firebase',
        'uid': '12345',
        'displayName': 'Flutter Test User',
        'photoUrl': 'http://www.example.com/',
        'email': 'test@example.com',
      }
    ],
  );

  late MockUserPlatform mockUserPlatform;
  late MockUserCredentialPlatform mockUserCredPlatform;
  late MockConfirmationResultPlatform mockConfirmationResultPlatform;
  late MockRecaptchaVerifier mockVerifier;
  late AdditionalUserInfo mockAdditionalUserInfo;
  late EmailAuthCredential mockCredential;

  MockFirebaseAuth mockAuthPlatform = MockFirebaseAuth();

  AuthenticationProvider _repo = AuthenticationProvider();

  group('$FirebaseAuth', () {
    PigeonUserDetails user;
    // used to generate a unique application name for each test
    var testCount = 0;

    setUp(() async {
      FirebaseAuthPlatform.instance = mockAuthPlatform = MockFirebaseAuth();

      // Each test uses a unique FirebaseApp instance to avoid sharing state
      final app = await Firebase.initializeApp(
        name: '$testCount',
        options: const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        ),
      );

      auth = FirebaseAuth.instanceFor(app: app);
      user = kMockUser;

      mockUserPlatform = MockUserPlatform(
          mockAuthPlatform, TestMultiFactorPlatform(mockAuthPlatform), user);
      mockConfirmationResultPlatform = MockConfirmationResultPlatform();
      mockAdditionalUserInfo = AdditionalUserInfo(
        isNewUser: false,
        username: 'flutterUser',
        providerId: 'testProvider',
        profile: <String, dynamic>{'foo': 'bar'},
      );
      mockCredential = EmailAuthProvider.credential(
        email: 'test',
        password: 'test',
      ) as EmailAuthCredential;
      mockUserCredPlatform = MockUserCredentialPlatform(
        FirebaseAuthPlatform.instance,
        mockAdditionalUserInfo,
        mockCredential,
        mockUserPlatform,
      );
      mockVerifier = MockRecaptchaVerifier();

      when(mockAuthPlatform.signInAnonymously())
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithCredential(any)).thenAnswer(
          (_) => Future<UserCredentialPlatform>.value(mockUserCredPlatform));

      when(mockAuthPlatform.currentUser).thenReturn(mockUserPlatform);

      when(mockAuthPlatform.instanceFor(
        app: anyNamed('app'),
        pluginConstants: anyNamed('pluginConstants'),
      )).thenAnswer((_) => mockUserPlatform);

      when(mockAuthPlatform.delegateFor(
        app: anyNamed('app'),
      )).thenAnswer((_) => mockAuthPlatform);

      when(mockAuthPlatform.setInitialValues(
        currentUser: anyNamed('currentUser'),
        languageCode: anyNamed('languageCode'),
      )).thenAnswer((_) => mockAuthPlatform);

      when(mockAuthPlatform.createUserWithEmailAndPassword(any, any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.getRedirectResult())
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithCustomToken(any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithEmailLink(any, any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithPhoneNumber(any, any))
          .thenAnswer((_) async => mockConfirmationResultPlatform);

      when(mockVerifier.delegate).thenReturn(mockVerifier.mockDelegate);

      when(mockAuthPlatform.signInWithPopup(any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.signInWithRedirect(any))
          .thenAnswer((_) async => mockUserCredPlatform);

      when(mockAuthPlatform.authStateChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      when(mockAuthPlatform.idTokenChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      when(mockAuthPlatform.userChanges()).thenAnswer((_) =>
          Stream<UserPlatform>.fromIterable(<UserPlatform>[mockUserPlatform]));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelFirebaseAuth.channel,
              (call) async {
        return <String, dynamic>{'user': user};
      });
    });

    // incremented after tests completed, in case a test may want to use this
    // value for an assertion (toString)
    tearDown(() => testCount++);

    setUp(() async {
      user = kMockUser;
      await auth.signInAnonymously();
    });

    group('signInWithEmailAndPassword()', () {
      test('should call delegate method', () async {
        final res = await auth.signInWithEmailAndPassword(
            email: kMockEmail, password: kMockPassword);
        print("🚀 ~ test ~ $res:");
        final isSignIn = _repo.signInWithEmailAndPassword(
            email: "email", password: "password");
        print("🚀 ~ test ~ $isSignIn:");
        verify(mockAuthPlatform.signInWithEmailAndPassword(
            kMockEmail, kMockPassword));
      });
    });

    test('toString()', () async {
      expect(
        auth.toString(),
        equals('FirebaseAuth(app: $testCount)'),
      );
    });
  });
}

class MockFirebaseAuth extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseAuthPlatform {
  @override
  Stream<UserPlatform?> userChanges() {
    return super.noSuchMethod(
      Invocation.method(#userChanges, []),
      returnValue: const Stream<UserPlatform?>.empty(),
      returnValueForMissingStub: const Stream<UserPlatform?>.empty(),
    );
  }

  @override
  Stream<UserPlatform?> idTokenChanges() {
    return super.noSuchMethod(
      Invocation.method(#idTokenChanges, []),
      returnValue: const Stream<UserPlatform?>.empty(),
      returnValueForMissingStub: const Stream<UserPlatform?>.empty(),
    );
  }

  @override
  Stream<UserPlatform?> authStateChanges() {
    return super.noSuchMethod(
      Invocation.method(#authStateChanges, []),
      returnValue: const Stream<UserPlatform?>.empty(),
      returnValueForMissingStub: const Stream<UserPlatform?>.empty(),
    );
  }

  @override
  FirebaseAuthPlatform delegateFor(
      {FirebaseApp? app, Persistence? persistence}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: TestFirebaseAuthPlatform(),
      returnValueForMissingStub: TestFirebaseAuthPlatform(),
    );
  }

  @override
  Future<UserCredentialPlatform> createUserWithEmailAndPassword(
    String? email,
    String? password,
  ) {
    return super.noSuchMethod(
      Invocation.method(#createUserWithEmailAndPassword, [email, password]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<ConfirmationResultPlatform> signInWithPhoneNumber(
    String? phoneNumber,
    RecaptchaVerifierFactoryPlatform? applicationVerifier,
  ) {
    return super.noSuchMethod(
      Invocation.method(
        #signInWithPhoneNumber,
        [phoneNumber, applicationVerifier],
      ),
      returnValue: neverEndingFuture<ConfirmationResultPlatform>(),
      returnValueForMissingStub:
          neverEndingFuture<ConfirmationResultPlatform>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential? credential,
  ) {
    return super.noSuchMethod(
      Invocation.method(#signInWithCredential, [credential]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String? token) {
    return super.noSuchMethod(
      Invocation.method(#signInWithCustomToken, [token]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
    String? email,
    String? password,
  ) {
    return super.noSuchMethod(
      Invocation.method(#signInWithEmailAndPassword, [email, password]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithPopup(AuthProvider? provider) {
    return super.noSuchMethod(
      Invocation.method(#signInWithPopup, [provider]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailLink(
    String? email,
    String? emailLink,
  ) {
    return super.noSuchMethod(
      Invocation.method(#signInWithEmailLink, [email, emailLink]),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<void> signInWithRedirect(AuthProvider? provider) {
    return super.noSuchMethod(
      Invocation.method(#signInWithRedirect, [provider]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<UserCredentialPlatform> signInAnonymously() {
    return super.noSuchMethod(
      Invocation.method(#signInAnonymously, []),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return super.noSuchMethod(
      Invocation.method(#signInAnonymously, [], {
        #currentUser: currentUser,
        #languageCode: languageCode,
      }),
      returnValue: TestFirebaseAuthPlatform(),
      returnValueForMissingStub: TestFirebaseAuthPlatform(),
    );
  }

  @override
  Future<UserCredentialPlatform> getRedirectResult() {
    return super.noSuchMethod(
      Invocation.method(#getRedirectResult, []),
      returnValue: neverEndingFuture<UserCredentialPlatform>(),
      returnValueForMissingStub: neverEndingFuture<UserCredentialPlatform>(),
    );
  }

  @override
  Future<void> setLanguageCode(String? languageCode) {
    return super.noSuchMethod(
      Invocation.method(#setLanguageCode, [languageCode]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<void> useAuthEmulator(String host, int port) {
    return super.noSuchMethod(
      Invocation.method(#useEmulator, [host, port]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<ActionCodeInfo> checkActionCode(String? code) {
    return super.noSuchMethod(
      Invocation.method(#checkActionCode, [code]),
      returnValue: neverEndingFuture<ActionCodeInfo>(),
      returnValueForMissingStub: neverEndingFuture<ActionCodeInfo>(),
    );
  }

  @override
  Future<void> confirmPasswordReset(String? code, String? newPassword) {
    return super.noSuchMethod(
      Invocation.method(#confirmPasswordReset, [code, newPassword]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String? email) {
    return super.noSuchMethod(
      Invocation.method(#checkActionCode, [email]),
      returnValue: neverEndingFuture<List<String>>(),
      returnValueForMissingStub: neverEndingFuture<List<String>>(),
    );
  }

  @override
  bool isSignInWithEmailLink(String? emailLink) {
    return super.noSuchMethod(
      Invocation.method(#isSignInWithEmailLink, [emailLink]),
      returnValue: false,
      returnValueForMissingStub: false,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(
    String? email, [
    ActionCodeSettings? actionCodeSettings,
  ]) {
    return super.noSuchMethod(
      Invocation.method(#sendPasswordResetEmail, [email, actionCodeSettings]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<void> sendSignInLinkToEmail(
    String? email,
    ActionCodeSettings? actionCodeSettings,
  ) {
    return super.noSuchMethod(
      Invocation.method(#sendSignInLinkToEmail, [email, actionCodeSettings]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<void> setSettings({
    bool? appVerificationDisabledForTesting,
    String? userAccessGroup,
    String? phoneNumber,
    String? smsCode,
    bool? forceRecaptchaFlow,
  }) {
    return super.noSuchMethod(
      Invocation.method(#setSettings, [
        appVerificationDisabledForTesting,
        userAccessGroup,
        phoneNumber,
        smsCode,
        forceRecaptchaFlow,
      ]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<void> setPersistence(Persistence? persistence) {
    return super.noSuchMethod(
      Invocation.method(#setPersistence, [persistence]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<void> signOut() {
    return super.noSuchMethod(
      Invocation.method(#signOut, [signOut]),
      returnValue: neverEndingFuture<void>(),
      returnValueForMissingStub: neverEndingFuture<void>(),
    );
  }

  @override
  Future<String> verifyPasswordResetCode(String? code) {
    return super.noSuchMethod(
      Invocation.method(#verifyPasswordResetCode, [code]),
      returnValue: neverEndingFuture<String>(),
      returnValueForMissingStub: neverEndingFuture<String>(),
    );
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Object? verificationCompleted,
    Object? verificationFailed,
    Object? codeSent,
    Object? codeAutoRetrievalTimeout,
    Duration? timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    String? autoRetrievedSmsCodeForTesting,
  }) {
    return super.noSuchMethod(
      Invocation.method(#verifyPhoneNumber, [], {
        #phoneNumber: phoneNumber,
        #verificationCompleted: verificationCompleted,
        #verificationFailed: verificationFailed,
        #codeSent: codeSent,
        #codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        #timeout: timeout,
        #forceResendingToken: forceResendingToken,
        #autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
      }),
      returnValue: neverEndingFuture<String>(),
      returnValueForMissingStub: neverEndingFuture<String>(),
    );
  }
}

class FakeFirebaseAuthPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebaseAuthPlatform {
  FakeFirebaseAuthPlatform({this.tenantId, this.customAuthDomain});

  @override
  String? tenantId;

  @override
  String? customAuthDomain;

  @override
  FirebaseAuthPlatform delegateFor(
      {required FirebaseApp app, Persistence? persistence}) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }
}

class MockUserPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestUserPlatform {
  MockUserPlatform(FirebaseAuthPlatform auth, MultiFactorPlatform multiFactor,
      PigeonUserDetails _user) {
    TestUserPlatform(auth, multiFactor, _user);
  }
}

class MockUserCredentialPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestUserCredentialPlatform {
  MockUserCredentialPlatform(
    FirebaseAuthPlatform auth,
    AdditionalUserInfo additionalUserInfo,
    AuthCredential credential,
    UserPlatform userPlatform,
  ) {
    TestUserCredentialPlatform(
      auth,
      additionalUserInfo,
      credential,
      userPlatform,
    );
  }
}

class MockConfirmationResultPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestConfirmationResultPlatform {
  MockConfirmationResultPlatform() {
    TestConfirmationResultPlatform();
  }
}

class TestConfirmationResultPlatform extends ConfirmationResultPlatform {
  TestConfirmationResultPlatform() : super('TEST');
}

class TestFirebaseAuthPlatform extends FirebaseAuthPlatform {
  TestFirebaseAuthPlatform() : super();

  void instanceFor({
    FirebaseApp? app,
    Map<dynamic, dynamic>? pluginConstants,
  }) {}

  @override
  FirebaseAuthPlatform delegateFor(
      {FirebaseApp? app, Persistence? persistence}) {
    return this;
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }
}

class MockRecaptchaVerifier extends Mock
    with MockPlatformInterfaceMixin
    implements TestRecaptchaVerifier {
  MockRecaptchaVerifier() {
    TestRecaptchaVerifier();
  }

  RecaptchaVerifierFactoryPlatform get mockDelegate {
    return MockRecaptchaVerifierFactoryPlatform();
  }

  @override
  RecaptchaVerifierFactoryPlatform get delegate {
    return super.noSuchMethod(
      Invocation.getter(#delegate),
      returnValue: MockRecaptchaVerifierFactoryPlatform(),
      returnValueForMissingStub: MockRecaptchaVerifierFactoryPlatform(),
    );
  }
}

class MockRecaptchaVerifierFactoryPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestRecaptchaVerifierFactoryPlatform {
  MockRecaptchaVerifierFactoryPlatform() {
    TestRecaptchaVerifierFactoryPlatform();
  }
}

class TestRecaptchaVerifier implements RecaptchaVerifier {
  TestRecaptchaVerifier() : super();

  @override
  void clear() {}

  @override
  RecaptchaVerifierFactoryPlatform get delegate =>
      TestRecaptchaVerifierFactoryPlatform();

  @override
  Future<int> render() {
    throw UnimplementedError();
  }

  @override
  String get type => throw UnimplementedError();

  @override
  Future<String> verify() {
    throw UnimplementedError();
  }
}

class TestRecaptchaVerifierFactoryPlatform
    extends RecaptchaVerifierFactoryPlatform {}

class TestAuthProvider extends AuthProvider {
  TestAuthProvider() : super('TEST');
}

class TestUserPlatform extends UserPlatform {
  TestUserPlatform(FirebaseAuthPlatform auth, MultiFactorPlatform multiFactor,
      PigeonUserDetails data)
      : super(auth, multiFactor, data);
}

class TestMultiFactorPlatform extends MultiFactorPlatform {
  TestMultiFactorPlatform(FirebaseAuthPlatform auth) : super(auth);
}

class TestUserCredentialPlatform extends UserCredentialPlatform {
  TestUserCredentialPlatform(
    FirebaseAuthPlatform auth,
    AdditionalUserInfo additionalUserInfo,
    AuthCredential credential,
    UserPlatform userPlatform,
  ) : super(
          auth: auth,
          additionalUserInfo: additionalUserInfo,
          credential: credential,
          user: userPlatform,
        );
}

class EmptyUserCredentialPlatform extends UserCredentialPlatform {
  EmptyUserCredentialPlatform() : super(auth: FirebaseAuthPlatform.instance);
}
