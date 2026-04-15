import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/channel.dart';
import '../models/channel_post.dart';
import 'local_storage_service.dart';

class ChannelService extends ChangeNotifier {
  static final ChannelService _instance = ChannelService._internal();
  factory ChannelService() => _instance;
  ChannelService._internal();

  final _storage = LocalStorageService();
  List<Channel> _channels = [];
  final Map<String, List<ChannelPost>> _posts = {};
  final Map<String, String?> _cursors = {};
  final Map<String, bool> _loading = {};
  final Map<String, String> _tokens = {};
  final Map<String, WebSocketChannel?> _wsConns = {};
  final Map<String, StreamSubscription?> _wsSubs = {};
  final Map<String, Map<String, List<PostReaction>>> _reactions = {};
  final Set<String> _viewedPostIds = {};

  List<Channel> get channels => _channels;

  Channel? _findChannel(String channelId) {
    for (final c in _channels) {
      if (c.id == channelId) return c;
    }
    return null;
  }
  List<ChannelPost> postsFor(String channelId) => _posts[channelId] ?? [];
  bool isLoading(String channelId) => _loading[channelId] ?? false;
  bool hasMore(String channelId) => _cursors[channelId] != null;
  List<PostReaction> reactionsFor(String channelId, String postId) =>
      _reactions[channelId]?[postId] ?? [];

  ChannelPost? latestPost(String channelId) {
    final posts = _posts[channelId];
    return (posts != null && posts.isNotEmpty) ? posts.first : null;
  }

  Future<void> init() async {
    _channels = await _storage.loadChannels();
    // Load cached posts from SQLite
    for (final ch in _channels) {
      _posts[ch.id] = await _storage.loadChannelPosts(ch.id);
    }
    // Load cached tokens
    final prefs = await SharedPreferences.getInstance();
    for (final ch in _channels) {
      final token = prefs.getString('channel_token_${ch.url}');
      if (token != null) _tokens[ch.url] = token;
    }
    notifyListeners();
    // Background refresh
    for (final ch in _channels) {
      unawaited(_refreshChannel(ch));
    }
  }

  Future<void> _refreshChannel(Channel ch) async {
    try {
      // Fetch latest metadata
      final metaResp = await http.get(
        Uri.parse('${ch.url}/api/v1/channel'),
      ).timeout(const Duration(seconds: 10));
      if (metaResp.statusCode == 200) {
        final meta = jsonDecode(metaResp.body) as Map<String, dynamic>;
        final updated = ch.copyWith(
          name: meta['name'] as String? ?? ch.name,
          description: meta['description'] as String? ?? ch.description,
          avatarUrl: meta['avatar_url'] as String? ?? ch.avatarUrl,
        );
        if (updated.name != ch.name || updated.description != ch.description || updated.avatarUrl != ch.avatarUrl) {
          final idx = _channels.indexWhere((c) => c.id == ch.id);
          if (idx >= 0) {
            _channels[idx] = updated;
            await _storage.saveChannel(updated);
          }
        }
      }
    } catch (e) {
      debugPrint('[ChannelService] Failed to refresh metadata for ${ch.name}: $e');
    }
    // Fetch latest posts
    await fetchPosts(ch.id);
  }

  Future<void> fetchPosts(String channelId, {bool loadMore = false}) async {
    final ch = _findChannel(channelId);
    if (ch == null) return;
    if (_loading[channelId] == true) return;
    _loading[channelId] = true;

    try {
      final cursor = loadMore ? _cursors[channelId] : null;
      final uri = Uri.parse('${ch.url}/api/v1/posts').replace(queryParameters: {
        'limit': '20',
        if (cursor != null) 'cursor': cursor,
      });
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final rawPosts = (body['posts'] as List?) ?? [];
        final posts = rawPosts
            .map((p) => ChannelPost.fromJson(p as Map<String, dynamic>))
            .toList();
        final nextCursor = body['next_cursor'] as String?;
        _cursors[channelId] = (nextCursor != null && nextCursor.isNotEmpty) ? nextCursor : null;

        if (loadMore) {
          _posts[channelId] = [...(_posts[channelId] ?? []), ...posts];
        } else {
          _posts[channelId] = posts;
        }
        // Cache to SQLite
        unawaited(_storage.saveChannelPosts(channelId, posts));
      }
    } catch (e) {
      debugPrint('[ChannelService] fetchPosts error for $channelId: $e');
    } finally {
      _loading[channelId] = false;
      notifyListeners();
    }
  }

  Future<String> _getToken(String channelUrl) async {
    if (_tokens.containsKey(channelUrl)) return _tokens[channelUrl]!;
    try {
      final resp = await http.post(
        Uri.parse('$channelUrl/api/v1/token'),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final token = body['token'] as String? ?? '';
        _tokens[channelUrl] = token;
        // Persist
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('channel_token_$channelUrl', token);
        return token;
      }
    } catch (e) {
      debugPrint('[ChannelService] _getToken error (details redacted)');
    }
    return '';
  }

  void connectFeed(String channelId) {
    if (_wsConns[channelId] != null) return;
    final ch = _findChannel(channelId);
    if (ch == null) return;

    try {
      final wsUrl = ch.url.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      final channel = WebSocketChannel.connect(Uri.parse('$wsUrl/api/v1/ws/feed'));
      _wsConns[channelId] = channel;
      _wsSubs[channelId] = channel.stream.listen(
        (data) => _handleWsEvent(channelId, data),
        onError: (e) {
          debugPrint('[ChannelService] WS error for $channelId: $e');
          _cleanupWs(channelId);
        },
        onDone: () => _cleanupWs(channelId),
      );
    } catch (e) {
      debugPrint('[ChannelService] connectFeed error: $e');
    }
  }

  void disconnectFeed(String channelId) {
    _cleanupWs(channelId);
  }

  void _cleanupWs(String channelId) {
    _wsSubs[channelId]?.cancel();
    _wsSubs.remove(channelId);
    try {
      _wsConns[channelId]?.sink.close();
    } catch (_) {}
    _wsConns.remove(channelId);
  }

  void _handleWsEvent(String channelId, dynamic raw) {
    try {
      if (raw is! String) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';
      switch (type) {
        case 'new_post':
          final post = ChannelPost.fromJson(data['post'] as Map<String, dynamic>);
          final existing = _posts[channelId] ?? [];
          // Insert at beginning (newest first)
          if (!existing.any((p) => p.id == post.id)) {
            _posts[channelId] = [post, ...existing];
            unawaited(_storage.upsertChannelPost(channelId, post));
            notifyListeners();
          }
          break;
        case 'edit_post':
          final post = ChannelPost.fromJson(data['post'] as Map<String, dynamic>);
          final existing = _posts[channelId] ?? [];
          final idx = existing.indexWhere((p) => p.id == post.id);
          if (idx >= 0) {
            existing[idx] = post;
            _posts[channelId] = existing;
            unawaited(_storage.upsertChannelPost(channelId, post));
            notifyListeners();
          }
          break;
        case 'delete_post':
          final postId = data['id'] as String? ?? '';
          if (postId.isNotEmpty) {
            _posts[channelId]?.removeWhere((p) => p.id == postId);
            unawaited(_storage.removeChannelPost(channelId, postId));
            notifyListeners();
          }
          break;
      }
    } catch (e) {
      debugPrint('[ChannelService] WS event parse error: $e');
    }
  }

  Future<void> recordView(String channelId, String postId) async {
    if (_viewedPostIds.contains(postId)) return;
    _viewedPostIds.add(postId);
    final ch = _findChannel(channelId);
    if (ch == null) return;
    try {
      final token = await _getToken(ch.url);
      await http.post(
        Uri.parse('${ch.url}/api/v1/posts/$postId/view'),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> fetchReactions(String channelId, String postId) async {
    final ch = _findChannel(channelId);
    if (ch == null) return;
    try {
      final resp = await http.get(
        Uri.parse('${ch.url}/api/v1/posts/$postId/reactions'),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final list = (jsonDecode(resp.body) as List)
            .map((r) => PostReaction.fromJson(r as Map<String, dynamic>))
            .toList();
        _reactions[channelId] ??= {};
        _reactions[channelId]![postId] = list;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ChannelService] fetchReactions error: $e');
    }
  }

  Future<void> toggleReaction(String channelId, String postId, String emoji) async {
    final ch = _findChannel(channelId);
    if (ch == null) return;
    try {
      final token = await _getToken(ch.url);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      // Try POST first; if already reacted, DELETE
      final resp = await http.post(
        Uri.parse('${ch.url}/api/v1/posts/$postId/react'),
        headers: headers,
        body: jsonEncode({'emoji': emoji}),
      ).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 409) {
        // Already reacted — remove
        await http.delete(
          Uri.parse('${ch.url}/api/v1/posts/$postId/react'),
          headers: headers,
          body: jsonEncode({'emoji': emoji}),
        ).timeout(const Duration(seconds: 5));
      }
      // Refresh reactions
      await fetchReactions(channelId, postId);
    } catch (e) {
      debugPrint('[ChannelService] toggleReaction error: $e');
    }
  }

  Future<void> addChannel(Channel channel) async {
    _channels.add(channel);
    await _storage.saveChannel(channel);
    _posts[channel.id] = [];
    notifyListeners();
    unawaited(_refreshChannel(channel));
  }

  Future<void> removeChannel(String id) async {
    _cleanupWs(id);
    _channels.removeWhere((c) => c.id == id);
    _posts.remove(id);
    _cursors.remove(id);
    _reactions.remove(id);
    await _storage.removeChannel(id);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final id in _wsConns.keys.toList()) {
      _cleanupWs(id);
    }
    super.dispose();
  }
}
