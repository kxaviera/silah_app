import 'package:flutter/material.dart';

import '../../core/message_api.dart';
import '../../core/auth_api.dart';
import '../../utils/boost_dialog.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageApi = MessageApi();
  final _authApi = AuthApi();
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<bool> _isUserBoosted() async {
    try {
      final me = await _authApi.getMe();
      if (me['success'] != true || me['user'] == null) return false;
      final u = me['user'] as Map<String, dynamic>;
      final status = u['boostStatus'] as String?;
      final expires = u['boostExpiresAt'] as String?;
      if (status != 'active' || expires == null) return false;
      return DateTime.parse(expires).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _messageApi.getConversations();
      
      if (response['success'] == true) {
        setState(() {
          _conversations = (response['conversations'] as List)
              .map((c) => c as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load conversations';
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

  String _formatTime(dynamic time) {
    if (time is String) {
      try {
        time = DateTime.parse(time);
      } catch (e) {
        return time;
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
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${time.day}/${time.month}/${time.year}';
      }
    }
    return 'Recently';
  }

  List<Map<String, dynamic>> get _filteredConversations {
    final search = _searchController.text.toLowerCase();
    if (search.isEmpty) return _conversations;
    
    return _conversations.where((c) {
      final name = (c['otherUser']?['name'] ?? c['otherUser']?['fullName'] ?? '').toLowerCase();
      final preview = (c['lastMessage']?['message'] ?? '').toLowerCase();
      return name.contains(search) || preview.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search conversations',
              hintStyle: TextStyle(color: Colors.black38),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadConversations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredConversations.isEmpty
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
                                _searchController.text.isNotEmpty
                                    ? 'No conversations found'
                                    : 'No conversations yet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (_, i) {
                              final c = _filteredConversations[i];
                              final otherUser = c['otherUser'] ?? {};
                              final userName = otherUser['name'] ?? otherUser['fullName'] ?? 'Unknown';
                              final lastMessage = c['lastMessage'];
                              final preview = lastMessage?['message'] ?? '';
                              final lastMessageTime = lastMessage?['createdAt'] ?? c['updatedAt'];
                              final unreadCount = c['unreadCount'] ?? 0;
                              final isUnread = unreadCount > 0;
                              final conversationId = c['_id'] ?? c['id'] ?? '';
                              final otherUserId = otherUser['_id'] ?? otherUser['id'] ?? '';
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isUnread
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                        : Colors.grey.shade200,
                                    width: isUnread ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Center(
                                      child: Text(
                                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: isUnread
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatTime(lastMessageTime),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      preview,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: isUnread
                                      ? Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            unreadCount > 9 ? '9+' : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                  onTap: () async {
                                    final boosted = await _isUserBoosted();
                                    if (!mounted) return;
                                    if (!boosted) {
                                      await showBoostRequiredDialog(context);
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          conversationId: conversationId,
                                          otherUserId: otherUserId,
                                          name: userName,
                                        ),
                                      ),
                                    ).then((_) => _loadConversations());
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: _filteredConversations.length,
                          ),
                        ),
        ),
      ],
    );
  }
}

