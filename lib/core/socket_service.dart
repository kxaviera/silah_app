import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  final Map<String, StreamController<Map<String, dynamic>>> _messageControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  /// Initialize socket connection
  Future<void> connect({required String userId}) async {
    if (_socket != null && _isConnected && _userId == userId) {
      return; // Already connected
    }

    _userId = userId;

    try {
      // Get token from storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('SocketService: No auth token found');
        return;
      }

      // Get socket URL from AppConfig
      final socketUrl = AppConfig.fullSocketUrl;

      // Create socket connection
      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      // Connection events
      _socket!.onConnect((_) {
        print('SocketService: Connected');
        _isConnected = true;
        _connectionController.add(true);
        
        // Join user room
        _socket!.emit('join:user', {'userId': userId});
      });

      _socket!.onDisconnect((_) {
        print('SocketService: Disconnected');
        _isConnected = false;
        _connectionController.add(false);
      });

      _socket!.onError((error) {
        print('SocketService: Error: $error');
        _isConnected = false;
        _connectionController.add(false);
      });

      // Message events
      _socket!.on('new:message', (data) {
        final message = data as Map<String, dynamic>;
        final conversationId = message['conversationId'] as String?;
        
        if (conversationId != null) {
          _messageControllers[conversationId]?.add(message);
        }
      });

      _socket!.on('message:sent', (data) {
        final message = data as Map<String, dynamic>;
        final conversationId = message['conversationId'] as String?;
        
        if (conversationId != null) {
          _messageControllers[conversationId]?.add(message);
        }
      });

      // Typing indicators
      _socket!.on('typing:indicator', (data) {
        final typingData = data as Map<String, dynamic>;
        final conversationId = typingData['conversationId'] as String?;
        final isTyping = typingData['isTyping'] as bool? ?? false;
        
        if (conversationId != null) {
          _typingControllers[conversationId]?.add(isTyping);
        }
      });

      // Request events
      _socket!.on('new:request', (data) {
        // Handle new contact request notification
        print('SocketService: New request received');
      });

      _socket!.on('request:accepted', (data) {
        // Handle request accepted notification
        print('SocketService: Request accepted');
      });

      _socket!.on('request:rejected', (data) {
        // Handle request rejected notification
        print('SocketService: Request rejected');
      });

      // Connect
      _socket!.connect();
    } catch (e) {
      print('SocketService: Connection error: $e');
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _userId = null;
      _connectionController.add(false);
    }
  }

  /// Join conversation room
  void joinConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join:conversation', {'conversationId': conversationId});
    }
  }

  /// Leave conversation room
  void leaveConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave:conversation', {'conversationId': conversationId});
    }
  }

  /// Send message via socket
  void sendMessage({
    required String conversationId,
    required String message,
  }) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send:message', {
        'conversationId': conversationId,
        'message': message,
      });
    }
  }

  /// Start typing indicator
  void startTyping(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing:start', {'conversationId': conversationId});
    }
  }

  /// Stop typing indicator
  void stopTyping(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('typing:stop', {'conversationId': conversationId});
    }
  }

  /// Get message stream for a conversation
  Stream<Map<String, dynamic>> getMessageStream(String conversationId) {
    if (!_messageControllers.containsKey(conversationId)) {
      _messageControllers[conversationId] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _messageControllers[conversationId]!.stream;
  }

  /// Get typing indicator stream for a conversation
  Stream<bool> getTypingStream(String conversationId) {
    if (!_typingControllers.containsKey(conversationId)) {
      _typingControllers[conversationId] = StreamController<bool>.broadcast();
    }
    return _typingControllers[conversationId]!.stream;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    for (var controller in _typingControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
    _typingControllers.clear();
    _connectionController.close();
  }
}
