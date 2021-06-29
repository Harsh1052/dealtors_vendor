library flutter_images.validations;

String validateEmail(String value) {
  if (value.isEmpty) {
    // The form is empty
    return "Enter email address";
  }
  // This is just a regular expression for email addresses
  String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+";
  RegExp regExp = new RegExp(p);

  if (regExp.hasMatch(value)) {
    // So, the email is valid
    return null;
  }
  // The pattern of the email didn't match the regex above.
  return 'Email is not valid';
}
String empty(String value){
  if(value.isEmpty)
    {
      return "Enter value";
    }
    return null;
}
String mobileValidation(String value)
{
  if(value.isEmpty)
  {
    return "Enter mobile no" ;
  }
  else if(value.trim().length<10)
    {
      return "Enter valid mobile number";
    }
  else
  {
    return null;
  }
}