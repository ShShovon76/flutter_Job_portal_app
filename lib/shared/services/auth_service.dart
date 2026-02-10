class AuthService {
  static bool isLoggedIn = false; // change to true to test
  static String? role; // 'job_seeker' or 'employer'

  static void loginAsJobSeeker() {
    isLoggedIn = true;
    role = 'job_seeker';
  }

  static void loginAsEmployer() {
    isLoggedIn = true;
    role = 'employer';
  }

  static void logout() {
    isLoggedIn = false;
    role = null;
  }
}
