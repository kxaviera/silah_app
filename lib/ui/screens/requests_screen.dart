import 'package:flutter/material.dart';

import '../../core/request_api.dart';
import 'ad_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});
  static const routeName = '/requests';

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _requestApi = RequestApi();
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ReceivedTab(requestApi: _requestApi),
                _SentTab(requestApi: _requestApi),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedTab extends StatefulWidget {
  final RequestApi requestApi;
  
  const _ReceivedTab({required this.requestApi});

  @override
  State<_ReceivedTab> createState() => _ReceivedTabState();
}

class _ReceivedTabState extends State<_ReceivedTab> {
  List<Map<String, dynamic>> _received = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReceivedRequests();
  }

  Future<void> _loadReceivedRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.requestApi.getReceivedRequests();
      
      if (response['success'] == true) {
        setState(() {
          _received = (response['requests'] as List).map((r) => r as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load requests';
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

  Future<void> _handleAccept(String requestId, String userId) async {
    try {
      final response = await widget.requestApi.acceptRequest(requestId);
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request accepted'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReceivedRequests();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to accept request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  Future<void> _handleReject(String requestId) async {
    try {
      final response = await widget.requestApi.rejectRequest(requestId);
      
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadReceivedRequests();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to reject request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null && _received.isEmpty) {
      return Center(
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
              onPressed: _loadReceivedRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadReceivedRequests,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_received.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No incoming requests yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._received.map((r) {
              final requestId = r['_id'] ?? r['id'] ?? '';
              final userId = r['from']?['_id'] ?? r['from']?['id'] ?? '';
              final userName = r['from']?['name'] ?? r['from']?['fullName'] ?? 'Unknown';
              final requestType = r['requestType'] ?? 'Mobile & photos';
              final createdAt = r['createdAt'] ?? DateTime.now();
              final isNew = r['status'] == 'pending' && 
                           DateTime.now().difference(DateTime.parse(createdAt.toString())).inDays < 1;
              
              return _buildRequestCard(
                context,
                name: userName,
                type: requestType,
                time: _formatTime(createdAt),
                isNew: isNew,
                onAccept: () => _handleAccept(requestId, userId),
                onReject: () => _handleReject(requestId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdDetailScreen(userId: userId),
                    ),
                  );
                },
              );
            }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Safety tip: Only accept requests from verified profiles you trust.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
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

  Widget _buildRequestCard(
    BuildContext context, {
    required String name,
    required String type,
    required String time,
    required bool isNew,
    required VoidCallback onAccept,
    required VoidCallback onReject,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew
                ? theme.colorScheme.primary.withOpacity(0.3)
                : Colors.grey.shade200,
            width: isNew ? 2 : 1,
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                  onPressed: onAccept,
                  tooltip: 'Accept',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: onReject,
                  tooltip: 'Reject',
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _SentTab extends StatefulWidget {
  final RequestApi requestApi;
  
  const _SentTab({required this.requestApi});

  @override
  State<_SentTab> createState() => _SentTabState();
}

class _SentTabState extends State<_SentTab> {
  List<Map<String, dynamic>> _sent = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSentRequests();
  }

  Future<void> _loadSentRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.requestApi.getSentRequests();
      
      if (response['success'] == true) {
        setState(() {
          _sent = (response['requests'] as List).map((r) => r as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load requests';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null && _sent.isEmpty) {
      return Center(
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
              onPressed: _loadSentRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadSentRequests,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_sent.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.send_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You have not sent any requests yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._sent.map((r) {
              final userId = r['to']?['_id'] ?? r['to']?['id'] ?? '';
              final userName = r['to']?['name'] ?? r['to']?['fullName'] ?? 'Unknown';
              final requestType = r['requestType'] ?? 'Mobile & photos';
              final status = r['status'] ?? 'pending';
              final createdAt = r['createdAt'] ?? DateTime.now();
              
              return _buildSentCard(
                context,
                name: userName,
                type: requestType,
                time: _formatTime(createdAt),
                status: status,
                userId: userId,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSentCard(
    BuildContext context, {
    required String name,
    required String type,
    required String time,
    required String status,
    String? userId,
  }) {
    final isAccepted = status.toLowerCase() == 'accepted' || status.toLowerCase() == 'approved';
    final isPending = status.toLowerCase() == 'pending';
    final isRejected = status.toLowerCase() == 'rejected';
    
    String statusText;
    if (isAccepted) {
      statusText = 'Accepted';
    } else if (isRejected) {
      statusText = 'Rejected';
    } else {
      statusText = 'Pending';
    }
    
    return GestureDetector(
      onTap: userId != null && userId.isNotEmpty
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdDetailScreen(userId: userId),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? const Color(0xFFE8F5E9) // Colors.green.shade50
                      : isRejected
                          ? const Color(0xFFEFEBE9) // Colors.red.shade50
                          : const Color(0xFFFFF3E0), // Colors.orange.shade50
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAccepted
                        ? const Color(0xFFA5D6A7) // Colors.green.shade300
                        : isRejected
                            ? const Color(0xFFEF9A9A) // Colors.red.shade300
                            : const Color(0xFFFFB74D), // Colors.orange.shade300
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAccepted
                        ? const Color(0xFF2E7D32) // Colors.green.shade700
                        : isRejected
                            ? const Color(0xFFC62828) // Colors.red.shade700
                            : const Color(0xFFE65100), // Colors.orange.shade700
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

