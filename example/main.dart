import 'package:your_package/flute.dart';

final flute = Flute();

@override
void initState() {
  super.initState();
  flute.init(440.0);
  flute.noteOn(440.0, 0.7);
}

