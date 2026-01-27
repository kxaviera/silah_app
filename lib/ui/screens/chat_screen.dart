import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/message_api.dart';
import '../../core/socket_service.dart';
import '../../core/request_api.dart';
import '../../core/auth_api.dart';
import '../../core/block_api.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String name;
  
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.name,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageApi = MessageApi();
  final _requestApi = RequestApi();
  final _blockApi = BlockApi();
  final _socketService = SocketService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _iBlockedThem = false;
  bool _theyBlockedMe = false;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  bool _canChat = false; // Check if contact request is approved
  bool _checkingChatAccess = true;
  String? _currentUserId;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  bool get _isBlocked => _iBlockedThem || _theyBlockedMe;
  
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<bool>? _typingSubscription;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _checkChatAccess();
    _checkBlockStatus();
    _loadMessages();
    _setupSocketListeners();
  }

  Future<void> _checkBlockStatus() async {
    try {
      final response = await _blockApi.getBlockStatus(widget.otherUserId);
      if (mounted && response['success'] == true) {
        setState(() {
          _iBlockedThem = response['iBlockedThem'] as bool? ?? false;
          _theyBlockedMe = response['theyBlockedMe'] as bool? ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _iBlockedThem = false;
          _theyBlockedMe = false;
        });
      }
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final authApi = AuthApi();
      final response = await authApi.getMe();
      if (response['success'] == true && mounted) {
        final user = response['user'] as Map<String, dynamic>;
        setState(() {
          _currentUserId = user['_id'] ?? user['id'];
        });
      }
    } catch (e) {
      print('Failed to load current user ID: $e');
    }
  }

  Future<void> _checkChatAccess() async {
    setState(() {
      _checkingChatAccess = true;
    });

    try {
      final response = await _requestApi.checkRequestStatus(widget.otherUserId);
      
      if (mounted) {
        setState(() {
          // Support both legacy `approved` and newer `canChat` booleans
          final approved = response['approved'] == true;
          final canChat = response['canChat'] == true;
          _canChat = approved || canChat;
          _checkingChatAccess = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canChat = false;
          _checkingChatAccess = false;
        });
      }
    }
  }

  void _setupSocketListeners() {
    // Join conversation room
    _socketService.joinConversation(widget.conversationId);
    
    // Listen for new messages
    _messageSubscription = _socketService.getMessageStream(widget.conversationId).listen((message) {
      if (mounted) {
        setState(() {
          // Check if message already exists
          final messageId = message['_id'] ?? message['id'];
          final exists = _messages.any((m) => (m['_id'] ?? m['id']) == messageId);
          
          if (!exists) {
            _messages.add(message);
            _messages.sort((a, b) {
              final aTime = DateTime.parse(a['createdAt'] ?? DateTime.now().toIso8601String());
              final bTime = DateTime.parse(b['createdAt'] ?? DateTime.now().toIso8601String());
              return aTime.compareTo(bTime);
            });
          } else {
            // Update existing message
            final index = _messages.indexWhere((m) => (m['_id'] ?? m['id']) == messageId);
            if (index != -1) {
              _messages[index] = message;
            }
          }
        });
        _scrollToBottom();
      }
    });
    
    // Listen for typing indicators
    _typingSubscription = _socketService.getTypingStream(widget.conversationId).listen((isTyping) {
      if (mounted) {
        setState(() {
          _otherUserTyping = isTyping;
        });
      }
    });
  }

  @override
  void dispose() {
    _socketService.leaveConversation(widget.conversationId);
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _messageApi.getMessages(
        conversationId: widget.conversationId,
      );
      
      if (response['success'] == true) {
        setState(() {
          _messages = (response['messages'] as List)
              .map((m) => m as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load messages';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSendImage() async {
    if (_isSending || !_canChat || _isBlocked) return;

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (picked == null) return;

    setState(() {
      _isSending = true;
    });

    // Optimistic placeholder
    final tempMessage = {
      'message': picked.path,
      'sender': 'current',
      'createdAt': DateTime.now().toIso8601String(),
      'isSending': true,
      'messageType': 'image',
      'isLocalImage': true,
    };
    setState(() {
      _messages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      final response = await _messageApi.sendImage(
        conversationId: widget.conversationId,
        image: picked,
      );

      if (response['success'] == true) {
        final sentMessage = response['message'] as Map<String, dynamic>;
        setState(() {
          final tempIndex = _messages.indexWhere((m) => m['isSending'] == true && m['messageType'] == 'image');
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
          }
          _messages.add(sentMessage);
          _isSending = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          final tempIndex = _messages.indexWhere((m) => m['isSending'] == true && m['messageType'] == 'image');
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
          }
          _isSending = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        final tempIndex = _messages.indexWhere((m) => m['isSending'] == true && m['messageType'] == 'image');
        if (tempIndex != -1) {
          _messages.removeAt(tempIndex);
        }
        _isSending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while sending image.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _isSending || !_canChat || _isBlocked) return;

    // Enforce: user can only send one message in a row until the other user replies.
    // Find the last real (non-temporary) message.
    if (_messages.isNotEmpty) {
      final lastReal = _messages.lastWhere(
        (m) => m['isSending'] != true,
        orElse: () => <String, dynamic>{},
      );
      if (lastReal.isNotEmpty) {
        final lastSenderId = lastReal['sender']?['_id'] ??
            lastReal['senderId'] ??
            lastReal['sender'];
        final lastIsMe =
            lastSenderId != null && lastSenderId.toString() == _currentUserId;
        if (lastIsMe) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please wait for a reply before sending another message.',
                ),
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isSending = true;
    });

    // Optimistically add message
    final tempMessage = {
      'message': message,
      'sender': 'current', // Will be replaced by actual sender ID from API
      'createdAt': DateTime.now().toIso8601String(),
      'isSending': true,
    };
    setState(() {
      _messages.add(tempMessage);
      _controller.clear();
    });
    _scrollToBottom();

    // Stop typing indicator
    if (_isTyping) {
      setState(() {
        _isTyping = false;
      });
      _typingTimer?.cancel();
      _socketService.stopTyping(widget.conversationId);
    }

    try {
      // Send via socket for real-time delivery
      _socketService.sendMessage(
        conversationId: widget.conversationId,
        message: message,
      );
      
      // Also send via API as backup
      final response = await _messageApi.sendMessage(
        conversationId: widget.conversationId,
        message: message,
      );
      
      if (response['success'] == true) {
        // Replace temp message with actual message from API
        final sentMessage = response['message'] as Map<String, dynamic>;
        setState(() {
          final tempIndex = _messages.indexWhere((m) => m['isSending'] == true);
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
          }
          _messages.add(sentMessage);
          _isSending = false;
        });
        _scrollToBottom();
      } else {
        // Remove failed message
        setState(() {
          final tempIndex = _messages.indexWhere((m) => m['isSending'] == true);
          if (tempIndex != -1) {
            _messages.removeAt(tempIndex);
          }
          _isSending = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to send message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        final tempIndex = _messages.indexWhere((m) => m['isSending'] == true);
        if (tempIndex != -1) {
          _messages.removeAt(tempIndex);
        }
        _isSending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(dynamic time) {
    if (time is String) {
      try {
        time = DateTime.parse(time);
      } catch (e) {
        return '';
      }
    }
    if (time is DateTime) {
      final now = DateTime.now();
      final difference = now.difference(time);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) async {
              if (value == 'block') {
                final res = await _blockApi.blockUser(widget.otherUserId);
                if (!mounted) return;
                if (res['success'] == true) {
                  setState(() => _iBlockedThem = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.name} has been blocked')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] as String? ?? 'Failed to block'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else if (value == 'unblock') {
                final res = await _blockApi.unblockUser(widget.otherUserId);
                if (!mounted) return;
                if (res['success'] == true) {
                  setState(() => _iBlockedThem = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.name} has been unblocked')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] as String? ?? 'Failed to unblock'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else if (value == 'report') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Report User'),
                    content: const Text(
                      'Are you sure you want to report this user? '
                      'Our team will review your report.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User reported')),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Report'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _iBlockedThem ? 'unblock' : 'block',
                child: Row(
                  children: [
                    Icon(
                      _iBlockedThem ? Icons.block_flipped : Icons.block,
                      color: _iBlockedThem ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_iBlockedThem ? 'Unblock user' : 'Block user'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Report user'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Safety tip: Never share personal or financial information.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _iBlockedThem
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'You blocked this user',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final res = await _blockApi.unblockUser(widget.otherUserId);
                                if (!mounted) return;
                                if (res['success'] == true) {
                                  setState(() => _iBlockedThem = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${widget.name} has been unblocked')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] as String? ?? 'Failed to unblock'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.block_flipped, size: 18),
                              label: const Text('Unblock user'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _theyBlockedMe
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.block,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'You can\'t message this user',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'They have restricted messaging.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) {
                              final msg = _messages[i];
                              final senderId = msg['sender']?['_id'] ?? msg['sender'];
                              final isMe = (senderId != null && senderId == _currentUserId) || msg['isSending'] == true;
                              final messageText = msg['message'] ?? '';
                              final messageTime = msg['createdAt'];
                              final isSending = msg['isSending'] == true;
                              final String messageType = (msg['messageType'] as String?) ?? 'text';
                              
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      if (messageType == 'image')
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            messageText,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      else
                                        Text(
                                          messageText,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      if (messageTime != null && !isSending) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(messageTime),
                                          style: TextStyle(
                                            color: isMe ? Colors.white70 : Colors.black54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                      if (isSending) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  isMe ? Colors.white70 : Colors.black54,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Sending...',
                                              style: TextStyle(
                                                color: isMe ? Colors.white70 : Colors.black54,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          // Typing indicator
          if (_otherUserTyping && !_isBlocked && !_isLoading && _messages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.name} is typing...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_checkingChatAccess)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (!_canChat)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Colors.orange.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact request not approved',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can only chat after your contact request is approved.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (_isBlocked)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Center(
                child: Text(
                  _iBlockedThem
                      ? 'You blocked this user. Unblock from menu or above to chat.'
                      : 'You cannot send messages to this user.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, color: Colors.black54),
                      onPressed: _pickAndSendImage,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: _canChat && !_isBlocked,
                        style: TextStyle(
                          color: (_canChat && !_isBlocked) ? Colors.black87 : Colors.black38,
                        ),
                        decoration: InputDecoration(
                          hintText: _canChat ? 'Type a message...' : 'Contact request not approved',
                          hintStyle: TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: (_canChat && !_isBlocked) ? Colors.grey.shade50 : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (text) {
                          if (text.isNotEmpty && !_isTyping) {
                            setState(() {
                              _isTyping = true;
                            });
                            _socketService.startTyping(widget.conversationId);
                            
                            // Stop typing after 3 seconds of no input
                            _typingTimer?.cancel();
                            _typingTimer = Timer(const Duration(seconds: 3), () {
                              if (mounted && _isTyping) {
                                setState(() {
                                  _isTyping = false;
                                });
                                _socketService.stopTyping(widget.conversationId);
                              }
                            });
                          } else if (text.isEmpty && _isTyping) {
                            setState(() {
                              _isTyping = false;
                            });
                            _typingTimer?.cancel();
                            _socketService.stopTyping(widget.conversationId);
                          }
                        },
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

