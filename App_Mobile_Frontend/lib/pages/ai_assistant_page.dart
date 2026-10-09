import 'package:flutter/material.dart';

// ON DÉPLACE LES COULEURS ICI POUR QU'ELLES SOIENT ACCESSIBLES PAR TOUT LE MONDE
const Color brandBlue = Color(0xFF2046E3);
const Color navy = Color(0xFF0A1628);

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Bonjour ! Je suis l\'assistant virtuel du Terminal TCR. Je suis là pour vous aider à naviguer dans l\'application et répondre à vos questions sur nos services.',
      'isUser': false
    },
  ];

  final List<String> _suggestions = [
    "Comment créer un compte ?",
    "Comment contacter le TCR ?",
    "Suivre un équipement",
    "Rôles disponibles",
    "Mot de passe oublié ?"
  ];

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add({'text': text, 'isUser': true}));
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _messages.add({'text': _getAIResponse(text), 'isUser': false}));
      _scrollToBottom();
    });
  }

  String _getAIResponse(String query) {
    query = query.toLowerCase();

    if (query.contains('compte') || query.contains('créer') || query.contains('inscription')) {
      return "Pour créer un compte :\n\n"
             "1. Allez sur l'onglet 'Profil'.\n"
             "2. Sélectionnez votre catégorie (Responsable ou Personnel).\n"
             "3. Cliquez sur 'Créer un compte' en bas du formulaire.\n"
             "4. Remplissez vos infos et envoyez.\n\n"
             "⚠️ Votre compte doit être validé par un Administrateur avant de pouvoir vous connecter.";
    }

    if (query.contains('contact') || query.contains('joindre') || query.contains('téléphone') || query.contains('email')) {
      return "Vous pouvez contacter Marsa Maroc - TCR via :\n\n"
             "📞 Tél : +212 (0) 522 23 10 11\n"
             "📧 Email : tcr@marsamaroc.co.ma\n"
             "📍 Adresse : Port de Casablanca, Terminal TCR.\n"
             "🕒 Service disponible 24h/24 et 7j/7.";
    }

    if (query.contains('rôle') || query.contains('catégorie') || query.contains('profil')) {
      return "L'application dispose de 3 accès principaux :\n\n"
             "• Administrateur : Gestion globale et validation des comptes.\n"
             "• Responsable : Consultation des Dashboards et suivi de parc.\n"
             "• Personnel : Mise à jour de l'état des engins en temps réel.";
    }

    if (query.contains('engin') || query.contains('équipement') || query.contains('suivre') || query.contains('panne')) {
      return "Cette application permet de voir l'état des équipements en temps réel. "
             "Une fois connecté, vous verrez des indicateurs colorés :\n\n"
             "🟢 Vert : Disponible\n"
             "🔴 Rouge : En panne\n"
             "🟠 Orange : En maintenance";
    }

    if (query.contains('mot de passe') || query.contains('mdp') || query.contains('perdu')) {
      return "Si vous avez oublié votre mot de passe, cliquez sur 'Mot de passe oublié' sur la page de connexion. "
             "Un lien de réinitialisation sera envoyé à votre adresse email professionnelle.";
    }

    return "Je ne suis pas sûr de comprendre votre demande. Pouvez-vous préciser si cela concerne votre compte, un contact ou le suivi technique des engins ?";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/ai_assistant.png'),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assistant IA TCR', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Support Intelligent', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _suggestions.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(_suggestions[i], style: const TextStyle(fontSize: 11, color: brandBlue, fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  side: BorderSide(color: brandBlue.withOpacity(0.2)),
                  onPressed: () => _handleSend(_suggestions[i]),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return _ChatBubble(text: m['text'], isUser: m['isUser']);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _handleSend,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF4F6FB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _handleSend(_controller.text),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: brandBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? brandBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : navy, // MAINTENANT navy EST RECONNU
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}