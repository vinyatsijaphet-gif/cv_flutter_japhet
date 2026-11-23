import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/membre.dart';
import '../services/api_service.dart';

/// Formulaire d'ajout (membre == null) ou de modification d'un membre.
/// Retourne le Membre enregistré au Navigator.pop si l'enregistrement a réussi.
class MembreFormPage extends StatefulWidget {
  final Membre? membre;
  const MembreFormPage({super.key, this.membre});

  @override
  State<MembreFormPage> createState() => _MembreFormPageState();
}

class _MembreFormPageState extends State<MembreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom;
  late final TextEditingController _postnom;
  late final TextEditingController _prenom;
  late final TextEditingController _lieu;
  late final TextEditingController _date;
  late final TextEditingController _parente;
  ImageData? _image;
  bool _saving = false;

  bool get _isEdit => widget.membre != null;

  @override
  void initState() {
    super.initState();
    final m = widget.membre;
    _nom = TextEditingController(text: m?.nom);
    _postnom = TextEditingController(text: m?.postnom);
    _prenom = TextEditingController(text: m?.prenom);
    _lieu = TextEditingController(text: m?.lieuNaissance);
    _date = TextEditingController(text: m?.dateNaissance);
    _parente = TextEditingController(text: m?.parente);
  }

  @override
  void dispose() {
    for (final c in [_nom, _postnom, _prenom, _lieu, _date, _parente]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 85);
    if (x != null) {
      final bytes = await x.readAsBytes();
      final name = x.name.isNotEmpty ? x.name : 'photo.jpg';
      setState(() => _image = ImageData(bytes, name));
    }
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date.text) ?? DateTime(2000);
    final d = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _date.text =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Veuillez remplir tous les champs obligatoires.');
      return;
    }
    setState(() => _saving = true);
    final m = Membre(
      nom: _nom.text.trim(),
      postnom: _postnom.text.trim(),
      prenom: _prenom.text.trim(),
      lieuNaissance: _lieu.text.trim(),
      dateNaissance: _date.text.trim(),
      parente: _parente.text.trim(),
    );
    try {
      final Membre saved;
      if (_isEdit) {
        saved = await ApiService.updateMembre(widget.membre!.id!, m, image: _image);
      } else {
        saved = await ApiService.createMembre(m, image: _image);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Membre modifié' : 'Membre ajouté')));
      // On renvoie le membre enregistré pour mettre la liste à jour tout de suite.
      Navigator.pop(context, saved);
    } on ApiException catch (e) {
      _showError(e.toString());
    } catch (e) {
      // Toute autre erreur inattendue : on l'affiche au lieu de l'ignorer.
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v, int max) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Champ obligatoire';
    if (s.length > max) return '$max caractères maximum';
    return null;
  }

  Widget _field(TextEditingController c, String label, int max,
      {IconData? icon, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => _required(v, max),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingUrl = widget.membre?.imageUrl;
    ImageProvider? avatar;
    if (_image != null) {
      avatar = MemoryImage(_image!.bytes);
    } else if (existingUrl != null) {
      avatar = NetworkImage(existingUrl);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifier le membre' : 'Ajouter un membre')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? const Icon(Icons.add_a_photo, size: 36)
                        : null,
                  ),
                ),
                TextButton(onPressed: _pickImage, child: const Text('Choisir une photo')),
                const SizedBox(height: 8),
                _field(_nom, 'Nom', 50, icon: Icons.badge_outlined),
                _field(_postnom, 'Postnom', 50, icon: Icons.badge_outlined),
                _field(_prenom, 'Prénom', 50, icon: Icons.badge_outlined),
                _field(_lieu, 'Lieu de naissance', 100, icon: Icons.place_outlined),
                _field(_date, 'Date de naissance (AAAA-MM-JJ)', 10,
                    icon: Icons.cake_outlined, readOnly: true, onTap: _pickDate),
                _field(_parente, 'Parenté (Père, Mère, Frère…)', 50,
                    icon: Icons.family_restroom),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_isEdit ? 'Enregistrer' : 'Ajouter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
