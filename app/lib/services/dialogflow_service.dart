import 'package:flutter/services.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as df;

class DialogflowService {
  df.DialogFlowtter? dialogFlowtter;

  Future<void> initialize() async {
    try {
      // Load the key file
      dialogFlowtter = await df.DialogFlowtter.fromFile(
        path: "assets/dialog_flow_auth.json",
      );
    } catch (e) {
      print('Dialogflow initialization error: $e');
      rethrow;
    }
  }

  Future<String> getResponse(String query) async {
    try {
      if (dialogFlowtter == null) {
        throw Exception('Dialogflow not initialized');
      }

      // Call Dialogflow
      final response = await dialogFlowtter!.detectIntent(
        queryInput: df.QueryInput(
          text: df.TextInput(
            text: query,
            languageCode: 'en',
          ),
        ),
      );

      // Return the response directly in English
      final message = response.text;
      return message ?? 'Sorry, I don\'t understand.';
    } catch (e) {
      print('Dialogflow response error: $e');
      return 'Sorry, something went wrong. Please try again later.';
    }
  }

  void dispose() {
    dialogFlowtter?.dispose();
  }
}
