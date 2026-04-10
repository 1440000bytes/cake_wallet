import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:cw_core/utils/print_verbose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:zkool/src/rust/api/account.dart' as zkool_account;
import 'package:zkool/src/rust/api/coin.dart' as zkool_coin;
import 'package:zkool/src/rust/api/sync.dart' as zkool_sync;
import 'package:zkool/src/rust/api/pay.dart' as zkool_pay;
import 'package:zkool/src/rust/api/key.dart' as zkool_key;
import 'package:zkool/src/rust/api/network.dart' as zkool_network;
import 'package:zkool/src/rust/pay.dart' as zkool_paydart;
import 'package:zkool/src/rust/frb_generated.dart' as zkool_frb;

const DAY_SEC = 24 * 3600;
const DAY_MS = DAY_SEC * 1000;
const DEFAULT_ACCOUNT = 1;

class Backup {
  Backup({this.seed, this.index = 0, this.sk = '', this.fvk = '', this.uvk = '', this.tsk = ''});

  final String? seed;
  final int index;
  final String sk;
  final String fvk;
  final String uvk;
  final String tsk;
}

class PoolBalance {
  PoolBalance({this.transparent = 0, this.sapling = 0, this.orchard = 0});

  final int transparent;
  final int sapling;
  final int orchard;

  PoolBalance unpack() => this;
}

class FeeT {
  FeeT({required this.fee, required this.minFee, required this.maxFee, required this.scheme});

  final int fee;
  final int minFee;
  final int maxFee;
  final int scheme;
}

class TxReport {
  TxReport();
}

class PaymentUri {
  PaymentUri({this.address, this.amount, this.memo});

  final String? address;
  final int? amount;
  final String? memo;
}

class SwapT {
  SwapT();
}

class RaptorQresultT {
  RaptorQresultT();
}

class ShieldedNote {
  ShieldedNote();
}

class Balance {
  Balance();
}

class Height {
  Height({this.pool = 0, this.height = 0, this.time = 0});

  final int pool;
  final int height;
  final int time;

  Height unpack() => this;
}

class Recipient {
  Recipient({
    required this.address,
    required this.amount,
    this.pools,
    this.feeIncluded = false,
    this.replyTo = false,
    this.memo,
  });

  factory Recipient.fromBytes(final List<int> bytes) {
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return Recipient(
      address: map['address']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      pools: (map['pools'] as num?)?.toInt(),
      feeIncluded: map['feeIncluded'] == true,
      replyTo: map['replyTo'] == true,
      memo: map['memo']?.toString(),
    );
  }

  final String address;
  final int amount;
  final int? pools;
  final bool feeIncluded;
  final bool replyTo;
  final String? memo;

  List<int> toBytes() => utf8.encode(
    jsonEncode({
      'address': address,
      'amount': amount,
      'pools': pools,
      'feeIncluded': feeIncluded,
      'replyTo': replyTo,
      'memo': memo,
    }),
  );
}

class Agekeys {
  Agekeys();
}

class KeyPack {
  KeyPack();
}

class Account {
  Account({required this.id, required this.name});

  factory Account.fromBytes(final List<int> bytes) {
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return Account(id: (map['id'] as num?)?.toInt() ?? 0, name: map['name']?.toString() ?? '');
  }

  final int id;
  final String name;

  Account unpack() => this;
  dynamic get pack => null;

  List<int> toBytes() => utf8.encode(jsonEncode({'id': id, 'name': name}));

  @override
  String toString() {
    return "Account(id: $id, name: $name)";
  }
}

class ShieldedTx {
  ShieldedTx({
    required this.id,
    this.txId,
    this.shortTxId,
    required this.height,
    required this.timestamp,
    this.name,
    required this.value,
    this.address,
    this.memo = '',
  });

  factory ShieldedTx.fromBytes(final List<int> bytes) {
    final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ShieldedTx(
      id: (map['id'] as num?)?.toInt() ?? 0,
      txId: map['txId']?.toString(),
      shortTxId: map['shortTxId']?.toString(),
      height: (map['height'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString(),
      value: (map['value'] as num?)?.toInt() ?? 0,
      address: map['address']?.toString(),
      memo: map['memo']?.toString() ?? '',
    );
  }

  final int id;
  final String? txId;
  final String? shortTxId;
  final int height;
  final int timestamp;
  final String? name;
  int value;
  final String? address;
  String? memo;

  ShieldedTx unpack() => this;
  dynamic get pack => null;

  List<int> toBytes() => utf8.encode(
    jsonEncode({
      'id': id,
      'txId': txId,
      'shortTxId': shortTxId,
      'height': height,
      'timestamp': timestamp,
      'name': name,
      'value': value,
      'address': address,
      'memo': memo,
    }),
  );

  @override
  String toString() {
    return "ShieldedTx(id: $id, txId: $txId, shortTxId: $shortTxId, height: $height, timestamp: $timestamp, name: $name, value: $value, address: $address, memo: $memo)";
  }
}

class RecipientObjectBuilder {
  RecipientObjectBuilder({
    required this.address,
    required this.amount,
    this.pools,
    this.feeIncluded = false,
    this.replyTo = false,
    this.memo,
  });

  final String address;
  final int amount;
  final int? pools;
  final bool feeIncluded;
  final bool replyTo;
  final String? memo;

  List<int> toBytes() => Recipient(
    address: address,
    amount: amount,
    pools: pools,
    feeIncluded: feeIncluded,
    replyTo: replyTo,
    memo: memo,
  ).toBytes();
}

class Message {
  Message();
}

class ContactT {
  ContactT();
}

class PrevNext {
  PrevNext();
}

class Contact {
  Contact();
}

class TxTimeValue {
  TxTimeValue();
}

class Spending {
  Spending();
}

class Checkpoint {
  Checkpoint();
}

class SyncParams {
  SyncParams();
}

class PaymentParams {
  PaymentParams();
}

class SignOnlyParams {
  SignOnlyParams();
}

class TransferPoolsParams {
  TransferPoolsParams();
}

class SyncHistoricalPricesParams {
  SyncHistoricalPricesParams();
}

class GetTBalanceParams {
  GetTBalanceParams();
}

class BlockHeightByTimeParams {
  BlockHeightByTimeParams();
}

class WarpApi {
  static const int _zcashCoinId = 0;
  static int _k(final int _coin) => _zcashCoinId;
  static String? _dbPassword;
  static String? _dbPath;
  static String _lwdUrl = 'http://127.0.0.1:9067';
  static zkool_coin.Coin _coin = zkool_coin.Coin();
  static bool _isDbOpen = false;
  static int _lastKnownSyncHeight = 0;
  static final Map<String, zkool_pay.PcztPackage> _preparedPlans = {};
  static PoolBalance _poolBalanceCache = PoolBalance();
  static final Map<String, List<ShieldedTx>> _txCache = {};
  static List<Account> _accountCache = <Account>[];
  static final Map<String, Backup> _backupCache = {};
  static final Map<String, String> _addressCache = {};
  static bool _isGlobalInit = false;
  static Future<void> globalInit() async {
    if (_isGlobalInit) return;
    _isGlobalInit = true;
    await zkool_frb.RustLib.init();
  }

  static Future<void> openAccount({final int coin = 0, required final int account}) async {
    final account = _coin.account;
    _coin = await _coinForAccount(coin, account);
    await _refreshAddresses(coin, account);
  }

  static String _hex(final List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Future<String> _encodePlan(final zkool_pay.PcztPackage package) async {
    final packed = await zkool_pay.packTransaction(pczt: package);
    // Keep both in-memory and serialized fallback for compatibility.
    final key = DateTime.now().microsecondsSinceEpoch.toString();
    _preparedPlans[key] = package;
    return jsonEncode({'key': key, 'packed': base64Encode(packed)});
  }

  static Future<zkool_pay.PcztPackage> _decodePlan(final String plan) async {
    try {
      final decoded = jsonDecode(plan);
      if (decoded is Map<String, dynamic>) {
        final key = decoded['key']?.toString();
        if (key != null && _preparedPlans.containsKey(key)) {
          return _preparedPlans[key]!;
        }
        final packedB64 = decoded['packed']?.toString();
        if (packedB64 != null && packedB64.isNotEmpty) {
          final bytes = base64Decode(packedB64);
          return zkool_pay.unpackTransaction(bytes: bytes);
        }
      }
    } catch (_) {}
    throw UnimplementedError('Unsupported tx plan format');
  }

  static Future<zkool_coin.Coin> _ensureCoin(final int coin) async {
    await globalInit();
    if (!_isDbOpen) {
      if (_dbPath == null || _dbPath!.isEmpty) {
        throw Exception('Wallet DB path is not initialized');
      }
      _coin = await _coin.openDatabase(dbFilepath: _dbPath!, password: _dbPassword);
      _isDbOpen = true;
    }
    _coin = _coin.setLwd(url: _normalizeLwdUrl(_lwdUrl), serverType: 0);
    return _coin;
  }

  static Future<zkool_coin.Coin> _coinForAccount(final int coin, final int account) async {
    final c = await _ensureCoin(coin);
    return c.setAccount(account: account);
  }

  static String _txCacheKey(final int coin, final int account) => '${_k(coin)}:$account';
  static String _backupCacheKey(final int coin, final int account) => '${_k(coin)}:$account';
  static String _addrCacheKey(final int coin, final int account, final int uaType) =>
      '${_k(coin)}:$account:$uaType';
  static String _normalizeLwdUrl(final String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return 'http://127.0.0.1:9067';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }

  static Future<void> _refreshAccounts(final int coin) async {
    final c = await _ensureCoin(coin);
    final list = await zkool_account.listAccounts(c: c);
    _accountCache = list.map((final a) => Account(id: a.id, name: a.name)).toList();
  }

  static Future<void> refreshAccounts(final int coin) async {
    await _refreshAccounts(coin);
  }

  static Future<void> _refreshBackup(final int coin, final int id) async {
    final c = await _coinForAccount(coin, id);
    final seed = await zkool_account.getAccountSeed(account: id, c: c);
    String uvk = '';
    try {
      uvk = await zkool_account.getAccountUfvk(account: id, pools: 7, c: c);
    } catch (e) {
      // Some accounts (e.g. transparent-only rotation accounts) do not expose
      // shielded receivers, so UFVK lookup can fail. Keep backup metadata with
      // seed/index and continue.
      printV('getAccountUfvk failed for account $id: $e');
    }
    _backupCache[_backupCacheKey(coin, id)] = Backup(
      seed: seed?.mnemonic,
      index: seed?.aindex ?? 0,
      sk: '',
      fvk: uvk,
      uvk: uvk,
      tsk: '',
    );
  }

  static Future<void> _refreshSeedOnly(final int coin, final int id) async {
    final c = await _coinForAccount(coin, id);
    final seed = await zkool_account.getAccountSeed(account: id, c: c);
    final existing = _backupCache[_backupCacheKey(coin, id)];
    _backupCache[_backupCacheKey(coin, id)] = Backup(
      seed: seed?.mnemonic,
      index: seed?.aindex ?? 0,
      sk: existing?.sk ?? '',
      fvk: existing?.fvk ?? '',
      uvk: existing?.uvk ?? '',
      tsk: existing?.tsk ?? '',
    );
  }

  static Future<void> refreshAccountCache(final int coin, final int id) async {
    await _refreshBackup(coin, id);
    await _refreshAddresses(coin, id);
    await _refreshPoolBalance(coin, id);
    await _refreshTxs(coin, id);
  }

  static Future<void> refreshTransparentAccountCache(final int coin, final int id) async {
    await _refreshSeedOnly(coin, id);
    await _refreshTransparentAddresses(coin, id);
    await _refreshPoolBalance(coin, id);
    await _refreshTxs(coin, id);
  }

  static Future<void> _refreshAddresses(final int coin, final int id) async {
    final c = await _coinForAccount(coin, id);
    final addrs = await zkool_account.getAddresses(uaPools: 7, c: c);
    _addressCache[_addrCacheKey(coin, id, 0)] = addrs.taddr ?? '';
    _addressCache[_addrCacheKey(coin, id, 2)] = addrs.saddr ?? '';
    _addressCache[_addrCacheKey(coin, id, 4)] = addrs.oaddr ?? '';
    _addressCache[_addrCacheKey(coin, id, 6)] = addrs.ua ?? '';
    _addressCache[_addrCacheKey(coin, id, 7)] = addrs.ua ?? '';
  }

  static Future<void> _refreshTransparentAddresses(final int coin, final int id) async {
    final c = await _coinForAccount(coin, id);
    final addrs = await zkool_account.getAddresses(uaPools: 1, c: c);
    _addressCache[_addrCacheKey(coin, id, 0)] = addrs.taddr ?? '';
  }

  static Future<void> _refreshPoolBalance(final int coin, final int account) async {
    final c = await _coinForAccount(coin, account);
    final b = await zkool_sync.balance(c: c);
    final vals = b.field0;
    _poolBalanceCache = PoolBalance(
      transparent: vals.isNotEmpty ? vals[0].toInt() : 0,
      sapling: vals.length > 1 ? vals[1].toInt() : 0,
      orchard: vals.length > 2 ? vals[2].toInt() : 0,
    );
  }

  static Future<void> _refreshTxs(final int coin, final int account) async {
    final c = await _coinForAccount(coin, account);
    final txs = await zkool_account.listTxHistory(c: c);
    _txCache[_txCacheKey(coin, account)] = txs.map((final t) {
      final txid = _hex(t.txid);
      return ShieldedTx(
        id: t.id,
        txId: txid,
        shortTxId: txid.length >= 8 ? txid.substring(0, 8) : txid,
        height: t.height,
        timestamp: t.time,
        value: t.value.toInt(),
      );
    }).toList();
  }

  static int _recipientAmount(final dynamic amount) {
    if (amount is int) return amount;
    if (amount is BigInt) return amount.toInt();
    return 0;
  }

  // - == === API below === == -

  static Future<String?> get platformVersion => Future.value(null);

  static DynamicLibrary open() {
    throw UnimplementedError("No need to .open()");
  }

  static void migrateWallet(final int coin, final String dbPath) {
    throw UnimplementedError();
  }

  static void migrateData(final int coin) {
    // no-op migration hook for compatibility.
  }

  static void initProver(final Uint8List spend, final Uint8List output) {
    // zkool handles proving context internally for this integration.
  }

  static void initWallet(final int coin, final String dbPath) {
    if (_isDbOpen) {
      if (dbPath != dbPath) {
        throw Exception("Tried to open different DB! This is unsupported");
      }
      return;
    }
    _dbPath = dbPath;
    _isDbOpen = false;
    _coin = zkool_coin.Coin();
  }

  static void mempoolRun(final int port) {
    throw UnimplementedError();
  }

  static Future<int> newAccount(
    final int coin,
    final String name,
    String key,
    final int index, {
    final int? birthHeight,
    final bool transparentOnly = false,
    String? passphrase,
  }) async {
    if (passphrase == null) {
      final seedWords = key.split(" ");
      if ([13, 25].contains(seedWords.length)) {
        passphrase = seedWords.removeLast();
        key = seedWords.join(" ");
      }
    }
    final c = await _ensureCoin(coin);
    final id = await zkool_account.newAccount(
      na: zkool_account.NewAccount(
        name: name,
        restore: true,
        key: key,
        passphrase: passphrase,
        aindex: index,
        birth: birthHeight ?? 3400000,
        folder: '',
        useInternal: true,
        internal: false,
        ledger: false,
      ),
      c: c,
    );
    final currentId = _coin.account;
    _coin = await c.setAccount(account: id);
    await _refreshAccounts(coin);
    await refreshTransparentAccountCache(coin, id);
    await _refreshPoolBalance(coin, id);
    await _refreshTxs(coin, id);
    await _refreshBackup(coin, id);
    await _refreshSeedOnly(coin, id);
    _coin = await c.setAccount(account: currentId);
    return id;
  }

  static String ledgerGetFVK(final int coin) {
    throw UnimplementedError();
  }

  static void convertToWatchOnly(final int coin, final int id) {
    throw UnimplementedError();
  }

  static Backup getBackup(final int coin, final int id) {
    final key = _backupCacheKey(coin, id);
    return _backupCache[key] ?? Backup();
  }

  static void setBackupReminder(final int coin, final int id, final bool v) {
    throw UnimplementedError();
  }

  static String getAddress(final int coin, final int id, final int uaType) {
    final key = _addrCacheKey(coin, id, uaType);
    return _addressCache[key] ?? '';
  }

  static int receiversOfAddress(final int coin, final String address) {
    throw UnimplementedError();
  }

  static void importTransparentPath(final int coin, final int id, final String path) {
    throw UnimplementedError();
  }

  static void importTransparentSecretKey(final int coin, final int id, final String key) {
    throw UnimplementedError();
  }

  static void importFromZWL(final int coin, final String name, final String path) {
    throw UnimplementedError();
  }

  static Future<void> skipToLastHeight(final int coin) async {
    throw UnimplementedError();
  }

  static int rewindTo(final int coin, final int height) {
    throw UnimplementedError();
  }

  static int rescanFrom(final int coin, final int height) {
    _lastKnownSyncHeight = height;
    return 0;
  }

  static Future<int> warpSync(
    final int coin,
    final int account,
    final bool getTx,
    final int anchorOffset,
    final int maxCost,
    final int port,
  ) async {
    final c = await _coinForAccount(coin, account);
    final currentHeight = await zkool_network.getCurrentHeight(c: c);
    int? lastLoggedHeight;
    int? lastLoggedTime;
    await for (final progress in zkool_sync.synchronize(
      accounts: [account],
      currentHeight: currentHeight,
      actionsPerSync: 10000,
      transparentLimit: 100,
      checkpointAge: 200,
      c: c,
      fast: true,
    )) {
      if (progress.height != lastLoggedHeight || progress.time != lastLoggedTime) {
        printV("warpSync progress: ${progress.height} / ${progress.time}");
        lastLoggedHeight = progress.height;
        lastLoggedTime = progress.time;
      }
      _lastKnownSyncHeight = progress.height;
    }
    try {
      // Ensure cached DB height reflects final sync state even when no final
      // progress event is emitted by the sync stream.
      final db = await zkool_sync.getDbHeight(c: c);
      _lastKnownSyncHeight = db.height;
    } catch (_) {
      if (_lastKnownSyncHeight <= 0) {
        _lastKnownSyncHeight = currentHeight;
      }
    }
    await _refreshAccounts(coin);
    await _refreshBackup(coin, account);
    await _refreshAddresses(coin, account);
    await _refreshPoolBalance(coin, account);
    await _refreshTxs(coin, account);
    return 0;
  }

  static void cancelSync() {
    zkool_sync.cancelSync();
  }

  static Future<bool> transparentSync(final int coin, final int account, final int height) async {
    await warpSync(coin, account, true, 0, 0, 0);
    await _refreshPoolBalance(coin, account);
    return true;
  }

  static Future<int> getLatestHeight(final int coin) async {
    final c = await _ensureCoin(coin);
    final chain = await zkool_network.getCurrentHeight(c: c);
    try {
      final db = await zkool_sync.getDbHeight(c: c);
      _lastKnownSyncHeight = db.height;
    } catch (e) {
      printV(e);
    }
    return chain;
  }

  static bool validSeed(final int coin, final String seed) {
    throw UnimplementedError();
  }

  static int validKey(final int coin, final String key) {
    throw UnimplementedError();
  }

  static bool validAddress(final int coin, final String address) {
    if (!_isGlobalInit) {
      return address.startsWith('u1') ||
          address.startsWith('zs') ||
          address.startsWith('t1') ||
          address.startsWith('t3');
    }
    return zkool_key.isValidAddress(address: address);
  }

  static String getDiversifiedAddress(
    final int coin,
    final int account,
    final int uaType,
    final int time,
  ) {
    return getAddress(coin, account, uaType);
  }

  static bool checkAccount(final int coin, final int account) {
    throw UnimplementedError();
  }

  // static Future<String> sendPayment(
  //     int coin,
  //     int account,
  //     List<Recipient> recipients,
  //     bool useTransparent,
  //     int anchorOffset,
  //     void Function(int) f) async {
  //   throw UnimplementedError();
  // }

  static PoolBalance getPoolBalances(
    final int coin,
    final int account,
    final int confirmations,
    final bool include_unconfirmed,
  ) {
    return _poolBalanceCache;
  }

  static Future<int> getTBalance(final int coin, final int account) async {
    final balances = getPoolBalances(coin, account, 0, true);
    return balances.transparent;
  }

  static Future<int> getTBalanceAsync(final int coin, final int account) async {
    throw UnimplementedError();
  }

  static Future<String> transferPools(
    final int coin,
    final int account,
    final int fromPool,
    final int toPool,
    final int amount,
    final bool includeFee,
    final String memo,
    final int splitAmount,
    final int anchorOffset,
    final FeeT fee,
  ) async {
    throw UnimplementedError();
  }

  // static String shieldTAddr(
  //     int coin, int account, int amount, int anchorOffset, FeeT fee) {
  //   final fee2 = encodeFee(fee);
  //   final txPlan = warp_api_lib.shield_taddr(coin, account, amount,
  //       anchorOffset, toNativeBytes(fee2), fee2.lengthInBytes);
  //   return unwrapResultString(txPlan);
  // }

  static Future<String> prepareTx(
    final int coin,
    final int account,
    final List<Recipient> recipients,
    final int pools,
    final int senderUAType,
    final int anchorOffset,
    final FeeT fee,
  ) async {
    final c = await _coinForAccount(coin, account);
    final typedRecipients = recipients.map((final r) {
      final d = r as dynamic;
      return zkool_paydart.Recipient(
        address: (d.address ?? '').toString(),
        amount: BigInt.from(_recipientAmount(d.amount)),
        pools: d.pools as int?,
        userMemo: d.memo as String?,
      );
    }).toList();
    final pczt = await zkool_pay.prepare(
      recipients: typedRecipients,
      options: zkool_pay.PaymentOptions(
        srcPools: pools,
        recipientPaysFee: true,
        smartTransparent: false,
      ),
      c: c,
    );
    return _encodePlan(pczt);
  }

  static TxReport transactionReport(final int coin, final String plan) {
    throw UnimplementedError();
  }

  static Future<String> signAndBroadcast(
    final int coin,
    final int account,
    final String plan,
  ) async {
    final c = await _coinForAccount(coin, account);
    final package = await _decodePlan(plan);
    final signed = await zkool_pay.signTransaction(pczt: package, c: c);
    final txBytes = await zkool_pay.extractTransaction(package: signed);
    final height = await getLatestHeight(coin);
    return zkool_pay.broadcastTransaction(height: height, txBytes: txBytes, c: c);
  }

  static Future<String> signOnly(
    final int coin,
    final int account,
    final String tx, {
    final void Function(int)? progressFn,
  }) async {
    throw UnimplementedError();
  }

  static String broadcast(final int coin, final String txStr) {
    throw UnimplementedError();
  }

  static bool isValidTransparentKey(final String key) {
    throw UnimplementedError();
  }

  static Future<String> sweepTransparent(
    final int coin,
    final int account,
    final int latestHeight,
    final String sk,
    final int pool,
    final String address,
    final FeeT fee,
  ) async {
    throw UnimplementedError();
  }

  static Future<String> sweepTransparentSeed(
    final int coin,
    final int account,
    final int latestHeight,
    final String seed,
    final int pool,
    final String address,
    final int index,
    final int limit,
    final FeeT fee,
  ) async {
    throw UnimplementedError('sweepTransparentSeed intentionally not implemented');
  }

  // static String ledgerSign(int coin, String txFilename) {
  //   final res = warp_api_lib.ledger_sign(coin, toNative(txFilename));
  //   return res.cast<Utf8>().toDartString();
  // }

  static DateTime getActivationDate() {
    throw UnimplementedError();
  }

  static Future<int> getBlockHeightByTime(final int coin, final DateTime time) async {
    throw UnimplementedError();
  }

  static void setDbPasswd(final int coin, final String _passwd) {
    _dbPassword = _passwd;
  }

  static void updateLWD(final int coin, final String url) {
    final normalized = _normalizeLwdUrl(url);
    _lwdUrl = normalized;
    // Do not touch Rust synchronously before FRB init.
    // `_ensureCoin` applies this URL on the next async call.
    if (_isGlobalInit && _isDbOpen) {
      _coin = _coin.setLwd(url: normalized, serverType: 0);
    }
  }

  static String getLWD(final int coin) {
    throw UnimplementedError();
  }

  static void storeContact(
    final int coin,
    final int id,
    final String name,
    final String address,
    final bool dirty,
  ) {
    throw UnimplementedError();
  }

  static String commitUnsavedContacts(
    final int coin,
    final int account,
    final int pools,
    final int anchorOffset,
    final FeeT fee,
  ) {
    throw UnimplementedError();
  }

  static void markMessageAsRead(final int coin, final int messageId, final bool read) {
    throw UnimplementedError();
  }

  static void markAllMessagesAsRead(final int coin, final int account, final bool read) {
    throw UnimplementedError();
  }

  static void truncateData() {
    throw UnimplementedError();
  }

  static void truncateSyncData() {
    throw UnimplementedError();
  }

  static void deleteAccount(final int coin, final int account) {
    throw UnimplementedError();
  }

  static int getFirstAccount(final int coin) {
    throw UnimplementedError();
  }

  static String makePaymentURI(
    final int coin,
    final String address,
    final int amount,
    final String memo,
  ) {
    throw UnimplementedError();
  }

  static PaymentUri? decodePaymentURI(final int coin, final String uri) {
    try {
      if (_isGlobalInit) {
        final parsed = zkool_pay.parsePaymentUri(uri: uri);
        if (parsed != null && parsed.isNotEmpty) {
          final first = parsed.first;
          return PaymentUri(
            address: first.address,
            amount: first.amount.toInt(),
            memo: first.userMemo,
          );
        }
      }
      final u = Uri.tryParse(uri);
      if (u == null) return null;
      if (u.scheme == 'zcash' && u.path.isNotEmpty) {
        return PaymentUri(
          address: u.path,
          memo: u.queryParameters['memo'],
          amount: int.tryParse(u.queryParameters['amount'] ?? ''),
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<Agekeys> generateKey() async {
    throw UnimplementedError();
  }

  static void zipBackup(final String key, final String filename, final String tmpDir) {
    throw UnimplementedError();
  }

  static String decryptBackup(final String key, final String path, final String tempDir) {
    throw UnimplementedError();
  }

  static void unzipBackup(final String path, final String dbDir) {
    throw UnimplementedError();
  }

  static List<String> splitData(final int id, final String data) {
    throw UnimplementedError();
  }

  static RaptorQresultT mergeData(final String drop) {
    throw UnimplementedError();
  }

  static String getTxSummary(final String tx) {
    throw UnimplementedError();
  }

  static Future<KeyPack> deriveZip32(
    final int coin,
    final int idAccount,
    final int accountIndex,
    final int externalIndex,
    final int? addressIndex,
  ) async {
    throw UnimplementedError();
  }

  static String parseTexAddress(final int coin, final String address) {
    throw UnimplementedError();
  }

  static void storeSwap(final int coin, final int account, final SwapT swap) {
    throw UnimplementedError();
  }

  static List<SwapT> listSwaps(final int coin) {
    throw UnimplementedError();
  }

  static void clearSwapHistory(final int coin) {
    throw UnimplementedError();
  }

  static void ledgerBuildKeys() {
    throw UnimplementedError();
  }

  static String ledgerGetAddress() {
    throw UnimplementedError();
  }

  static Future<String> ledgerSend(final int coin, final String txPlan) async {
    throw UnimplementedError();
  }

  static bool hasCuda() {
    throw UnimplementedError();
  }

  static bool hasMetal() {
    throw UnimplementedError();
  }

  static bool hasGPU() {
    throw UnimplementedError();
  }

  static void useGPU(final bool v) {
    throw UnimplementedError();
  }

  static List<Account> getAccountList(final int coin) {
    return _accountCache;
  }

  static int countAccounts(final int coin) {
    throw UnimplementedError();
  }

  static String getTAddr(final int coin, final int id) {
    return getAddress(coin, id, 0);
  }

  static String getSK(final int coin, final int id) {
    throw UnimplementedError();
  }

  static void updateAccountName(final int coin, final int id, final String name) {
    throw UnimplementedError();
  }

  static Balance getBalance(final int coin, final int id, final int confirmedHeight) {
    throw UnimplementedError();
  }

  static Height getDbHeight(final int coin) {
    return Height(
      height: _lastKnownSyncHeight,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  static Future<List<ShieldedNote>> getNotes(final int coin, final int id) async {
    throw UnimplementedError();
  }

  static Future<List<ShieldedTx>> getTxs(final int coin, final int id) async {
    await _refreshTxs(coin, id);
    await _refreshBackup(coin, id);
    await _refreshAddresses(coin, id);
    await _refreshPoolBalance(coin, id);
    return _txCache[_txCacheKey(coin, id)] ?? <ShieldedTx>[];
  }

  static Future<List<Message>> getMessages(final int coin, final int id) async {
    throw UnimplementedError();
  }

  static List<ShieldedNote> getNotesSync(final int coin, final int id) {
    throw UnimplementedError('getNotesSync intentionally not implemented');
  }

  static List<ShieldedTx> getTxsSync(final int coin, final int id) {
    return _txCache[_txCacheKey(coin, id)] ?? <ShieldedTx>[];
  }

  static List<Message> getMessagesSync(final int coin, final int id) {
    throw UnimplementedError();
  }

  static PrevNext getPrevNextMessage(
    final int coin,
    final int id,
    final String subject,
    final int height,
  ) {
    throw UnimplementedError();
  }

  // static List<SendTemplateT> getSendTemplates(int coin) {
  //   final r = unwrapResultBytes(warp_api_lib.get_templates(coin));
  //   final templates = SendTemplateVec(r).unpack();
  //   return templates.templates!;
  // }

  // static int saveSendTemplate(int coin, SendTemplateT t) {
  //   final template = SendTemplateObjectBuilder(
  //     id: t.id,
  //     title: t.title,
  //     address: t.address,
  //     amount: t.amount,
  //     feeIncluded: t.feeIncluded,
  //     fiatAmount: t.fiatAmount,
  //     fiat: t.fiat,
  //     includeReplyTo: t.includeReplyTo,
  //     subject: t.subject,
  //     body: t.body,
  //   ).toBytes();
  //   final data = toNativeBytes(template);

  //   return unwrapResultU32(
  //       warp_api_lib.save_send_template(coin, data, template.length));
  // }

  static void deleteSendTemplate(final int coin, final int id) {
    throw UnimplementedError();
  }

  static List<Contact> getContacts(final int coin) {
    throw UnimplementedError();
  }

  static ContactT getContact(final int coin, final int id) {
    throw UnimplementedError();
  }

  static List<TxTimeValue> getPnLTxs(final int coin, final int id, final int timestamp) {
    throw UnimplementedError();
  }

  static List<Spending> getSpendings(final int coin, final int id, final int timestamp) {
    throw UnimplementedError();
  }

  static void updateExcluded(final int coin, final int id, final bool excluded) {
    throw UnimplementedError();
  }

  static void invertExcluded(final int coin, final int id) {
    throw UnimplementedError();
  }

  static List<Checkpoint> getCheckpoints(final int coin) {
    throw UnimplementedError();
  }

  static void clearTxDetails(final int coin, final int account) {
    throw UnimplementedError();
  }

  static void cloneDbWithPasswd(final int coin, final String tempPath, final String passwd) {
    throw UnimplementedError();
  }

  static bool decryptDb(final String dbPath, final String passwd) {
    throw UnimplementedError();
  }

  static String getProperty(final int coin, final String name) {
    throw UnimplementedError();
  }

  static void setProperty(final int coin, final String name, final String value) {
    throw UnimplementedError();
  }

  static int getAvailableAddrs(final int coin, final int account) {
    throw UnimplementedError();
  }

  static Future<int> ping(final String server) async {
    throw UnimplementedError();
  }

  static Future<int> importFromLedger(final int coin, final String name) async {
    throw UnimplementedError();
  }

  static Future<String> zipDbs(final String passwd, final String tempDir) async {
    throw UnimplementedError();
  }
}
