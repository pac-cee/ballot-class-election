import 'package:flutter/material.dart';

import 'app.dart';
import 'state/election_controller.dart';

void main() {
  runApp(BallotApp(controller: ElectionController.withSamples()));
}
