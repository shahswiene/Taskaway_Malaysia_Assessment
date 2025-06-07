import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Provides the Supabase client instance.
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
