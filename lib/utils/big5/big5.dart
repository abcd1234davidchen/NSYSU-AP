library big5;

part 'table.dart';

// only non-sream version

const Big5Codec big5 = Big5Codec();

class Big5Codec {
  const Big5Codec();

  String decode(List<int> src) {
    return big5TransformDecode(src);
  }

  List<int> encode(String src) {
    return big5TransformEncode(src);
  }
}

// big5 constants.
const int runeError = 0xFFFD;
const int runeSelf = 0x80;

String big5TransformDecode(List<int> src) {
  int r = 0;
  int size = 0;
  String nDst = '';

  void write(int input) => nDst += String.fromCharCode(input);

  for (int nSrc = 0; nSrc < src.length; nSrc += size) {
    final int c0 = src[nSrc];
    if (c0 < 0x80) {
      r = c0;
      size = 1;
    } else if (0x81 <= c0 && c0 < 0xFF) {
      if (nSrc + 1 >= src.length) {
        r = runeError;
        size = 1;
        write(r);
        continue;
      }
      final int c1 = src[nSrc + 1];
      r = 0xfffd;
      size = 2;

      final int i = c0 * 16 * 16 + c1;
      final int? s = decode[i];
      if (s != null) {
        write(s);
        continue;
      }
    } else {
      r = runeError;
      size = 1;
    }
    write(r);
    continue;
  }
  return nDst;
}

List<int> big5TransformEncode(String src) {
  final List<int> runes = Runes(src).toList();

  int r = 0;
  int size = 0;
  final List<int> dst = <int>[];

  void write2(int r) {
    dst.add(r >> 8);
    dst.add(r % 256);
  }

  for (int nSrc = 0; nSrc < runes.length; nSrc += size) {
    r = runes[nSrc];

    // Decode a 1-byte rune.
    if (r < runeSelf) {
      size = 1;
      dst.add(r);
      continue;
    } else {
      // Decode a multi-byte rune.
      // TODO handle some error
      size = 1;
    }

    if (r >= runeSelf) {
      if (encode0Low <= r && r < encode0High) {
        r = encode0[r - encode0Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode1Low <= r && r < encode1High) {
        r = encode1[r - encode1Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode2Low <= r && r < encode2High) {
        r = encode2[r - encode2Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode3Low <= r && r < encode3High) {
        r = encode3[r - encode3Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode4Low <= r && r < encode4High) {
        r = encode4[r - encode4Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode5Low <= r && r < encode5High) {
        r = encode5[r - encode5Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode6Low <= r && r < encode6High) {
        r = encode6[r - encode6Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      } else if (encode7Low <= r && r < encode7High) {
        r = encode7[r - encode7Low]!;
        if (r != 0) {
          write2(r);
          continue;
        }
      }
      // TODO handle err
      break;
    }
  }
  return dst;
}
