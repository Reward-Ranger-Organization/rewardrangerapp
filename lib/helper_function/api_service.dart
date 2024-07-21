import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helper_function/utility.dart';
import '../model/sign_up_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token; // Variable to store the token

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        _token ??= await _getToken();
        logger.i('Interceptor TokenINTRECEPTOR: $_token');
        if (_token != null) {
          options.headers['token'] = _token;
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        _handleDioError(error);
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> signUpWithEmail(Map<String, dynamic> userData) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/signup';

    try {
      final Response response = await _dio.post(endpoint, data: userData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('Sign Up Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('Sign up failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> signUpWithPhone(Map<String, dynamic> userData) async {
    const String endpoint =
        'https://reward-ranger-backend.onrender.com/signup'; // Replace with your phone signup endpoint

    try {
      final Response response = await _dio.post(endpoint, data: userData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('Sign Up with Phone Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('Phone sign up failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/login';

    try {
      final Response response = await _dio.post(endpoint, data: credentials);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          logger.i('Login Response: ${responseData['data']}');
          await _saveToken(responseData['data']['token']);
          _token = responseData['data']['token']; // Update the token variable
          return responseData['data'];
        } else {
          throw Exception('Login failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> loginWithPhone({
    required String sessionInfo,
    required String otp,
  }) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/login';

    try {
      final Response response = await _dio.post(
        endpoint,
        data: {
          'session_info': sessionInfo,
          'otp': otp,
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          logger.i('Login Response: ${responseData['data']}');
          await _saveToken(responseData['data']['token']);
          _token = responseData['data']['token']; // Update the token variable
          return responseData['data'];
        } else {
          throw Exception('Login failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> sendVerificationCode({
    required String phoneNumber,
    required String recaptchaToken,
  }) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/send-verification-code';

    try {
      final Response response = await _dio.post(
        endpoint,
        data: {
          'phone_number': phoneNumber,
          'recaptcha_token': recaptchaToken,
        },
      );
      if (response.statusCode == 200) {
        logger.i('Verification code sent successfully: ${response.data}');
        return response.data;
      } else {
        throw Exception('Failed to send verification code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionInfo,
    required String otp,
  }) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/verify-otp';

    try {
      final Response response = await _dio.post(
        endpoint,
        data: {
          'session_info': sessionInfo,
          'otp': otp,
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          await _saveToken(responseData['data']['token']);
          _token = responseData['data']['token'];
          return responseData['data'];
        } else {
          throw Exception('OTP verification failed: ${responseData['message']}');
        }
      } else {
        throw Exception('OTP verification failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: 'token', value: token);
      _token = token; // Update the token variable
      logger.i('Token saved successfully');
    } catch (e) {
      logger.e('Failed to save auth token: $e');
      throw Exception('Failed to save auth token: $e');
    }
  }

  Future<String?> _getToken() async {
    try {
      if (_token == null) {
        final token = await _storage.read(key: 'token');
        logger.i('Token retrieved FROM GET TOKEN: $token');
        _token = token; // Update the token variable
      }
      return _token;
    } catch (e) {
      logger.e('Failed to get auth token: $e');
      throw Exception('Failed to get auth token: $e');
    }
  }

  Future<UserInfo?> getUserInfo() async {
    try {
      // Fetch the token using _getToken method
      String? token = await _getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      // Make the API call to fetch user info
      final response = await _dio.get(
        'https://reward-ranger-backend.onrender.com/api/me',
        options: Options(
          headers: {
            'token': token,
          },
        ),
      );

      // Parse the response and return UserInfo
      if (response.statusCode == 200 && response.data['status'] == true) {
        return UserInfo.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user info: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    } catch (e) {
      logger.e('Error fetching user info: $e');
      throw Exception('Error fetching user info: $e');
    }
  }

  Future<Map<String, dynamic>> postScore(int score) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/score';

    try {
      _token ??= await _getToken();
      if (_token == null) {
        logger.e('Token is not available');
        throw Exception('Token is not available');
      }

      logger.i('Posting score with token: $_token');
      final response = await _dio.post(
        endpoint,
        data: {'score': score},
        options: Options(
          headers: {'Authorization': 'Bearer $_token'},
        ),
      );
      if (response.statusCode == 200) {
        logger.i('Score posted successfully');
        return response.data;
      } else {
        throw Exception('Failed to update score with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> verifyEmail() async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/verify-email';

    try {
      _token ??= await _getToken();
      if (_token == null) {
        logger.e('Token is not available');
        throw Exception('Token is not available');
      }

      logger.i('Verifying email with token: $_token');
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {'token': _token},
        ),
      );
      if (response.statusCode == 200) {
        logger.i('Email verified successfully');
        return response.data;
      } else {
        throw Exception('Failed to verify email with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    const String endpoint = 'https://reward-ranger-backend.onrender.com/api/forgot-password';

    try {
      final Response response = await _dio.post(endpoint, data: {'email': email});
      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('Forgot Password Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('Forgot password failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> userQuery(String queryText) async {
    try {
      _token ??= await _getToken();
      if (_token == null) {
        logger.e('Token is not available');
        throw Exception('Token is not available');
      }

      const String userQueryEndpoint = 'https://reward-ranger-backend.onrender.com/api/user-query';

      final response = await _dio.post(
        userQueryEndpoint,
        data: {'query': queryText},
        options: Options(
          headers: {'token': _token},
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        logger.i('User Query Response: ${response.data}');
        return response.data;
      } else {
        throw Exception('Failed to fetch user query: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return {}; // Handle or return appropriate response
    } catch (e) {
      logger.e('Error fetching user query: $e');
      throw Exception('Error fetching user query: $e');
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      logger.e('DioException response data: ${e.response?.data}');
      throw Exception('Request failed: ${e.response?.data}');
    } else {
      logger.e('DioException message: ${e.message}');
      throw Exception('Request failed: ${e.message}');
    }
  }
}
