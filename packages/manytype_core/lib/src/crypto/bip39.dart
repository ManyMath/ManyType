import 'dart:typed_data';
import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// Generate a new 12-word BIP-39 mnemonic.
String generateMnemonic() {
  final mnemonic = Mnemonic.generate(
    Language.english,
    length: MnemonicLength.words12,
  );
  return mnemonic.sentence;
}

/// Parse a mnemonic string and derive a 64-byte seed.
/// Passphrase defaults to empty string (Anytype uses no passphrase).
Uint8List mnemonicToSeed(String mnemonic, {String passphrase = ''}) {
  final m =
      Mnemonic.fromSentence(mnemonic, Language.english, passphrase: passphrase);
  return Uint8List.fromList(m.seed);
}

/// Validate a mnemonic string (checksum + wordlist).
bool validateMnemonic(String mnemonic) {
  try {
    Mnemonic.fromSentence(mnemonic, Language.english);
    return true;
  } catch (_) {
    return false;
  }
}
