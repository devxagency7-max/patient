import 'dart:async';
import 'package:pharmacare/core/config/app_config.dart';
import 'package:pharmacare/core/network/api_client.dart';
import 'package:pharmacare/features/chat/data/models/chat_message_model.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ConversationReadEvent {
  final String conversationId;
  final String userId;

  ConversationReadEvent({required this.conversationId, required this.userId});
}

class ChatSignalRService {
  final ApiClient apiClient;
  HubConnection? _hubConnection;

  // SignalR's `withAutomaticReconnect()` restores the transport connection
  // after a drop (backgrounding, network blip, phone sleep), but the server
  // does NOT remember this connection's group memberships across a
  // reconnect — it's a fresh connectionId. Without re-invoking
  // JoinConversation here, `ReceiveMessage` silently stops arriving for any
  // conversation joined before the drop, even though the hub reports
  // "Connected" again. Track joined ids so onreconnected can rejoin them.
  final Set<String> _joinedConversationIds = {};

  final _messageController = StreamController<ChatMessageModel>.broadcast();
  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  final _connectionStatusController = StreamController<HubConnectionState>.broadcast();
  Stream<HubConnectionState> get connectionStatusStream => _connectionStatusController.stream;

  final _conversationReadController = StreamController<ConversationReadEvent>.broadcast();
  Stream<ConversationReadEvent> get conversationReadStream => _conversationReadController.stream;

  ChatSignalRService({required this.apiClient});

  Future<void> connect() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          AppConfig.chatHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              final token = await apiClient.getFirebaseToken();
              return token ?? '';
            },
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.onclose(({error}) {
      _connectionStatusController.add(HubConnectionState.Disconnected);
    });

    _hubConnection!.onreconnecting(({error}) {
      _connectionStatusController.add(HubConnectionState.Reconnecting);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _connectionStatusController.add(HubConnectionState.Connected);
      for (final conversationId in _joinedConversationIds) {
        _hubConnection!.invoke('JoinConversation', args: [conversationId]).catchError((_) => null);
      }
    });

    _hubConnection!.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageJson = arguments.first as Map<String, dynamic>;
        final message = ChatMessageModel.fromJson(
          messageJson,
          currentUserId: apiClient.currentUserId,
        );
        _messageController.add(message);
      }
    });

    _hubConnection!.on('ConversationRead', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        _conversationReadController.add(ConversationReadEvent(
          conversationId: arguments[0] as String,
          userId: arguments[1] as String,
        ));
      }
    });

    try {
      await _hubConnection!.start();
      _connectionStatusController.add(HubConnectionState.Connected);
    } catch (e) {
      _connectionStatusController.add(HubConnectionState.Disconnected);
    }
  }

  bool get isConnected =>
      _hubConnection != null && _hubConnection!.state == HubConnectionState.Connected;

  Future<void> joinConversation(String conversationId) async {
    _joinedConversationIds.add(conversationId);
    if (!isConnected) return;
    try {
      await _hubConnection!.invoke('JoinConversation', args: [conversationId]);
    } catch (_) {}
  }

  Future<void> leaveConversation(String conversationId) async {
    _joinedConversationIds.remove(conversationId);
    if (!isConnected) return;
    try {
      await _hubConnection!.invoke('LeaveConversation', args: [conversationId]);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
    }
  }
}
