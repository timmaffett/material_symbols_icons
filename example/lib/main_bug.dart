// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // prevent engine from removing query url parameters
  setUrlStrategy(const PathUrlStrategy());
}
