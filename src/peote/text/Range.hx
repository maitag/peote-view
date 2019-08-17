package peote.text;

class Range {
	public static inline function C0ControlsBasicLatin()                return new Range(0x0000, 0x007F);
	public static inline function C1ControlsLatin1Supplement()          return new Range(0x0080, 0x00FF);
	public static inline function LatinExtendedA()                      return new Range(0x0100, 0x017F);
	public static inline function LatinExtendedB()                      return new Range(0x0180, 0x024F);
	public static inline function IPAExtensions()                       return new Range(0x0250, 0x02AF);
	public static inline function SpacingModifierLetters()              return new Range(0x02B0, 0x02FF);
	public static inline function CombiningDiacriticalMarks()           return new Range(0x0300, 0x036F);
	public static inline function GreekCoptic()                         return new Range(0x0370, 0x03FF);
	public static inline function Cyrillic()                            return new Range(0x0400, 0x04FF);
	public static inline function CyrillicSupplement()                  return new Range(0x0500, 0x052F);
	public static inline function Armenian()                            return new Range(0x0530, 0x058F);
	public static inline function Hebrew()                              return new Range(0x0590, 0x05FF);
	public static inline function Arabic()                              return new Range(0x0600, 0x06FF);
	public static inline function Syriac()                              return new Range(0x0700, 0x074F);
	public static inline function ArabicSupplement()                    return new Range(0x0750, 0x077F);
	public static inline function Thaana()                              return new Range(0x0780, 0x07BF);
	public static inline function NKo()                                 return new Range(0x07C0, 0x07FF);
	public static inline function Samaritan()                           return new Range(0x0800, 0x083F);
	public static inline function Mandaic()                             return new Range(0x0840, 0x085F);
	public static inline function ArabicExtendedA()                     return new Range(0x08A0, 0x08FF);
	public static inline function Devanagari()                          return new Range(0x0900, 0x097F);
	public static inline function Bengali()                             return new Range(0x0980, 0x09FF);
	public static inline function Gurmukhi()                            return new Range(0x0A00, 0x0A7F);
	public static inline function Gujarati()                            return new Range(0x0A80, 0x0AFF);
	public static inline function Oriya()                               return new Range(0x0B00, 0x0B7F);
	public static inline function Tamil()                               return new Range(0x0B80, 0x0BFF);
	public static inline function Telugu()                              return new Range(0x0C00, 0x0C7F);
	public static inline function Kannada()                             return new Range(0x0C80, 0x0CFF);
	public static inline function Malayalam()                           return new Range(0x0D00, 0x0D7F);
	public static inline function Sinhala()                             return new Range(0x0D80, 0x0DFF);
	public static inline function Thai()                                return new Range(0x0E00, 0x0E7F);
	public static inline function Lao()                                 return new Range(0x0E80, 0x0EFF);
	public static inline function Tibetan()                             return new Range(0x0F00, 0x0FFF);
	public static inline function Myanmar()                             return new Range(0x1000, 0x109F);
	public static inline function Georgian()                            return new Range(0x10A0, 0x10FF);
	public static inline function HangulJamo()                          return new Range(0x1100, 0x11FF);
	public static inline function Ethiopic()                            return new Range(0x1200, 0x137F);
	public static inline function EthiopicSupplement()                  return new Range(0x1380, 0x139F);
	public static inline function Cherokee()                            return new Range(0x13A0, 0x13FF);
	public static inline function CanadianAboriginalSyllabics()         return new Range(0x1400, 0x167F);
	public static inline function Ogham()                               return new Range(0x1680, 0x169F);
	public static inline function Runic()                               return new Range(0x16A0, 0x16FF);
	public static inline function Tagalog()                             return new Range(0x1700, 0x171F);
	public static inline function Hanunoo()                             return new Range(0x1720, 0x173F);
	public static inline function Buhid()                               return new Range(0x1740, 0x175F);
	public static inline function Tagbanwa()                            return new Range(0x1760, 0x177F);
	public static inline function Khmer()                               return new Range(0x1780, 0x17FF);
	public static inline function Mongolian()                           return new Range(0x1800, 0x18AF);
	public static inline function CanadianAboriginalSyllabicsExtended() return new Range(0x18B0, 0x18FF);
	public static inline function Limbu()                               return new Range(0x1900, 0x194F);
	public static inline function TaiLe()                               return new Range(0x1950, 0x197F);
	public static inline function NewTaiLue()                           return new Range(0x1980, 0x19DF);
	public static inline function KhmerSymbols()                        return new Range(0x19E0, 0x19FF);
	public static inline function Buginese()                            return new Range(0x1A00, 0x1A1F);
	public static inline function TaiTham()                             return new Range(0x1A20, 0x1AAF);
	public static inline function CombiningDiacriticalMarksExtended()   return new Range(0x1AB0, 0x1AFF);
	public static inline function Balinese()                            return new Range(0x1B00, 0x1B7F);
	public static inline function Sundanese()                           return new Range(0x1B80, 0x1BBF);
	public static inline function Batak()                               return new Range(0x1BC0, 0x1BFF);
	public static inline function Lepcha()                              return new Range(0x1C00, 0x1C4F);
	public static inline function OlChiki()                             return new Range(0x1C50, 0x1C7F);
	public static inline function CyrillicExtendedC()                   return new Range(0x1C80, 0x1C8F);
	public static inline function SundaneseSupplement()                 return new Range(0x1CC0, 0x1CCF);
	public static inline function VedicExtensions()                     return new Range(0x1CD0, 0x1CFF);
	public static inline function PhoneticExtensions()                  return new Range(0x1D00, 0x1D7F);
	public static inline function PhoneticExtensionsSupplement()        return new Range(0x1D80, 0x1DBF);
	public static inline function CombiningDiacriticalMarksSupplement() return new Range(0x1DC0, 0x1DFF);
	public static inline function LatinExtendedAdditional()             return new Range(0x1E00, 0x1EFF);
	public static inline function GreekExtended()                       return new Range(0x1F00, 0x1FFF);
	public static inline function GeneralPunctuation()                  return new Range(0x2000, 0x206F);
	public static inline function SuperscriptsSubscripts()              return new Range(0x2070, 0x209F);
	public static inline function CurrencySymbols()                     return new Range(0x20A0, 0x20CF);
	public static inline function CombiningDiacriticalMarksForSymbols() return new Range(0x20D0, 0x20FF);
	public static inline function LetterlikeSymbols()                   return new Range(0x2100, 0x214F);
	public static inline function NumberForms()                         return new Range(0x2150, 0x218F);
	public static inline function Arrows()                              return new Range(0x2190, 0x21FF);
	public static inline function MathematicalOperators()               return new Range(0x2200, 0x22FF);
	public static inline function MiscellaneousTechnical()              return new Range(0x2300, 0x23FF);
	public static inline function ControlPictures()                     return new Range(0x2400, 0x243F);
	public static inline function OpticalCharacterRecognition()         return new Range(0x2440, 0x245F);
	public static inline function EnclosedAlphanumerics()               return new Range(0x2460, 0x24FF);
	public static inline function BoxDrawing()                          return new Range(0x2500, 0x257F);
	public static inline function BlockElements()                       return new Range(0x2580, 0x259F);
	public static inline function GeometricShapes()                     return new Range(0x25A0, 0x25FF);
	public static inline function MiscellaneousSymbols()                return new Range(0x2600, 0x26FF);
	public static inline function Dingbats()                            return new Range(0x2700, 0x27BF);
	public static inline function MiscellaneousMathematicalSymbolsA()   return new Range(0x27C0, 0x27EF);
	public static inline function SupplementalArrowsA()                 return new Range(0x27F0, 0x27FF);
	public static inline function BraillePatterns()                     return new Range(0x2800, 0x28FF);
	public static inline function SupplementalArrowsB()                 return new Range(0x2900, 0x297F);
	public static inline function MiscellaneousMathematicalSymbolsB()   return new Range(0x2980, 0x29FF);
	public static inline function SupplementalMathematicalOperators()   return new Range(0x2A00, 0x2AFF);
	public static inline function MiscellaneousSymbolsArrows()          return new Range(0x2B00, 0x2BFF);
	public static inline function Glagolithic()                         return new Range(0x2C00, 0x2C5F);
	public static inline function LatinExtendedC()                      return new Range(0x2C60, 0x2C7F);
	public static inline function Coptic()                              return new Range(0x2C80, 0x2CFF);
	public static inline function GeorgianSupplement()                  return new Range(0x2D00, 0x2D2F);
	public static inline function Tifinagh()                            return new Range(0x2D30, 0x2D7F);
	public static inline function EthiopicExtended()                    return new Range(0x2D80, 0x2DDF);
	public static inline function SupplementalPunctuation()             return new Range(0x2E00, 0x2E7F);
	public static inline function CJKRadicalsSupplement()               return new Range(0x2E80, 0x2EFF);
	public static inline function KangxiRadicals()                      return new Range(0x2F00, 0x2FDF);
	public static inline function IdeographicDescriptionCharacters()    return new Range(0x2FF0, 0x2FFF);
	public static inline function CJKSymbolsPunctuation()               return new Range(0x3000, 0x303F);
	public static inline function Hiragana()                            return new Range(0x3040, 0x309F);
	public static inline function Katakana()                            return new Range(0x30A0, 0x30FF);
	public static inline function Bopomofo()                            return new Range(0x3100, 0x312F);
	public static inline function HangulCompatibilityJamo()             return new Range(0x3130, 0x318F);
	public static inline function Kanbun()                              return new Range(0x3190, 0x319F);
	public static inline function BopomofoExtended()                    return new Range(0x31A0, 0x31BF);
	public static inline function CJKStrokes()                          return new Range(0x31C0, 0x31EF);
	public static inline function KatakanaPhoneticExtensions()          return new Range(0x31F0, 0x31FF);
	public static inline function EnclosedCJKLettersMonths()            return new Range(0x3200, 0x32FF);
	public static inline function CJKCompatibility()                    return new Range(0x3300, 0x33FF);
	public static inline function CJKUnifiedIdeographsExtensionA()      return new Range(0x3400, 0x4DBF);
	public static inline function YijingHexagramSymbols()               return new Range(0x4DC0, 0x4DFF);
	public static inline function CJKUnifiedIdeographs()                return new Range(0x4E00, 0x9FCF);
	public static inline function YiSyllables()                         return new Range(0xA000, 0xA48F);
	public static inline function YiRadicals()                          return new Range(0xA490, 0xA4CF);
	public static inline function Lisu()                                return new Range(0xA4D0, 0xA4FF);
	public static inline function Vai()                                 return new Range(0xA500, 0xA63F);
	public static inline function Bamum()                               return new Range(0xA6A0, 0xA6FF);
	public static inline function ModifierToneLetters()                 return new Range(0xA700, 0xA71F);
	public static inline function LatinExtendedD()                      return new Range(0xA720, 0xA7FF);
	public static inline function SylotiNagri()                         return new Range(0xA800, 0xA82F);
	public static inline function CommonIndicNumberForms()              return new Range(0xA830, 0xA83F);
	public static inline function PhagsPa()                             return new Range(0xA840, 0xA87F);
	public static inline function Saurashtra()                          return new Range(0xA880, 0xA8DF);
	public static inline function DevanagariExtended()                  return new Range(0xA8E0, 0xA8FF);
	public static inline function KayahLi()                             return new Range(0xA900, 0xA92F);
	public static inline function Rejang()                              return new Range(0xA930, 0xA95F);
	public static inline function HangulJamoExtendedA()                 return new Range(0xA960, 0xA97F);
	public static inline function Javanese()                            return new Range(0xA980, 0xA9DF);
	public static inline function MyanmarExtendedB()                    return new Range(0xA9E0, 0xA9FF);
	public static inline function Cham()                                return new Range(0xAA00, 0xAA5F);
	public static inline function MyanmarExtendedA()                    return new Range(0xAA60, 0xAA7F);
	public static inline function TaiViet()                             return new Range(0xAA80, 0xAADF);
	public static inline function MeeteiMayekExtensions()               return new Range(0xAAE0, 0xAAFF);
	public static inline function EthiopicExtendedA()                   return new Range(0xAB00, 0xAB2F);
	public static inline function LatinExtendedE()                      return new Range(0xAB30, 0xAB6F);
	public static inline function CherokeeSupplement()                  return new Range(0xAB70, 0xABBF);
	public static inline function MeeteiMayek()                         return new Range(0xABC0, 0xABFF);
	public static inline function HangulSyllables()                     return new Range(0xAC00, 0xD7AF);
	public static inline function HangulJamoExtendedB()                 return new Range(0xD7B0, 0xD7FF);
	public static inline function Tengwar()                             return new Range(0xE000, 0xE07F);
	public static inline function Cirth()                               return new Range(0xE080, 0xE0FF);
	public static inline function Kinya()                               return new Range(0xE150, 0xE1AF);
	public static inline function Aui()                                 return new Range(0xE280, 0xE29F);
	public static inline function Gargoyle()                            return new Range(0xE5C0, 0xE5DF);
	public static inline function Ewellic()                             return new Range(0xE680, 0xE6CF);
	public static inline function Unifon()                              return new Range(0xE740, 0xE76F);
	public static inline function Solresol()                            return new Range(0xE770, 0xE77F);
	public static inline function VisibleSpeech()                       return new Range(0xE780, 0xE7FF);
	public static inline function Monofon()                             return new Range(0xE800, 0xE82F);
	public static inline function Aiha()                                return new Range(0xF8A0, 0xF8CF);
	public static inline function Klingon()                             return new Range(0xF8D0, 0xF8FF);
	public static inline function CJKCompatibilityIdeographs()          return new Range(0xF900, 0xFAFF);
	public static inline function AlphabeticPresentationForms()         return new Range(0xFB00, 0xFB4F);
	public static inline function ArabicPresentationFormsA()            return new Range(0xFB50, 0xFDFF);
	public static inline function VariationSelectors()                  return new Range(0xFE00, 0xFE0F);
	public static inline function VerticalForms()                       return new Range(0xFE10, 0xFE1F);
	public static inline function CombiningHalfMarks()                  return new Range(0xFE20, 0xFE2F);
	public static inline function CJKCompatibilityForms()               return new Range(0xFE30, 0xFE4F);
	public static inline function SmallFormVariants()                   return new Range(0xFE50, 0xFE6F);
	public static inline function ArabicPresentationFormsB()            return new Range(0xFE70, 0xFEFF);
	public static inline function HalfwidthFullwidthForms()             return new Range(0xFF00, 0xFFEF);
	public static inline function Specials()                            return new Range(0xFFF0, 0xFFFF);
	public static inline function LinearBSyllabary()                    return new Range(0x010000, 0x01007F);
	public static inline function LinearBIdeograms()                    return new Range(0x010080, 0x0100FF);
	public static inline function AegeanNumbers()                       return new Range(0x010100, 0x01013F);
	public static inline function AncientGreekNumbers()                 return new Range(0x010140, 0x01018F);
	public static inline function AncientSymbols()                      return new Range(0x010190, 0x0101CF);
	public static inline function PhaistosDisc()                        return new Range(0x0101D0, 0x0101FF);
	public static inline function Lycian()                              return new Range(0x010280, 0x01029F);
	public static inline function Carian()                              return new Range(0x0102A0, 0x0102DF);
	public static inline function CopticEpactNumbers()                  return new Range(0x0102E0, 0x0102FF);
	public static inline function OldItalic()                           return new Range(0x010300, 0x01032F);
	public static inline function Gothic()                              return new Range(0x010330, 0x01034F);
	public static inline function OldPermic()                           return new Range(0x010350, 0x01037F);
	public static inline function Ugaritic()                            return new Range(0x010380, 0x01039F);
	public static inline function OldPersian()                          return new Range(0x0103A0, 0x0103DF);
	public static inline function Deseret()                             return new Range(0x010400, 0x01044F);
	public static inline function Shavian()                             return new Range(0x010450, 0x01047F);
	public static inline function Osmanya()                             return new Range(0x010480, 0x0104AF);
	public static inline function Osage()                               return new Range(0x0104B0, 0x0104FF);
	public static inline function Elbasan()                             return new Range(0x010500, 0x01052F);
	public static inline function CaucasianAlbanian()                   return new Range(0x010530, 0x01056F);
	public static inline function LinearA()                             return new Range(0x010600, 0x01077F);
	public static inline function CypriotSyllabary()                    return new Range(0x010800, 0x01083F);
	public static inline function ImperialAramaic()                     return new Range(0x010840, 0x01085F);
	public static inline function Palmyrene()                           return new Range(0x010860, 0x01087F);
	public static inline function Nabataean()                           return new Range(0x010880, 0x0108AF);
	public static inline function Hatran()                              return new Range(0x0108E0, 0x0108FF);
	public static inline function Phoenecian()                          return new Range(0x010900, 0x01091F);
	public static inline function Lydian()                              return new Range(0x010920, 0x01093F);
	public static inline function MeroiticHieroglyphs()                 return new Range(0x010980, 0x01099F);
	public static inline function MeroiticCursive()                     return new Range(0x0109A0, 0x0109FF);
	public static inline function Kharoshthi()                          return new Range(0x010A00, 0x010A5F);
	public static inline function OldSouthArabian()                     return new Range(0x010A60, 0x010A7F);
	public static inline function OldNorthArabian()                     return new Range(0x010A80, 0x010A9F);
	public static inline function Manichaean()                          return new Range(0x010AC0, 0x010AFF);
	public static inline function Avestan()                             return new Range(0x010B00, 0x010B3F);
	public static inline function InscriptionalParthian()               return new Range(0x010B40, 0x010B5F);
	public static inline function InscriptionalPahlavi()                return new Range(0x010B60, 0x010B7F);
	public static inline function PsalterPahlavi()                      return new Range(0x010B80, 0x010BAF);
	public static inline function OldTurkic()                           return new Range(0x010C00, 0x010C4F);
	public static inline function OldHungarian()                        return new Range(0x010C80, 0x010CFF);
	public static inline function RumiNumeralSymbols()                  return new Range(0x010E60, 0x010E7F);
	public static inline function Brahmi()                              return new Range(0x011000, 0x01107F);
	public static inline function Kaithi()                              return new Range(0x011080, 0x0110CF);
	public static inline function SoraSompeng()                         return new Range(0x0110D0, 0x0110FF);
	public static inline function Chakma()                              return new Range(0x011100, 0x01114F);
	public static inline function Mahajani()                            return new Range(0x011150, 0x01117F);
	public static inline function Sharada()                             return new Range(0x011180, 0x0111DF);
	public static inline function SinhalaArchaicNumbers()               return new Range(0x0111E0, 0x0111FF);
	public static inline function Khojki()                              return new Range(0x011200, 0x01124F);
	public static inline function Multani()                             return new Range(0x011280, 0x0112AF);
	public static inline function Khudawadi()                           return new Range(0x0112B0, 0x0112FF);
	public static inline function Grantha()                             return new Range(0x011300, 0x01137F);
	public static inline function Newa()                                return new Range(0x011400, 0x01147F);
	public static inline function Tirhuta()                             return new Range(0x011480, 0x0114DF);
	public static inline function Siddham()                             return new Range(0x011580, 0x0115FF);
	public static inline function Modi()                                return new Range(0x011600, 0x01165F);
	public static inline function MongolianSupplement()                 return new Range(0x011660, 0x01167F);
	public static inline function Takri()                               return new Range(0x011680, 0x0116CF);
	public static inline function Ahom()                                return new Range(0x011700, 0x01173F);
	public static inline function WarangCiti()                          return new Range(0x0118A0, 0x0118FF);
	public static inline function PauCinHau()                           return new Range(0x011AC0, 0x011AFF);
	public static inline function Bhaiksuki()                           return new Range(0x011C00, 0x011C6F);
	public static inline function Marchen()                             return new Range(0x011C70, 0x011CBF);	
//	public static inline function Cuneiform()                           return new Range(0x012000, 0x0123FF);
//	public static inline function CuneiformNumbersPunctuation()         return new Range(0x012400, 0x01247F);
//	public static inline function EarlyDynasticCuneiform()              return new Range(0x012480, 0x01254F);
//	public static inline function EgyptianHieroglyphs()                 return new Range(0x013000, 0x01342F);
//	public static inline function AnatolianHieroglyphs()                return new Range(0x014400, 0x01467F);
//	public static inline function BamumSupplement()                     return new Range(0x016800, 0x0168BF);
	public static inline function Mro()                                 return new Range(0x016A40, 0x016A6F);
	public static inline function BassaVah()                            return new Range(0x016AD0, 0x016AFF);
	public static inline function PahawhHmong()                         return new Range(0x016B00, 0x016B8F);
	public static inline function Miao()                                return new Range(0x016F00, 0x016F9F);
	public static inline function IdeographicSymbolsPunctuation()       return new Range(0x016FE0, 0x016FFF);
//	public static inline function Tangut()                              return new Range(0x017000, 0x0187FF);
//	public static inline function TangutComponents()                    return new Range(0x018800, 0x018AFF);
	public static inline function KanaSupplement()                      return new Range(0x01B000, 0x01B0FF);
	public static inline function Duployan()                            return new Range(0x01BC00, 0x01BC9F);
	public static inline function ShorthandFormatControls()             return new Range(0x01BCA0, 0x01BCAF);
	public static inline function ByzantineMusicalSymbols()             return new Range(0x01D000, 0x01D0FF);
	public static inline function MusicalSymbols()                      return new Range(0x01D100, 0x01D1FF);
	public static inline function AncientGreekMusicalNotation()         return new Range(0x01D200, 0x01D24F);
	public static inline function TaiXuanJingSymbols()                  return new Range(0x01D300, 0x01D35F);
	public static inline function CountingRodNumerals()                 return new Range(0x01D360, 0x01D37F);
	public static inline function MathematicalAlphanumericSymbols()     return new Range(0x01D400, 0x01D7FF);
//	public static inline function SuttonSignWriting()                   return new Range(0x01D800, 0x01DAAF);
	public static inline function GlagoliticSupplement()                return new Range(0x01E000, 0x01E02F);
	public static inline function MendeKikakui()                        return new Range(0x01E800, 0x01E8DF);
	public static inline function Adlam()                               return new Range(0x01E900, 0x01E95F);
	public static inline function ArabicMathematicalAlphabeticSymbols() return new Range(0x01EE00, 0x01EEFF);
	public static inline function MahjongTiles()                        return new Range(0x01F000, 0x01F02F);
	public static inline function DominoTiles()                         return new Range(0x01F030, 0x01F09F);
	public static inline function PlayingCards()                        return new Range(0x01F0A0, 0x01F0FF);
	public static inline function EnclosedAlphanumericSupplement()      return new Range(0x01F100, 0x01F1FF);
	public static inline function EnclosedIdeographicSupplement()       return new Range(0x01F200, 0x01F2FF);
	public static inline function MiscellaneousSymbolsPictographs()     return new Range(0x01F300, 0x01F5FF);
	public static inline function Emoticons()                           return new Range(0x01F600, 0x01F64F);
	public static inline function OrnamentalDingbats()                  return new Range(0x01F650, 0x01F67F);
	public static inline function TransportMapSymbols()                 return new Range(0x01F680, 0x01F6FF);
	public static inline function AlchemicalSymbols()                   return new Range(0x01F700, 0x01F77F);
	public static inline function GeometricShapesExtended()             return new Range(0x01F780, 0x01F7FF);
	public static inline function SupplementalArrowsC()                 return new Range(0x01F800, 0x01F8FF);
	public static inline function SupplementalSymbolsPictographs()      return new Range(0x01F900, 0x01F9FF);
	public static inline function KinyaSyllables()                      return new Range(0x0F0000, 0x0F0E69);

	public static var namesRanges = [
		{name:"C0 Controls and Basic Latin", range:C0ControlsBasicLatin()},
		{name:"C1 Controls and Latin-1 Supplement", range:C1ControlsLatin1Supplement()},
		{name:"Latin Extended - A", range:LatinExtendedA()},
		{name:"Latin Extended - B", range:LatinExtendedB()},
		{name:"IPA Extensions", range:IPAExtensions()},
		{name:"Spacing Modifier Letters", range:SpacingModifierLetters()},
		{name:"Combining Diacritical Marks", range:CombiningDiacriticalMarks()},
		{name:"Greek and Coptic", range:GreekCoptic()},
		{name:"Cyrillic", range:Cyrillic()},
		{name:"Cyrillic Supplement", range:CyrillicSupplement()},
		{name:"Armenian", range:Armenian()},
		{name:"Hebrew", range:Hebrew()},
		{name:"Arabic", range:Arabic()},
		{name:"Syriac", range:Syriac()},
		{name:"Arabic Supplement", range:ArabicSupplement()},
		{name:"Thaana", range:Thaana()},
		{name:"N'Ko", range:NKo()},
		{name:"Samaritan", range:Samaritan()},
		{name:"Mandaic", range:Mandaic()},
		{name:"Arabic Extended - A", range:ArabicExtendedA()},
		{name:"Devanagari", range:Devanagari()},
		{name:"Bengali", range:Bengali()},
		{name:"Gurmukhi", range:Gurmukhi()},
		{name:"Gujarati", range:Gujarati()},
		{name:"Oriya", range:Oriya()},
		{name:"Tamil", range:Tamil()},
		{name:"Telugu", range:Telugu()},
		{name:"Kannada", range:Kannada()},
		{name:"Malayalam", range:Malayalam()},
		{name:"Sinhala", range:Sinhala()},
		{name:"Thai", range:Thai()},
		{name:"Lao", range:Lao()},
		{name:"Tibetan", range:Tibetan()},
		{name:"Myanmar", range:Myanmar()},
		{name:"Georgian", range:Georgian()},
		{name:"Hangul Jamo", range:HangulJamo()},
		{name:"Ethiopic", range:Ethiopic()},
		{name:"Ethiopic Supplement", range:EthiopicSupplement()},
		{name:"Cherokee", range:Cherokee()},
		{name:"Unified Canadian Aboriginal Syllabics", range:CanadianAboriginalSyllabics()},
		{name:"Ogham", range:Ogham()},
		{name:"Runic", range:Runic()},
		{name:"Tagalog", range:Tagalog()},
		{name:"Hanunoo", range:Hanunoo()},
		{name:"Buhid", range:Buhid()},
		{name:"Tagbanwa", range:Tagbanwa()},
		{name:"Khmer", range:Khmer()},
		{name:"Mongolian", range:Mongolian()},
		{name:"Unified Canadian Aboriginal Syllabics Extended", range:CanadianAboriginalSyllabicsExtended()},
		{name:"Limbu", range:Limbu()},
		{name:"Tai Le", range:TaiLe()},
		{name:"New Tai Lue", range:NewTaiLue()},
		{name:"Khmer Symbols", range:KhmerSymbols()},
		{name:"Buginese", range:Buginese()},
		{name:"Tai Tham", range:TaiTham()},
		{name:"Combining Diacritical Marks Extended", range:CombiningDiacriticalMarksExtended()},
		{name:"Balinese", range:Balinese()},
		{name:"Sundanese", range:Sundanese()},
		{name:"Batak", range:Batak()},
		{name:"Lepcha", range:Lepcha()},
		{name:"Ol Chiki", range:OlChiki()},
		{name:"Cyrillic Extended - C", range:CyrillicExtendedC()},
		{name:"Sundanese Supplement", range:SundaneseSupplement()},
		{name:"Vedic Extensions", range:VedicExtensions()},
		{name:"Phonetic Extensions", range:PhoneticExtensions()},
		{name:"Phonetic Extensions Supplement", range:PhoneticExtensionsSupplement()},
		{name:"Combining Diacritical Marks Supplement", range:CombiningDiacriticalMarksSupplement()},
		{name:"Latin Extended Additional", range:LatinExtendedAdditional()},
		{name:"Greek Extended", range:GreekExtended()},
		{name:"General Punctuation", range:GeneralPunctuation()},
		{name:"Superscripts and Subscripts", range:SuperscriptsSubscripts()},
		{name:"Currency Symbols", range:CurrencySymbols()},
		{name:"Combining Diacritical Marks for Symbols", range:CombiningDiacriticalMarksForSymbols()},
		{name:"Letterlike Symbols", range:LetterlikeSymbols()},
		{name:"Number Forms", range:NumberForms()},
		{name:"Arrows", range:Arrows()},
		{name:"Mathematical Operators", range:MathematicalOperators()},
		{name:"Miscellaneous Technical", range:MiscellaneousTechnical()},
		{name:"Control Pictures", range:ControlPictures()},
		{name:"Optical Character Recognition", range:OpticalCharacterRecognition()},
		{name:"Enclosed Alphanumerics", range:EnclosedAlphanumerics()},
		{name:"Box Drawing", range:BoxDrawing()},
		{name:"Block Elements", range:BlockElements()},
		{name:"Geometric Shapes", range:GeometricShapes()},
		{name:"Miscellaneous Symbols", range:MiscellaneousSymbols()},
		{name:"Dingbats", range:Dingbats()},
		{name:"Miscellaneous Mathematical Symbols - A", range:MiscellaneousMathematicalSymbolsA()},
		{name:"Supplemental Arrows - A", range:SupplementalArrowsA()},
		{name:"Braille Patterns", range:BraillePatterns()},
		{name:"Supplemental Arrows - B", range:SupplementalArrowsB()},
		{name:"Miscellaneous Mathematical Symbols - B", range:MiscellaneousMathematicalSymbolsB()},
		{name:"Supplemental Mathematical Operators", range:SupplementalMathematicalOperators()},
		{name:"Miscellaneous Symbols and Arrows", range:MiscellaneousSymbolsArrows()},
		{name:"Glagolithic", range:Glagolithic()},
		{name:"Latin Extended - C", range:LatinExtendedC()},
		{name:"Coptic", range:Coptic()},
		{name:"Georgian Supplement", range:GeorgianSupplement()},
		{name:"Tifinagh", range:Tifinagh()},
		{name:"Ethiopic Extended", range:EthiopicExtended()},
		{name:"Supplemental Punctuation", range:SupplementalPunctuation()},
		{name:"CJK Radicals Supplement", range:CJKRadicalsSupplement()},
		{name:"Kangxi Radicals", range:KangxiRadicals()},
		{name:"Ideographic Description Characters", range:IdeographicDescriptionCharacters()},
		{name:"CJK Symbols and Punctuation", range:CJKSymbolsPunctuation()},
		{name:"Hiragana", range:Hiragana()},
		{name:"Katakana", range:Katakana()},
		{name:"Bopomofo", range:Bopomofo()},
		{name:"Hangul Compatibility Jamo", range:HangulCompatibilityJamo()},
		{name:"Kanbun", range:Kanbun()},
		{name:"Bopomofo Extended", range:BopomofoExtended()},
		{name:"CJK Strokes", range:CJKStrokes()},
		{name:"Katakana Phonetic Extensions", range:KatakanaPhoneticExtensions()},
		{name:"Enclosed CJK Letters and Months", range:EnclosedCJKLettersMonths()},
		{name:"CJK Compatibility", range:CJKCompatibility()},
		{name:"CJK Unified Ideographs Extension A", range:CJKUnifiedIdeographsExtensionA()},
		{name:"Yijing Hexagram Symbols", range:YijingHexagramSymbols()},
		{name:"CJK Unified Ideographs", range:CJKUnifiedIdeographs()},
		{name:"Yi Syllables", range:YiSyllables()},
		{name:"Yi Radicals", range:YiRadicals()},
		{name:"Lisu", range:Lisu()},
		{name:"Vai", range:Vai()},
		{name:"Bamum", range:Bamum()},
		{name:"Modifier Tone Letters", range:ModifierToneLetters()},
		{name:"Latin Extended - D", range:LatinExtendedD()},
		{name:"Syloti Nagri", range:SylotiNagri()},
		{name:"Common Indic Number Forms", range:CommonIndicNumberForms()},
		{name:"Phags-pa", range:PhagsPa()},
		{name:"Saurashtra", range:Saurashtra()},
		{name:"Devanagari Extended", range:DevanagariExtended()},
		{name:"Kayah Li", range:KayahLi()},
		{name:"Rejang", range:Rejang()},
		{name:"Hangul Jamo Extended - A", range:HangulJamoExtendedA()},
		{name:"Javanese", range:Javanese()},
		{name:"Myanmar Extended - B", range:MyanmarExtendedB()},
		{name:"Cham", range:Cham()},
		{name:"Myanmar Extended - A", range:MyanmarExtendedA()},
		{name:"Tai Viet", range:TaiViet()},
		{name:"Meetei Mayek Extensions", range:MeeteiMayekExtensions()},
		{name:"Ethiopic Extended - A", range:EthiopicExtendedA()},
		{name:"Latin Extended - E", range:LatinExtendedE()},
		{name:"Cherokee Supplement", range:CherokeeSupplement()},
		{name:"Meetei Mayek", range:MeeteiMayek()},
		{name:"Hangul Syllables", range:HangulSyllables()},
		{name:"Hangul Jamo Extended - B", range:HangulJamoExtendedB()},
		{name:"Tengwar", range:Tengwar()},
		{name:"Cirth", range:Cirth()},
		{name:"Kinya", range:Kinya()},
		{name:"Aui", range:Aui()},
		{name:"Gargoyle", range:Gargoyle()},
		{name:"Ewellic", range:Ewellic()},
		{name:"Unifon", range:Unifon()},
		{name:"Solresol", range:Solresol()},
		{name:"Visible Speech", range:VisibleSpeech()},
		{name:"Monofon", range:Monofon()},
		{name:"Aiha", range:Aiha()},
		{name:"Klingon", range:Klingon()},
		{name:"CJK Compatibility Ideographs", range:CJKCompatibilityIdeographs()},
		{name:"Alphabetic Presentation Forms", range:AlphabeticPresentationForms()},
		{name:"Arabic Presentation Forms - A", range:ArabicPresentationFormsA()},
		{name:"Variation Selectors", range:VariationSelectors()},
		{name:"Vertical Forms", range:VerticalForms()},
		{name:"Combining Half Marks", range:CombiningHalfMarks()},
		{name:"CJK Compatibility Forms", range:CJKCompatibilityForms()},
		{name:"Small Form Variants", range:SmallFormVariants()},
		{name:"Arabic Presentation Forms - B", range:ArabicPresentationFormsB()},
		{name:"Halfwidth and Fullwidth Forms", range:HalfwidthFullwidthForms()},
		{name:"Specials", range:Specials()},
		{name:"Linear B Syllabary", range:LinearBSyllabary()},
		{name:"Linear B Ideograms", range:LinearBIdeograms()},
		{name:"Aegean Numbers", range:AegeanNumbers()},
		{name:"Ancient Greek Numbers", range:AncientGreekNumbers()},
		{name:"Ancient Symbols", range:AncientSymbols()},
		{name:"Phaistos Disc", range:PhaistosDisc()},
		{name:"Lycian", range:Lycian()},
		{name:"Carian", range:Carian()},
		{name:"Coptic Epact Numbers", range:CopticEpactNumbers()},
		{name:"Old Italic", range:OldItalic()},
		{name:"Gothic", range:Gothic()},
		{name:"Old Permic", range:OldPermic()},
		{name:"Ugaritic", range:Ugaritic()},
		{name:"Old Persian", range:OldPersian()},
		{name:"Deseret", range:Deseret()},
		{name:"Shavian", range:Shavian()},
		{name:"Osmanya", range:Osmanya()},
		{name:"Osage", range:Osage()},
		{name:"Elbasan", range:Elbasan()},
		{name:"Caucasian Albanian", range:CaucasianAlbanian()},
		{name:"Linear A", range:LinearA()},
		{name:"Cypriot Syllabary", range:CypriotSyllabary()},
		{name:"Imperial Aramaic", range:ImperialAramaic()},
		{name:"Palmyrene", range:Palmyrene()},
		{name:"Nabataean", range:Nabataean()},
		{name:"Hatran", range:Hatran()},
		{name:"Phoenecian", range:Phoenecian()},
		{name:"Lydian", range:Lydian()},
		{name:"Meroitic Hieroglyphs", range:MeroiticHieroglyphs()},
		{name:"Meroitic Cursive", range:MeroiticCursive()},
		{name:"Kharoshthi", range:Kharoshthi()},
		{name:"Old South Arabian", range:OldSouthArabian()},
		{name:"Old North Arabian", range:OldNorthArabian()},
		{name:"Manichaean", range:Manichaean()},
		{name:"Avestan", range:Avestan()},
		{name:"Inscriptional Parthian", range:InscriptionalParthian()},
		{name:"Inscriptional Pahlavi", range:InscriptionalPahlavi()},
		{name:"Psalter Pahlavi", range:PsalterPahlavi()},
		{name:"Old Turkic", range:OldTurkic()},
		{name:"Old Hungarian", range:OldHungarian()},
		{name:"Rumi Numeral Symbols", range:RumiNumeralSymbols()},
		{name:"Brahmi", range:Brahmi()},
		{name:"Kaithi", range:Kaithi()},
		{name:"Sora Sompeng", range:SoraSompeng()},
		{name:"Chakma", range:Chakma()},
		{name:"Mahajani", range:Mahajani()},
		{name:"Sharada", range:Sharada()},
		{name:"Sinhala Archaic Numbers", range:SinhalaArchaicNumbers()},
		{name:"Khojki", range:Khojki()},
		{name:"Multani", range:Multani()},
		{name:"Khudawadi", range:Khudawadi()},
		{name:"Grantha", range:Grantha()},
		{name:"Newa", range:Newa()},
		{name:"Tirhuta", range:Tirhuta()},
		{name:"Siddham", range:Siddham()},
		{name:"Modi", range:Modi()},
		{name:"Mongolian Supplement", range:MongolianSupplement()},
		{name:"Takri", range:Takri()},
		{name:"Ahom", range:Ahom()},
		{name:"Warang Citi", range:WarangCiti()},
		{name:"Pau Cin Hau", range:PauCinHau()},
		{name:"Bhaiksuki", range:Bhaiksuki()},
		{name:"Marchen", range:Marchen()},
//		{name:"Cuneiform", range:Cuneiform()},
//		{name:"Cuneiform Numbers and Punctuation", range:CuneiformNumbersPunctuation()},
//		{name:"Early Dynastic Cuneiform", range:EarlyDynasticCuneiform()},
//		{name:"Egyptian Hieroglyphs", range:EgyptianHieroglyphs()},
//		{name:"Anatolian Hieroglyphs", range:AnatolianHieroglyphs()},
//		{name:"Bamum Supplement", range:BamumSupplement()},
		{name:"Mro", range:Mro()},
		{name:"Bassa Vah", range:BassaVah()},
		{name:"Pahawh Hmong", range:PahawhHmong()},
		{name:"Miao", range:Miao()},
		{name:"Ideographic Symbols and Punctuation", range:IdeographicSymbolsPunctuation()},
//		{name:"Tangut", range:Tangut()},
//		{name:"Tangut Components", range:TangutComponents()},
		{name:"Kana Supplement", range:KanaSupplement()},
		{name:"Duployan", range:Duployan()},
		{name:"Shorthand Format Controls", range:ShorthandFormatControls()},
		{name:"Byzantine Musical Symbols", range:ByzantineMusicalSymbols()},
		{name:"Musical Symbols", range:MusicalSymbols()},
		{name:"Ancient Greek Musical Notation", range:AncientGreekMusicalNotation()},
		{name:"Tai Xuan Jing Symbols", range:TaiXuanJingSymbols()},
		{name:"Counting Rod Numerals", range:CountingRodNumerals()},
		{name:"Mathematical Alphanumeric Symbols", range:MathematicalAlphanumericSymbols()},
//		{name:"Sutton SignWriting", range:SuttonSignWriting()},
		{name:"Glagolitic Supplement", range:GlagoliticSupplement()},
		{name:"Mende Kikakui", range:MendeKikakui()},
		{name:"Adlam", range:Adlam()},
		{name:"Arabic Mathematical Alphabetic Symbols", range:ArabicMathematicalAlphabeticSymbols()},
		{name:"Mahjong Tiles", range:MahjongTiles()},
		{name:"Domino Tiles", range:DominoTiles()},
		{name:"Playing Cards", range:PlayingCards()},
		{name:"Enclosed Alphanumeric Supplement", range:EnclosedAlphanumericSupplement()},
		{name:"Enclosed Ideographic Supplement", range:EnclosedIdeographicSupplement()},
		{name:"Miscellaneous Symbols and Pictographs", range:MiscellaneousSymbolsPictographs()},
		{name:"Emoticons", range:Emoticons()},
		{name:"Ornamental Dingbats", range:OrnamentalDingbats()},
		{name:"Transport and Map Symbols", range:TransportMapSymbols()},
		{name:"Alchemical Symbols", range:AlchemicalSymbols()},
		{name:"Geometric Shapes Extended", range:GeometricShapesExtended()},
		{name:"Supplemental Arrows - C", range:SupplementalArrowsC()},
		{name:"Supplemental Symbols and Pictographs", range:SupplementalSymbolsPictographs()},
		{name:"Kinya Syllables", range:KinyaSyllables()},
	];
	
	public var min(default, null):Int;
	public var max(default, null):Int;
	
	public inline function new(min:Int, max:Int)
	{
		this.min = min;
		this.max = max;
	}
}
