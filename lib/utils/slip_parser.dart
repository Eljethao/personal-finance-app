import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SlipParseResult {
  final double? amount;
  final DateTime? date;
  final String? note;
  const SlipParseResult({this.amount, this.date, this.note});
  bool get hasData => amount != null || date != null || note != null;
}

class SlipParser {
  /// Latin script handles Arabic numerals on all slips regardless of language.
  /// Lao/Thai labels are not recognized by OCR but amount detection uses
  /// keyword matching for all supported languages.
  static Future<SlipParseResult> parse(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final lines = <String>[];
    try {
      final result = await recognizer.processImage(inputImage);
      lines.addAll(
        result.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty),
      );
    } finally {
      recognizer.close();
    }
    final fullText = lines.join('\n');

    return SlipParseResult(
      amount: _parseAmount(fullText, lines),
      date: _parseDate(fullText),
      note: _parseNote(lines),
    );
  }

  // ── Amount extraction ──────────────────────────────────────────────────────

  // Keywords that indicate the NEXT number is an amount (multi-language)
  static final _amountKeywords = RegExp(
    r'(?:amount|total|transfer|paid|pay|sum'
    r'|จำนวน|ยอด|โอน|รวม'          // Thai
    r'|ຈຳນວນ|ຍອດ|ໂອນ|ລວມ'         // Lao
    r'|金额|总额|转账'                 // Chinese
    r')\s*:?\s*',
    caseSensitive: false,
  );

  // Keywords that indicate the number is a reference/ID — skip these
  static final _idKeywords = RegExp(
    r'(?:ref|reference|transaction\s*id|txn|tx\s*id|order|no\.|#'
    r'|เลขที่|เลขอ้างอิง|รหัส'     // Thai
    r'|ໝາຍເລກ|ລະຫັດ'              // Lao
    r'|编号|参考号'                   // Chinese
    r')\s*:?\s*',
    caseSensitive: false,
  );

  static double? _parseAmount(String text, List<String> lines) {
    // Step 1: Try to find amount next to an explicit amount keyword
    final keywordMatch = _amountKeywords.firstMatch(text);
    if (keywordMatch != null) {
      final after = text.substring(keywordMatch.end,
          (keywordMatch.end + 30).clamp(0, text.length));
      final numMatch = RegExp(r'[\d,]+(?:\.\d{1,2})?').firstMatch(after);
      if (numMatch != null) {
        final v = double.tryParse(numMatch.group(0)!.replaceAll(',', ''));
        if (v != null && v > 0) return v;
      }
    }

    // Step 2: Collect all formatted numbers (with comma separators) and filter IDs
    final candidates = <double>[];
    // Only match numbers with comma formatting OR decimal — plain long ints are IDs
    final moneyPattern = RegExp(
      r'\b(\d{1,3}(?:,\d{3})+(?:\.\d{1,2})?|\d+\.\d{1,2})\b',
    );

    for (final line in lines) {
      // Skip lines that contain ID keywords
      if (_idKeywords.hasMatch(line)) continue;
      // Skip lines that look like timestamps (HH:MM:SS)
      if (RegExp(r'\d{2}:\d{2}:\d{2}').hasMatch(line)) continue;

      for (final m in moneyPattern.allMatches(line)) {
        final raw = m.group(1)!.replaceAll(',', '');
        final v = double.tryParse(raw);
        if (v != null && v >= 100) candidates.add(v); // ignore tiny amounts
      }
    }

    if (candidates.isEmpty) return null;
    // Return the largest candidate (most likely the transfer amount)
    candidates.sort((a, b) => b.compareTo(a));
    return candidates.first;
  }

  // ── Date extraction ────────────────────────────────────────────────────────

  static DateTime? _parseDate(String text) {
    // DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
    final dmy = RegExp(r'\b(\d{1,2})[/\-\.](\d{1,2})[/\-\.](\d{2,4})\b');
    for (final m in dmy.allMatches(text)) {
      final d = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      int? y = int.tryParse(m.group(3)!);
      if (d == null || mo == null || y == null) continue;
      if (y < 100) y += 2000;
      if (y > 2500) y -= 543; // Buddhist year (Thailand/Lao)
      if (d >= 1 && d <= 31 && mo >= 1 && mo <= 12) {
        try { return DateTime(y, mo, d); } catch (_) {}
      }
    }

    // YYYY/MM/DD or YYYY-MM-DD
    final ymd = RegExp(r'\b(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})\b');
    for (final m in ymd.allMatches(text)) {
      int y = int.tryParse(m.group(1)!) ?? 0;
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (mo == null || d == null) continue;
      if (y > 2500) y -= 543;
      try { return DateTime(y, mo, d); } catch (_) {}
    }

    return null;
  }

  // ── Note / merchant extraction ─────────────────────────────────────────────

  // Labels that introduce the description/memo value on a slip
  static final _descLabel = RegExp(
    r'(?:description|desc|memo|remark|detail|note|purpose)\s*:?\s*',
    caseSensitive: false,
  );

  static final _skipLine = RegExp(
    r'^\d'                            // starts with digit
    r'|LAK|THB|USD|KIP'               // currency codes
    r'|receipt|slip|bank|transfer|เงิน|โอน|ຮັບ|ສົ່ງ'
    r'|transaction|payment|ref|date|time'
    r'|success|confirm|complete|processing|pending|approved'
    r'|online|mobile|internet'
    r'|description|desc|memo|remark|detail|purpose'  // label-only lines
    // Lao bank names
    r'|\bBCEL\b|\bLDB\b|\bBPL\b|\bAPB\b|\bNAYOBA\b|\bSTB\b|\bMARCO\b|\bJDB\b'
    // Thai bank names
    r'|\bKasikorn\b|\bKBANK\b|\bSCB\b|\bKTB\b|\bBBL\b|\bTMB\b|\bBAY\b|\bKKP\b',
    caseSensitive: false,
  );

  static final _hasLetter = RegExp(r'[a-zA-Z฀-๿຀-໿一-鿿]');

  static String? _parseNote(List<String> lines) {
    // Step 1: find a description label and pull the value that follows it
    for (int i = 0; i < lines.length; i++) {
      final m = _descLabel.firstMatch(lines[i]);
      if (m == null) continue;
      // Value may be inline after the label
      final inline = lines[i].substring(m.end).trim();
      if (inline.length >= 2 && !_skipLine.hasMatch(inline) && _hasLetter.hasMatch(inline)) {
        return inline;
      }
      // Or on the next line
      if (i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.length >= 2 && next.length <= 60 && !_skipLine.hasMatch(next) && _hasLetter.hasMatch(next)) {
          return next;
        }
      }
    }

    // Step 2: collect all meaningful lines and return the last one
    // (description field is typically at the bottom of bank slips)
    final candidates = <String>[];
    for (final l in lines) {
      if (l.length < 3 || l.length > 60) continue;
      if (_skipLine.hasMatch(l)) continue;
      if (!_hasLetter.hasMatch(l)) continue;
      // Skip garbled date/time lines — any line containing /YYYY or YYYY/
      if (RegExp(r'[/\-]\d{4}|\d{4}[/\-]').hasMatch(l)) continue;
      // Skip reference/transaction IDs — two or more hyphen-separated alphanumeric segments
      if (RegExp(r'[a-zA-Z0-9]+-[a-zA-Z0-9]+-').hasMatch(l)) continue;
      // Skip lines where more than half the characters are digits (ID/ref numbers)
      final digitCount = l.replaceAll(RegExp(r'[^0-9]'), '').length;
      if (digitCount > l.length / 2) continue;
      // Skip lines with fewer than 2 actual letters (OCR noise)
      final letters = l.replaceAll(RegExp(r'[^a-zA-Z฀-๿຀-໿一-鿿]'), '');
      if (letters.length < 2) continue;
      candidates.add(l);
    }
    return candidates.isNotEmpty ? candidates.last : null;
  }
}
