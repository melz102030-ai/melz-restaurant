import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/legal_document_model.dart';
import '../services/legal_service.dart';

final privacyPolicyProvider = StreamProvider<LegalDocumentModel?>((ref) =>
    LegalService.streamDocument(LegalService.privacyId));

final termsConditionsProvider = StreamProvider<LegalDocumentModel?>((ref) =>
    LegalService.streamDocument(LegalService.termsId));
