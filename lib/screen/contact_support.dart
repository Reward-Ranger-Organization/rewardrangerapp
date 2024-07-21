import 'package:flutter/material.dart';
import '../helper_function/api_service.dart'; // Import your ApiService
import '../helper_function/dialog.dart';
import '../widget/text_field.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final ApiService apiService = ApiService(); // Instantiate your ApiService

    void handleSubmit() async {
      // Validate the form (if needed)
      if (controller.text.isEmpty) {
        DialogUtil.showErrorSnackbar(context, 'Please enter your message');
        return;
      }

      // Call the userQuery API method
      try {
        final response = await apiService.userQuery(controller.text);
        // Handle the response as needed (e.g., show result in UI)
        DialogUtil.showSuccessSnackbar(context, 'User query successful');
        // Optionally, you can navigate to another screen or update state
      } catch (e) {
        DialogUtil.showErrorSnackbar(context, 'Failed to perform user query: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 219, 11, 11),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300,
                  child: CustomTextField(
                    controller: controller,
                    labelText: 'Enter your message',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: handleSubmit, // Call handleSubmit function
                child: const Text('Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
