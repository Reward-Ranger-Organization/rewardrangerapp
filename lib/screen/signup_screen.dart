import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rewardrangerapp/helper_function/api_service.dart';
import 'package:rewardrangerapp/screen/login_screen.dart';
import 'package:rewardrangerapp/screen/login_with_phone.dart';
import 'package:rewardrangerapp/widget/elevated_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUpPage extends StatefulWidget {
  final bool isPhoneAuth;

  const SignUpPage({Key? key, required this.isPhoneAuth}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final ApiService _apiService = ApiService();
  final Logger logger = Logger();
  String _selectedGender = '';
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'IN');
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> userData = {
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "gender": _selectedGender,
        "dob": DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd-MM-yyyy').parse(_dobController.text)),
        "city": _cityController.text,
      };

      if (widget.isPhoneAuth) {
        userData["phone"] = _phoneNumber.phoneNumber;
        logger.w("Phone NUM: ${_phoneNumber.phoneNumber}");
      } else {
        userData["email"] = _emailController.text;
        userData["password"] = _passwordController.text;
      }

      logger.i('Submitting data: $userData');

      try {
        final response = await (widget.isPhoneAuth
            ? _apiService.signUpWithPhone(userData)
            : _apiService.signUpWithEmail(userData));

        if (response['status'] == true) {
          logger.i('Sign up successful: ${response['message']}');
          _showSuccessSnackbar(response['message']);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    widget.isPhoneAuth ? const LoginWithPhone() : const Login(),
              ),
            );
          }
        } else {
          logger.e('Sign up failed: ${response['message']}');
          _showErrorSnackbar(response['message']);
        }
      } catch (e) {
        logger.e('Sign up failed: $e');
        _showErrorSnackbar(e.toString());
      }
    } else {
      logger.e('Form validation failed');
    }
  }

  void _showSuccessSnackbar(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _onDateSelected(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(args.value as DateTime);
      setState(() {
        _dobController.text = formatted;
      });
      Navigator.of(context).pop();
    }
  }

  void _showDatePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date of Birth'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.h,
            child: SfDateRangePicker(
              selectionColor: const Color.fromARGB(255, 10, 2, 160),
              onSelectionChanged: _onDateSelected,
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: DateTime.now(),
              headerStyle: const DateRangePickerHeaderStyle(
                textStyle: TextStyle(
                  color: Color.fromARGB(255, 128, 128, 138),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              monthViewSettings: const DateRangePickerMonthViewSettings(
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 149, 139, 139),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              selectionTextStyle: const TextStyle(color: Colors.white),
              todayHighlightColor: const Color.fromARGB(255, 221, 183, 183),
              backgroundColor: const Color.fromARGB(0, 255, 5, 5),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(height: 50.h),
              if (!widget.isPhoneAuth) ...[
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _phoneNumber = number;
                      });
                      // logger.f(number);
                      // logger.f(_phoneNumber);
                    },
                    selectorTextStyle: const TextStyle(color: Colors.white),
                    textFieldController: _phoneController,
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0.sp),
                      ),
                      labelText: 'Phone Number',
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0.sp),
                      hintText: 'Enter your phone number',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                      showFlags: true,
                      useEmoji: true,
                    ),
                    initialValue: _phoneNumber,
                    formatInput: false,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
              _buildTextFormField(
                controller: _firstNameController,
                labelText: 'First Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _lastNameController,
                labelText: 'Last Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildGenderButton(
                      gender: 'M',
                      icon: Icons.male,
                      label: 'Male',
                    ),
                    _buildGenderButton(
                      gender: 'F',
                      icon: Icons.female,
                      label: 'Female',
                    ),
                  ],
                ),
              ),
              _buildTextFormField(
                controller: _dobController,
                labelText: 'Date of Birth',
                readOnly: true,
                onTap: _showDatePickerDialog,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _cityController,
                labelText: 'City',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 50.h),
              CustomElevatedButton(
                onPressed: _submit,
                text: 'Sign Up',
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.isPhoneAuth
                          ? const LoginWithPhone()
                          : const Login(),
                    ),
                  );
                },
                child: const Text(
                  "Already have an account? Log in",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          labelText: labelText,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderButton({
    required String gender,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: () => _selectGender(gender),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon,
              color: _selectedGender == gender ? Colors.blue : Colors.grey),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color:
                      _selectedGender == gender ? Colors.blue : Colors.grey)),
        ],
      ),
    );
  }
}
