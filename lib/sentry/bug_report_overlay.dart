// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class FeedbackOverlay {
  static final FeedbackOverlay _instance = FeedbackOverlay._internal();
  factory FeedbackOverlay() => _instance;

  FeedbackOverlay._internal();

  late OverlayEntry _overlayEntry;
  bool isShown = true;

  String _name = '';
  String _description = '';

  void show(
    BuildContext context, {
    required bool isSent,
    // required Function(String, String) onChanged,
    required VoidCallback onSubmit,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Material(
          color: Colors.black.withOpacity(0.1),
          child: Center(
            child: Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              width: 320.0, // Adjust width based on screen size if needed
              height: 250, // Adjust height based on screen size if needed
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // To wrap content and not stretch unnecessarily
                children: isSent
                    ? [
                        const Text('Thank you for your feedback!'),
                        const SizedBox(height: 20),
                        const Icon(Icons.done),
                      ]
                    : [
                        const Text('Report an issue'),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (val) {
                            _name = val;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Full name',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (val) {
                            _description = val;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Give full description',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            isSent = true;
                            _submitFeedback();
                            onSubmit();
                          },
                          child: const Text('Submit'),
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
    // Insert the overlay entry into the Overlay
    Overlay.of(context).insert(_overlayEntry);
    // isShown = true;
  }

  void _submitFeedback() {
    print('🚀 Name: $_name');
    print('🚀 Description: $_description');
  }

  // Method to hide the feedback panel
  void hide() {
    // if (isShown) {
    _overlayEntry.remove();
    // isShown = false;
    // }
  }
}
