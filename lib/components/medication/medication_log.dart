class MedicationLog {
  final String id; // local UUID
  final int medicationId;
  final DateTime scheduledAt;
  final DateTime takenAt;
  final String status;
  bool isSynced;


  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.scheduledAt,
    required this.takenAt,
    this.status = 'taken',
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'medication_id': medicationId,
    'scheduled_at': scheduledAt.toIso8601String(),
    'taken_at': takenAt.toIso8601String(),
    'status': status,
    'local_log_id': id,
    'is_synced': isSynced ? 1 : 0,
  };
}