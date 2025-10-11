import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class Messages extends StatefulWidget {
  final String userId;
  final bool? isAnsweredFilter; // null = show all, true = show answered only, false = show unanswered only

  const Messages({required this.userId, super.key, this.isAnsweredFilter});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _sessions = [];
  List<dynamic> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📨 Loading sessions for user: ${widget.userId}');
      final result = await ApiService.getUserSessions(widget.userId);

      if (result['success'] == true) {
        setState(() {
          _sessions = result['data'] as List<dynamic>;
          _filterSessions();
          _isLoading = false;
        });
        print('✅ Loaded ${_sessions.length} sessions, filtered to ${_filteredSessions.length}');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'فشل في تحميل الرسائل';
          _isLoading = false;
        });
        print('❌ Failed to load sessions: ${result['error']}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل الرسائل';
        _isLoading = false;
      });
      print('❌ Error loading sessions: $e');
    }
  }

  void _filterSessions() {
    if (widget.isAnsweredFilter == null) {
      // Show all sessions
      _filteredSessions = _sessions;
    } else {
      // Filter by answered status
      _filteredSessions = _sessions.where((session) {
        final sessionData = session as Map<String, dynamic>;
        final isAnswered = sessionData["isAnswered"] == true;
        return isAnswered == widget.isAnsweredFilter;
      }).toList();
    }
  }

  Future<void> _refreshSessions() async {
    await _loadSessions();
  }

  String _getAppBarTitle() {
    if (widget.isAnsweredFilter == null) {
      return 'صندوق الرسائل';
    } else if (widget.isAnsweredFilter == true) {
      return 'البلاغات المغلقة';
    } else {
      return 'البلاغات المعلقة';
    }
  }

  String _getEmptyStateMessage() {
    if (widget.isAnsweredFilter == null) {
      return 'لا توجد رسائل';
    } else if (widget.isAnsweredFilter == true) {
      return 'لا توجد بلاغات مغلقة';
    } else {
      return 'لا توجد بلاغات معلقة';
    }
  }

  String _getEmptyStateSubMessage() {
    if (widget.isAnsweredFilter == null) {
      return 'ستظهر رسائل جلساتك هنا';
    } else if (widget.isAnsweredFilter == true) {
      return 'ستظهر البلاغات المغلقة هنا';
    } else {
      return 'ستظهر البلاغات المعلقة هنا';
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'حدث خطأ غير متوقع',
            style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshSessions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('إعادة المحاولة', style: AppTheme.buttonTextStyle.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.message_outlined, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          Text(_getEmptyStateMessage(), style: AppTheme.subtitleTextStyle.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(_getEmptyStateSubMessage(), style: AppTheme.bodyTextStyle.copyWith(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshSessions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('تحديث', style: AppTheme.buttonTextStyle.copyWith(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_getAppBarTitle(), style: AppTheme.subtitleTextStyle.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textPrimary),
            onPressed: _refreshSessions,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // App logo header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(AppConstants.appLogo, width: 80, height: 80),
            ),
            // Content area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                ),
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            const SizedBox(height: 16),
                            Text('جارٍ تحميل الرسائل...', style: AppTheme.bodyTextStyle.copyWith(color: Colors.white)),
                          ],
                        ),
                      )
                    : _errorMessage != null
                    ? _buildErrorWidget()
                    : _filteredSessions.isEmpty
                    ? _buildEmptyWidget()
                    : RefreshIndicator(
                        onRefresh: _refreshSessions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) {
                            final sessionData = _filteredSessions[index] as Map<String, dynamic>;
                            return NotificationItem(sessionData: sessionData);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> sessionData;

  const NotificationItem({required this.sessionData, super.key});

  String formatTimestamp(Map<String, dynamic> timestamp) {
    try {
      final int seconds = timestamp['_seconds'] ?? 0;
      final int nanoseconds = timestamp['_nanoseconds'] ?? 0;

      // Combine seconds and nanoseconds into a single value
      final int combinedMilliseconds = (seconds * 1000) + (nanoseconds / 1000000).round();

      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(combinedMilliseconds);

      final String day = dateTime.day.toString().padLeft(2, '0');
      final String month = dateTime.month.toString().padLeft(2, '0');
      final String year = dateTime.year.toString();

      final String formattedDate = '$day/$month/$year';

      final int hour = dateTime.hour;
      final int minute = dateTime.minute;

      final String formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      return '$formattedDate $formattedTime';
    } catch (e) {
      return 'وقت غير محدد';
    }
  }

  String getSessionId() {
    try {
      return sessionData["timestamp"]["_seconds"]?.toString() ?? 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = sessionData["isAnswered"] == true;
    final String statusText = isAnswered ? "تم الرد عليه وإغلاقه" : "لم يتم الرد عليه";
    final Color statusColor = isAnswered ? Colors.green : Colors.orange;
    final IconData statusIcon = isAnswered ? Icons.check_circle : Icons.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.emergency, color: Color(AppConstants.primaryColorValue), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'بلاغ طوارئ',
                      style: TextStyle(
                        color: Color(AppConstants.primaryColorValue),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Session details
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'رقم البلاغ: ${getSessionId()}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'تاريخ البلاغ: ${formatTimestamp(sessionData["timestamp"] ?? {})}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
