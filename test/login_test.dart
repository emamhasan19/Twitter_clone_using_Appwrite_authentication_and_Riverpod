import 'package:flutter_test/flutter_test.dart';

import 'package:twitter_clone/features/auth/view/login_view.dart';

void main() {
  test("I wanna test email field", () {
    var result = EmailFieldValidator.validate("");
    expect(result, "Email can't be empty!");
  });

  test("I wanna test password field", () {
    var result = passwordValidator.passValidate("");
    expect(result, "Please enter password!");
  });
}
