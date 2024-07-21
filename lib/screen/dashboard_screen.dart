import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rewardrangerapp/helper_function/dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../helper_function/api_service.dart';
import '../helper_function/utility.dart';
import '../model/quote_motivation.dart';
import '../model/sign_up_model.dart';
import '../service_locator.dart';
import '../widget/drawer_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  int _score = 0; // Local score variable
  String? _firstName = '';
  bool? _isVerified;
  String? _lastname;
  late Timer _timer;
  double _currentIndex = 0;
  bool _firstAnimationComplete = false;
  bool _quoteAnimationStarted = false;
  String _currentQuote = '';
  bool _isAnimating = false;
  UserInfo? _userInfo;

  final ApiService _apiService = locator<ApiService>();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _currentIndex = Random().nextInt(quotes.length).toDouble();
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _nextQuote();
    });
    _loadBannerAd();
    _loadRewardedAd();
    // Fetch user info after login

    // Initialize animation controller
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Initialize scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize color animation
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 255, 255, 255),
      end: const Color.fromARGB(255, 7, 230, 230),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();
  }

  void _toggleAnimation() {
    if (_isVerified == false) {
      _showAlertDialog('Please verify your email.');
      return; // Exit the function to avoid running the setState call
    }

    setState(() {
      _isAnimating = true;
    });

    // Play animation once and hide it after completion
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Verify'),
              onPressed: () {
                // Add your verify action here
                Navigator.of(context).pop();
                _verifyEmail();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyEmail() async {
    try {
      final result = await _apiService.verifyEmail();

      if (result['status'] == true) {
        setState(() {
          _isVerified = true;
        });
        // Show success snackbar only if the widget is still mounted
        if (mounted) {
          DialogUtil.showSuccessSnackbar(context, 'Verification Link has been sent to your email');
        }
      } else {
        // Show error snackbar only if the widget is still mounted
        if (mounted) {
          DialogUtil.showErrorSnackbar(context, 'Failed to verify email');
        }
      }
    } catch (e) {
      logger.e('Failed to verify email: $e');
      // Show error snackbar only if the widget is still mounted
      if (mounted) {
        DialogUtil.showErrorSnackbar(context, 'An error occurred while verifying email');
      }
    }
  }

  void _nextQuote() {
    setState(() {
      _currentIndex = Random().nextInt(quotes.length).toDouble(); // Get a random index
    });
  }

  void _previousQuote() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + quotes.length) % quotes.length;
    });
  }

  Future<void> _fetchUserInfo() async {
    try {
      UserInfo? userInfo = await _apiService.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _userInfo = userInfo;
          _score = userInfo.score; // Update the local score variable with the fetched score
          _firstName = userInfo.firstName;
          _isVerified = userInfo.isVerified;
          _lastname = userInfo.lastName;
        });
      }
    } catch (e) {
      logger.e('Failed to fetch user info: $e');
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
          print("Banner Ad Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Replace with your ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Rewarded Ad Loaded');
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          logger.f('User earned reward: ${reward.amount} ${reward.type}');
          _updateScore(100); // Update score by 100 for the rewarded ad
        },
      );

      _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AdWithoutView ad) {
          print('Rewarded Ad dismissed');
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
          print('Rewarded Ad failed to show: $error');
          ad.dispose();
          _loadRewardedAd();
        },
      );

      setState(() {
        _isRewardedAdReady = false;
      });
    } else {
      print('Rewarded Ad is not ready yet');
    }
  }

  void _updateScore(int increment) {
    setState(() {
      _score += increment;
      _controller.reset();
      _controller.forward();
    });
    _postScoreToApi(increment); // Post the updated score to the API
  }

  void _handleReferAndEarn() {
    const increment1 = 500; // Increment for Refer & Earn
    _updateScore(increment1); // Add increment for Refer & Earn
  }

  Future<void> _postScoreToApi(int increment) async {
    try {
      final response = await _apiService.postScore(increment);
      if (response['status']) {
        logger.f('Score updated successfully: ${response['message']}');
      } else {
        throw Exception('Failed to update score: ${response['message']}');
      }
    } catch (e) {
      print('Error posting score: $e');
      // Handle error (e.g., show snackbar)
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd.dispose();
    _controller.dispose(); // Dispose the animation controller
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.w('$_isVerified}');
    return Scaffold(
      drawerEdgeDragWidth: 100.0,
      drawer: DrawerScreen(
        firstName: _firstName ?? "",
        lastName: _lastname ?? "",
      ),
      drawerEnableOpenDragGesture: true,
      drawerScrimColor: Colors.black54,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(208, 6, 0, 42),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(223, 6, 0, 42),
        centerTitle: true,
        excludeHeaderSemantics: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Color.fromARGB(255, 9, 81, 115), // start with black
            //     Color.fromARGB(255, 57, 106, 252), // blue-ish
            //     Color.fromARGB(255, 154, 17, 255), // purple-ish
            //     Color.fromARGB(193, 220, 52, 2), // red
            //   ],
            //   stops: [0.0, 0.3, 0.6, 1.0], // begin with black and end with the blue-ish
            // ),
            ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _firstName == ""
                        ? const SizedBox(
                            height: 35,
                          )
                        : AnimatedTextKit(
                            isRepeatingAnimation: true,
                            animatedTexts: [
                              ColorizeAnimatedText(
                                'Welcome, $_firstName!',
                                textStyle: const TextStyle(
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                colors: [
                                  const Color.fromARGB(255, 0, 234, 255),
                                  Colors.blue,
                                  Colors.green,
                                  Colors.purple,
                                  Colors.red,
                                  Colors.deepPurple
                                ],
                                speed: const Duration(milliseconds: 600), // Adjust duration here
                              ),
                            ],
                            repeatForever: true,
                          ),
                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      height: 200.0, // The height of the AnimatedTextKit widget
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 70.0,
                          fontFamily: 'Canterbury',
                          color: Color.fromARGB(255, 0, 234, 255),
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            ScaleAnimatedText('Watch'),
                            ScaleAnimatedText('Earn'),
                            ScaleAnimatedText('Grow'),
                          ],
                          displayFullTextOnTap: true,
                          onFinished: () {
                            setState(() {
                              _firstAnimationComplete = true;
                            });
                          },
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ),

                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                // Icons.currency_exchange,
                                Icons.paid_outlined,
                                // Icons.assured_workload,
                                color: _colorAnimation.value,
                                size: 40,
                              ),
                              Text(
                                ' $_score',
                                //💵💸💰💲🎁💴💶💯🏦
                                style: TextStyle(
                                    color: _colorAnimation.value,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 130.0, // The height of the AnimatedTextKit widget
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Canterbury',
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textAlign: TextAlign.center, cursor: "  <",
                              curve: Curves.easeInOutCubic,
                              // curve: Curves.easeInOutCirc,
                              textStyle: const TextStyle(
                                color: Color.fromARGB(255, 0, 234, 255),
                              ),
                              _quoteAnimationStarted
                                  ? _currentQuote
                                  : quotes[_currentIndex.toInt()],
                              speed: const Duration(milliseconds: 100), // Adjust speed here
                            ),
                          ],
                          onFinished: () {
                            setState(() {
                              _quoteAnimationStarted = true;
                              _currentQuote = quotes[_currentIndex.toInt()]; // Update current quote
                            });
                          },
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ), // Display the current score

                    const SizedBox(height: 150.0),
                    // const Spacer(),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: _showRewardedAd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(20, 34, 74, 1),
                          // const Color.fromARGB(255, 132, 228, 16), // Background color
                          // minimumSize: const Size(200, 50), // Width and height
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8), // Horizontal padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Earn Coin',
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _toggleAnimation,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        elevation: WidgetStateProperty.all(0),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.only(
                            bottom: 20,
                          ),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.yellow, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.transparent,
                            width: 0,
                          ),
                        ),
                        child: Shimmer.fromColors(
                          period: const Duration(seconds: 2),
                          enabled: _score >= 600 ? true : false,
                          baseColor: const Color.fromARGB(255, 0, 43, 54),
                          highlightColor: const Color.fromARGB(255, 234, 234, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white, // Set to transparent to avoid double border
                                width: 2.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: const Text(
                              'REDEEM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            if (_isAnimating)
              Container(
                color: Colors.transparent.withOpacity(0.9), // Adjust opacity here (0.0 - 1.0)
                child: Center(
                  child: Lottie.asset('assets/animation/reward_animation.json'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
