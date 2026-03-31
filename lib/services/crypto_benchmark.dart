// lib/services/crypto_benchmark.dart
//
// Benchmark suite per le operazioni crittografiche dell'app.
// Ogni operazione viene eseguita 20 volte; i tempi vengono loggati
// con il prefisso TIMING_CRYPTO|<op>|<size>|<ms> per estrazione CSV.
//
// Raccolta log: flutter logs 2>&1 | grep "TIMING_" > crypto_timings.txt

import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart' as web3crypto;
import 'package:crypto/crypto.dart' as crypto;

import '../crypto/key_manager.dart';
import 'timing_logger.dart';

class CryptoBenchmark {
  static const int _iterations = 20;

  // Dimensioni payload da testare
  static const Map<String, int> _payloadSizes = {
    '10kb': 10 * 1024,
    '100kb': 100 * 1024,
    '500kb': 500 * 1024,
  };

  static Future<void> runAll() async {
    TimingLogger.clear();

    await _benchmarkAesGcm();
    await _benchmarkHkdf();
    await _benchmarkEcdhX25519();
    await _benchmarkKeyWrapFull();
    await _benchmarkEd25519Sign();
    await _benchmarkEd25519Verify();
    await _benchmarkSecp256k1Sign();

    TimingLogger.printCsv();
  }

  // AES-256-GCM: cifratura per payload da 10KB, 100KB, 500KB
  static Future<void> _benchmarkAesGcm() async {

    final aead = AesGcm.with256bits();
    final dek = await aead.newSecretKey();
    final rnd = Random.secure();

    for (final entry in _payloadSizes.entries) {
      final label = entry.key;
      final size = entry.value;
      final plaintext =
          Uint8List.fromList(List<int>.generate(size, (_) => rnd.nextInt(256)));
      final nonce = Uint8List.fromList(
          List<int>.generate(12, (_) => rnd.nextInt(256)));
      const recordId = 'benchmark-record-id';

      await TimingLogger.benchmark(
        'aes_encrypt',
        label,
        () async {
          await aead.encrypt(
            plaintext,
            secretKey: dek,
            nonce: nonce,
            aad: utf8.encode(recordId),
          );
        },
        iterations: _iterations,
      );
    }

    // AES-256-GCM decrypt (100KB)
    final size100k = 100 * 1024;
    final plaintext100k = Uint8List.fromList(
        List<int>.generate(size100k, (_) => rnd.nextInt(256)));
    final nonce100k = Uint8List.fromList(
        List<int>.generate(12, (_) => rnd.nextInt(256)));
    const recordId = 'benchmark-record-id';
    final encrypted = await aead.encrypt(
      plaintext100k,
      secretKey: dek,
      nonce: nonce100k,
      aad: utf8.encode(recordId),
    );
    final secretBox = SecretBox(
      encrypted.cipherText,
      nonce: nonce100k,
      mac: encrypted.mac,
    );

    await TimingLogger.benchmark(
      'aes_decrypt',
      '100kb',
      () async {
        await aead.decrypt(
          secretBox,
          secretKey: dek,
          aad: utf8.encode(recordId),
        );
      },
      iterations: _iterations,
    );
  }

  // HKDF-SHA256: derivazione KEK da URK
  static Future<void> _benchmarkHkdf() async {

    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final rnd = Random.secure();
    final ikm = SecretKey(
        Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256))));
    final salt =
        Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
    final info = utf8.encode('health-app:kek-device:v1');

    await TimingLogger.benchmark(
      'hkdf_sha256',
      'kek_derivation',
      () async {
        await hkdf.deriveKey(
          secretKey: ikm,
          nonce: salt,
          info: info,
        );
      },
      iterations: _iterations,
    );

    // HKDF via KeyManager reale (include lettura da secure storage alla prima call)
    await TimingLogger.benchmark(
      'hkdf_kek_device',
      'with_storage',
      () async {
        await KeyManager.deriveKekDevice();
      },
      iterations: _iterations,
    );
  }

  // ECDH X25519: shared secret
  static Future<void> _benchmarkEcdhX25519() async {

    final x = X25519();
    final aliceKp = await x.newKeyPair();
    final bobKp = await x.newKeyPair();
    final bobPub = await bobKp.extractPublicKey();

    await TimingLogger.benchmark(
      'ecdh_x25519',
      'shared_secret',
      () async {
        await x.sharedSecretKey(
          keyPair: aliceKp,
          remotePublicKey: bobPub,
        );
      },
      iterations: _iterations,
    );

    // generazione coppia effimera (parte del KEK wrap)
    await TimingLogger.benchmark(
      'x25519_keygen',
      'ephemeral',
      () async {
        await x.newKeyPair();
      },
      iterations: _iterations,
    );
  }

  // Key Wrap DEK completo: ECDH + HKDF + AES-GCM
  static Future<void> _benchmarkKeyWrapFull() async {

    final x = X25519();
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final aead = AesGcm.with256bits();
    final rnd = Random.secure();

    final recipientKp = await x.newKeyPair();
    final recipientPub = await recipientKp.extractPublicKey();
    final dekBytes =
        Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
    const recordId = 'benchmark-record-id';

    // wrap
    await TimingLogger.benchmark(
      'key_wrap_dek',
      'full_process',
      () async {
        final eph = await x.newKeyPair();
        final shared = await x.sharedSecretKey(
          keyPair: eph,
          remotePublicKey: recipientPub,
        );
        final kek = await hkdf.deriveKey(
          secretKey: shared,
          nonce: utf8.encode('wrap:v1'),
          info: utf8.encode('record:$recordId'),
        );
        final nonce =
            Uint8List.fromList(List<int>.generate(12, (_) => rnd.nextInt(256)));
        await aead.encrypt(
          dekBytes,
          secretKey: kek,
          nonce: nonce,
          aad: utf8.encode(recordId),
        );
      },
      iterations: _iterations,
    );

    // prepara dati reali per il benchmark di unwrap
    final ephKp = await x.newKeyPair();
    final ephPub = await ephKp.extractPublicKey();
    final shared0 = await x.sharedSecretKey(
        keyPair: ephKp, remotePublicKey: recipientPub);
    final kek0 = await hkdf.deriveKey(
      secretKey: shared0,
      nonce: utf8.encode('wrap:v1'),
      info: utf8.encode('record:$recordId'),
    );
    final nonce0 =
        Uint8List.fromList(List<int>.generate(12, (_) => rnd.nextInt(256)));
    final wrapBox = await aead.encrypt(
      dekBytes,
      secretKey: kek0,
      nonce: nonce0,
      aad: utf8.encode(recordId),
    );
    final recipientKpData = await recipientKp.extract();

    await TimingLogger.benchmark(
      'key_unwrap_dek',
      'full_process',
      () async {
        final shared = await x.sharedSecretKey(
          keyPair: recipientKpData,
          remotePublicKey: ephPub,
        );
        final kek = await hkdf.deriveKey(
          secretKey: shared,
          nonce: utf8.encode('wrap:v1'),
          info: utf8.encode('record:$recordId'),
        );
        await aead.decrypt(
          SecretBox(wrapBox.cipherText, nonce: nonce0, mac: wrapBox.mac),
          secretKey: kek,
          aad: utf8.encode(recordId),
        );
      },
      iterations: _iterations,
    );
  }

  // Ed25519: firma manifest
  static Future<void> _benchmarkEd25519Sign() async {

    final ed = Ed25519();
    final kp = await ed.newKeyPair();
    final rnd = Random.secure();

    // Manifesto tipico ~1KB
    final msg1k = Uint8List.fromList(
        List<int>.generate(1024, (_) => rnd.nextInt(256)));
    // Manifesto più grande ~5KB
    final msg5k = Uint8List.fromList(
        List<int>.generate(5 * 1024, (_) => rnd.nextInt(256)));

    await TimingLogger.benchmark(
      'ed25519_sign',
      '1kb',
      () async {
        await ed.sign(msg1k, keyPair: kp);
      },
      iterations: _iterations,
    );

    await TimingLogger.benchmark(
      'ed25519_sign',
      '5kb',
      () async {
        await ed.sign(msg5k, keyPair: kp);
      },
      iterations: _iterations,
    );
  }

  // Ed25519: verifica firma
  static Future<void> _benchmarkEd25519Verify() async {

    final ed = Ed25519();
    final kp = await ed.newKeyPair();
    final rnd = Random.secure();
    final msg = Uint8List.fromList(
        List<int>.generate(1024, (_) => rnd.nextInt(256)));
    final sig = await ed.sign(msg, keyPair: kp);
    final pub = await kp.extractPublicKey();

    // In cryptography 2.7.0, verify() prende solo message e signature.
    // La public key è già incorporata nell'oggetto Signature.
    await TimingLogger.benchmark(
      'ed25519_verify',
      '1kb',
      () async {
        await ed.verify(msg, signature: sig);
      },
      iterations: _iterations,
    );
  }

  // secp256k1: firma Ethereum (personal_sign)
  static Future<void> _benchmarkSecp256k1Sign() async {

    final rnd = Random.secure();
    // Genera chiave privata random per il benchmark
    final privKeyBytes =
        Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
    final ethKey = EthPrivateKey(privKeyBytes);

    // Simula: hash 32 byte (keccak256 del manifest) da firmare
    final payloadHash =
        Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));

    TimingLogger.benchmarkSync(
      'secp256k1_personal_sign',
      '32byte_hash',
      () {
        ethKey.signPersonalMessageToUint8List(payloadHash);
      },
      iterations: _iterations,
    );

    // Keccak256 hashing
    for (final entry in _payloadSizes.entries) {
      final label = entry.key;
      final size = entry.value;
      final data = Uint8List.fromList(
          List<int>.generate(size, (_) => rnd.nextInt(256)));

      TimingLogger.benchmarkSync(
        'keccak256',
        label,
        () {
          web3crypto.keccak256(data);
        },
        iterations: _iterations,
      );
    }

    // SHA-256 hashing
    for (final entry in _payloadSizes.entries) {
      final label = entry.key;
      final size = entry.value;
      final data = Uint8List.fromList(
          List<int>.generate(size, (_) => rnd.nextInt(256)));

      TimingLogger.benchmarkSync(
        'sha256',
        label,
        () {
          crypto.sha256.convert(data);
        },
        iterations: _iterations,
      );
    }
  }
}
