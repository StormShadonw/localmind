// import 'package:ollama_dart/ollama_dart.dart';

// class OllamaHelper {
//   OllamaClient ollamaClient = OllamaClient();

//   Future<void> sendMessage(String message, List<Message> chat) async {
//     final res = await ollamaClient.generateChatCompletion(
//       request: GenerateChatCompletionRequest(
//         model: "mistral:latest",
//         messages: [
//           Message(
//             role: MessageRole.system,
//             content: 'You are a helpful assistant.',
//           ),
//           Message(
//             role: MessageRole.user,
//             content: 'List the numbers from 1 to 9 in order.',
//           ),
//         ],
//         keepAlive: 1,
//       ),
//     );
//   }
// }
