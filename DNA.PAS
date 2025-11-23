program DNA_Synthesis;
{
  ДНК-СИНТЕЗАТОР БЕЛКА
  Модель производитель-потребитель с биологическим уклоном
  
  Лабораторная работа №3
  по дисциплине: Операционные системы
  Тема: Эмуляция работы параллельных процессов на примере схемы <производитель-потребитель>

  Выполнил: thepashbash

}

{$M $1000, 0, 0}

uses
  Crt, Dos;

const
  MAX_BUFFER_SIZE = 10;
  MAX_PRODUCERS = 4;
  MAX_CONSUMERS = 4;
  PRODUCER_PRIORITY = 100;
  CONSUMER_PRIORITY = 100;
  MAX_PROTEIN_CHAIN_LENDTH = 1000;
  
  SYNTHESIS_QUEUE_LENGTH = 6;
  CODON_LENGTH = 3;
  
  { Цвета }
  COLOR_ADENINE = 10;    { Зеленый }
  COLOR_THYMINE = 12;    { Красный }
  COLOR_GUANINE = 11;    { Голубой }
  COLOR_CYTOSINE = 13;   { Фиолетовый }
  COLOR_STATUS = 15;     { Белый }
  COLOR_ACTIVE = 10;     { Зеленый }
  COLOR_WAITING = 14;    { Желтый }
  COLOR_COMPLETED = 12;  { Красный }
  
  
  GeneticCodeTable: array[1..64] of record
    Codon: String[3];
    Name: String[15];
    Symbol: Char;
  end = (
    (Codon: 'AUG'; Name: 'Мет (Старт)'; Symbol: 'M'),
    (Codon: 'UUU'; Name: 'Фен'; Symbol: 'F'),
    (Codon: 'UUC'; Name: 'Фен'; Symbol: 'F'),
    (Codon: 'UUA'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'UUG'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'CUU'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'CUC'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'CUA'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'CUG'; Name: 'Лей'; Symbol: 'L'),
    (Codon: 'AUU'; Name: 'Иле'; Symbol: 'I'),
    (Codon: 'AUC'; Name: 'Иле'; Symbol: 'I'),
    (Codon: 'AUA'; Name: 'Иле'; Symbol: 'I'),
    (Codon: 'GUU'; Name: 'Вал'; Symbol: 'V'),
    (Codon: 'GUC'; Name: 'Вал'; Symbol: 'V'),
    (Codon: 'GUA'; Name: 'Вал'; Symbol: 'V'),
    (Codon: 'GUG'; Name: 'Вал'; Symbol: 'V'),
    (Codon: 'UCU'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'UCC'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'UCA'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'UCG'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'AGU'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'AGC'; Name: 'Сер'; Symbol: 'S'),
    (Codon: 'CCU'; Name: 'Про'; Symbol: 'P'),
    (Codon: 'CCC'; Name: 'Про'; Symbol: 'P'),
    (Codon: 'CCA'; Name: 'Про'; Symbol: 'P'),
    (Codon: 'CCG'; Name: 'Про'; Symbol: 'P'),
    (Codon: 'ACU'; Name: 'Тре'; Symbol: 'T'),
    (Codon: 'ACC'; Name: 'Тре'; Symbol: 'T'),
    (Codon: 'ACA'; Name: 'Тре'; Symbol: 'T'),
    (Codon: 'ACG'; Name: 'Тре'; Symbol: 'T'),
    (Codon: 'GCU'; Name: 'Ала'; Symbol: 'A'),
    (Codon: 'GCC'; Name: 'Ала'; Symbol: 'A'),
    (Codon: 'GCA'; Name: 'Ала'; Symbol: 'A'),
    (Codon: 'GCG'; Name: 'Ала'; Symbol: 'A'),
    (Codon: 'UAU'; Name: 'Тир'; Symbol: 'Y'),
    (Codon: 'UAC'; Name: 'Тир'; Symbol: 'Y'),
    (Codon: 'UAA'; Name: 'Охра (Стоп)'; Symbol: '*'),
    (Codon: 'UAG'; Name: 'Янтарь (Стоп)'; Symbol: '*'),
    (Codon: 'UGA'; Name: 'Опал (Стоп)'; Symbol: '*'),
    (Codon: 'CAU'; Name: 'Гис'; Symbol: 'H'),
    (Codon: 'CAC'; Name: 'Гис'; Symbol: 'H'),
    (Codon: 'CAA'; Name: 'Глн'; Symbol: 'Q'),
    (Codon: 'CAG'; Name: 'Глн'; Symbol: 'Q'),
    (Codon: 'AAU'; Name: 'Асн'; Symbol: 'N'),
    (Codon: 'AAC'; Name: 'Асн'; Symbol: 'N'),
    (Codon: 'AAA'; Name: 'Лиз'; Symbol: 'K'),
    (Codon: 'AAG'; Name: 'Лиз'; Symbol: 'K'),
    (Codon: 'GAU'; Name: 'Асп'; Symbol: 'D'),
    (Codon: 'GAC'; Name: 'Асп'; Symbol: 'D'),
    (Codon: 'GAA'; Name: 'Глу'; Symbol: 'E'),
    (Codon: 'GAG'; Name: 'Глу'; Symbol: 'E'),
    (Codon: 'UGU'; Name: 'Цис'; Symbol: 'C'),
    (Codon: 'UGC'; Name: 'Цис'; Symbol: 'C'),
    (Codon: 'UGG'; Name: 'Три'; Symbol: 'W'),
    (Codon: 'CGU'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'CGC'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'CGA'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'CGG'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'AGA'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'AGG'; Name: 'Арг'; Symbol: 'R'),
    (Codon: 'GGU'; Name: 'Гли'; Symbol: 'G'),
    (Codon: 'GGC'; Name: 'Гли'; Symbol: 'G'),
    (Codon: 'GGA'; Name: 'Гли'; Symbol: 'G'),
    (Codon: 'GGG'; Name: 'Гли'; Symbol: 'G')
  );

type
  { Базовые типы }
  TNucleotide = (ntAdenine, ntThymine, ntGuanine, ntCytosine, ntNone);
  TBasePair = (bpAT, bpTA, bpGC, bpCG, bpNone);
  TSynthesisStatus = (ssWaiting, ssActive, ssCompleted);
  TPotokType = (ptProducer, ptConsumer);
  
  { Структуры данных }
  TNucleotideRecord = record
    Nucleotide: TNucleotide;
    ID: Integer;
    TypeIDstr: array[1..4] of Char;
    Used: Boolean;
  end;

  TBasePairRecord = record
    PairType: TBasePair;
    Nucleotide1, Nucleotide2: TNucleotideRecord;
  end;

type
  TProteinChain = array[1..MAX_PROTEIN_CHAIN_LENDTH] of Char; 

  TSynthesisState = record
    Status: TSynthesisStatus;
    CurrentCodon: array[1..CODON_LENGTH] of TBasePair;
    CodonPosition: Integer;
    ProteinChain: TProteinChain;
    ProteinLength: Integer;  
  end;

  TPotok = record
    PotokType: TPotokType; 
    IsActive: Boolean;
    Priority: Integer;
  end;

  TProgramState = record
    CurrentPotok: Integer;
    Impulses: Longint;
    DelayTime: Integer;
    IsEscPressed: Boolean;
	IsRunning: Boolean;
    PotokCount: Integer;
    Potoks: array[1..MAX_PRODUCERS + MAX_CONSUMERS] of TPotok;
    NucleotidesBuffer: array[1..MAX_BUFFER_SIZE] of TNucleotideRecord;
    BufferSize: Integer;
    SynthesisQueue: array[1..SYNTHESIS_QUEUE_LENGTH] of TBasePairRecord;
	BasePairs: array[1..MAX_CONSUMERS] of TBasePairRecord;
    Synthesis: TSynthesisState;
    ProducerCounters: array[TNucleotide] of Integer;
	LastDisplayedAA: Integer;  { Последняя отображенная аминокислота }
	CurrentDisplayLine: Integer; { Текущая строка отображения }
	CurrentDisplayPos: Integer;  { Текущая позиция в строке }
  end;

var
  OldTimeHandler: procedure;
  OldKeyHandler: procedure;
  State: TProgramState;

{  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ }

procedure ValidateInputParams;
var
  Code: Integer;
  ExeName: String;
begin
  ExeName := ParamStr(0);  { Имя исполняемого файла }
  
  if ParamCount < 1 then
  begin
    Writeln('Программа запущена со стандартной задержкой, величина которой = 2000');
    Writeln('Формат: ', ExeName, ' <задержка>');
    Writeln('Задержка: 0-32767 мс');
    State.DelayTime := 2000;  { Стандартная задержка }
	Delay(2000);
    Exit;
  end;

  Val(ParamStr(1), State.DelayTime, Code);
  if (Code <> 0) or (State.DelayTime < 0) or (State.DelayTime > 32767) then
  begin
    Writeln('Ошибка: неверная задержка (0-32767)');
    Writeln('Формат: ', ExeName, ' <задержка>');
    Halt(1);
  end;
end;

function IntToStr(Value: Integer): String;
var
  S: String;
begin
  Str(Value, S);
  IntToStr := S;
end;

function NucleotideToChar(Nucleotide: TNucleotide): Char;
begin
  case Nucleotide of
    ntAdenine:  NucleotideToChar := 'A';
    ntThymine:  NucleotideToChar := 'T';
    ntGuanine:  NucleotideToChar := 'G';
    ntCytosine: NucleotideToChar := 'C';
	else NucleotideToChar := '?';
  end;
end;

function NucleotideToColor(Nucleotide: TNucleotide): Byte;
begin
  case Nucleotide of
    ntAdenine:  NucleotideToColor := COLOR_ADENINE;
    ntThymine:  NucleotideToColor := COLOR_THYMINE;
    ntGuanine:  NucleotideToColor := COLOR_GUANINE;
    ntCytosine: NucleotideToColor := COLOR_CYTOSINE;
	else NucleotideToColor := 7;
  end;
end;

function BasePairToStr(PairType: TBasePair): String;
begin
  case PairType of
    bpAT: BasePairToStr := 'A-T';
    bpTA: BasePairToStr := 'T-A';
    bpGC: BasePairToStr := 'G-C';
    bpCG: BasePairToStr := 'C-G';
    else BasePairToStr := '---';
  end;
end;

function GetBasePairType(N1, N2: TNucleotide): TBasePair;
begin
  if (N1 = ntAdenine) and (N2 = ntThymine) then GetBasePairType := bpAT
  else if (N1 = ntThymine) and (N2 = ntAdenine) then GetBasePairType := bpTA
  else if (N1 = ntGuanine) and (N2 = ntCytosine) then GetBasePairType := bpGC
  else if (N1 = ntCytosine) and (N2 = ntGuanine) then GetBasePairType := bpCG
  else GetBasePairType := bpNone;
end;



function GetCodonString(const Codon: array of TBasePair): String;
var
  i: Integer;
  TempStr: String;
begin
  TempStr := '';
  for i := 0 to CODON_LENGTH-1 do
  begin
    { Берем только ЛЕВУЮ букву из пары (правая - это партнер в ДНК) }
    case Codon[i] of
      bpAT: TempStr := TempStr + 'A';  { A-T > A }
      bpTA: TempStr := TempStr + 'U';  { T-A > U }
      bpGC: TempStr := TempStr + 'G';  { G-C > G }
      bpCG: TempStr := TempStr + 'C';  { C-G > C }
      else TempStr := TempStr + '?';
    end;
  end;
  GetCodonString := TempStr;
end;

function TranscribeToRNA(DNAPair: TBasePair): TBasePair;
begin
  { Транскрипция ДНК > РНК: Тимин > Урацил }
  case DNAPair of
    bpAT: TranscribeToRNA := bpAT;  { A-T > A-U }
    bpTA: TranscribeToRNA := bpTA;  { T-A > U-A }
    bpGC: TranscribeToRNA := bpGC;  { G-C > G-C }
    bpCG: TranscribeToRNA := bpCG;  { C-G > C-G }
    else TranscribeToRNA := bpNone;
  end;
end;

function GetAminoAcidName(CodonStr: String): String;
var
  i: Integer;
begin
  for i := 1 to 64 do
  begin
    if GeneticCodeTable[i].Codon = CodonStr then
    begin
      GetAminoAcidName := GeneticCodeTable[i].Name;
      Exit;
    end;
  end;
  GetAminoAcidName := 'Неизв';
end;

function TranslateCodonToAminoAcid(CodonStr: String): Char;
var
  i: Integer;
begin
  for i := 1 to 64 do
  begin
    if GeneticCodeTable[i].Codon = CodonStr then
    begin
      TranslateCodonToAminoAcid := GeneticCodeTable[i].Symbol;
      Exit;
    end;
  end;
  TranslateCodonToAminoAcid := '?';
end;

{ ОСНОВНЫЕ ПРОЦЕДУРЫ РАБОТЫ С БУФЕРОМ }

procedure AddToBuffer(Nucleotide: TNucleotideRecord);
begin
  if State.BufferSize < MAX_BUFFER_SIZE then
  begin
    Inc(State.BufferSize);
    State.NucleotidesBuffer[State.BufferSize] := Nucleotide;
  end;
end;

procedure RemoveFromBuffer(Index: Integer);
var
  i: Integer;
begin
  if (Index >= 1) and (Index <= State.BufferSize) then
  begin
    for i := Index to State.BufferSize - 1 do
      State.NucleotidesBuffer[i] := State.NucleotidesBuffer[i + 1];
    Dec(State.BufferSize);
  end;
end;

function GetBufferFillPercent: Integer;
begin
  if MAX_BUFFER_SIZE > 0 then
    GetBufferFillPercent := Trunc(State.BufferSize / MAX_BUFFER_SIZE * 100)
  else
    GetBufferFillPercent := 0;
end;

{ ПРОИЗВОДИТЕЛИ НУКЛЕОТИДОВ }

procedure NucleotideProducer(PotokNo: Integer);
var
	TempStr: String;
	Nucleotide: TNucleotideRecord;
	NucleotideType: TNucleotide;
begin
  { Проверяем активность и свободное место в буфере }
  if (not State.Potoks[PotokNo].IsActive) or (State.BufferSize >= MAX_BUFFER_SIZE) then
  begin
    { Деактивируем поток и сбрасываем импульсы }
    State.Potoks[PotokNo].IsActive := false;
    State.Impulses := 0;
    Exit;
  end;

    { Определяем тип нуклеотида по номеру потока }
    NucleotideType := TNucleotide(PotokNo - 1);  { 1->0, 2->1, 3->2, 4->3 }
    
    Inc(State.ProducerCounters[NucleotideType]);
    
    Nucleotide.Nucleotide := NucleotideType;
    Nucleotide.ID := State.ProducerCounters[NucleotideType];
    Nucleotide.Used := False;
	Nucleotide.TypeIDstr[1] := NucleotideToChar(NucleotideType);
    Str(Nucleotide.ID:3, TempStr);
	if TempStr[1] = ' ' then TempStr[1] := '0';
    if TempStr[2] = ' ' then TempStr[2] := '0';
	Nucleotide.TypeIDstr[2] := TempStr[1];
    Nucleotide.TypeIDstr[3] := TempStr[2];
    Nucleotide.TypeIDstr[4] := TempStr[3];
	
    AddToBuffer(Nucleotide);
    
    { Отображение }
    case PotokNo of
      1: begin GotoXY(16, 3); TextColor(NucleotideToColor(NucleotideType)); end;
      2: begin GotoXY(31, 3); TextColor(NucleotideToColor(NucleotideType)); end;
      3: begin GotoXY(46, 3); TextColor(NucleotideToColor(NucleotideType)); end;
      4: begin GotoXY(61, 3); TextColor(NucleotideToColor(NucleotideType)); end;
	  else begin GotoXY(0, 0); TextColor(7); end;
    end;

	Write(Nucleotide.TypeIDstr, ' ');
	GotoXY(WhereX-7, WhereY+1);
	TextAttr := 46;
	Write(' Активный ');
	TextAttr := 7;
	
	Delay(State.DelayTime);
	Window(6, 4, 76, 4);
	ClrScr;
	Window(1, 1, 80, 25);

end;

{  ПОТРЕБИТЕЛИ - СОЗДАТЕЛИ ПАР }

procedure CreateBasePair(Nucleotide1, Nucleotide2: TNucleotideRecord);
var
  i, CodonStart: Integer;
  RNAPair: TBasePair;
begin
  { Сдвигаем очередь ВПРАВО }
  for i := SYNTHESIS_QUEUE_LENGTH downto 2 do
    State.SynthesisQueue[i] := State.SynthesisQueue[i - 1];
  
  { Добавляем новую ДНК-пару СЛЕВА }
  State.SynthesisQueue[1].PairType := GetBasePairType(Nucleotide1.Nucleotide, Nucleotide2.Nucleotide);
  State.SynthesisQueue[1].Nucleotide1 := Nucleotide1;
  State.SynthesisQueue[1].Nucleotide2 := Nucleotide2;
  
  { Проверяем есть ли 3 ДНК-пары в конце очереди для кодона }
  CodonStart := SYNTHESIS_QUEUE_LENGTH - 2;
  if (State.SynthesisQueue[CodonStart].PairType <> bpNone) and
     (State.SynthesisQueue[CodonStart + 1].PairType <> bpNone) and
     (State.SynthesisQueue[CodonStart + 2].PairType <> bpNone) then
  begin
    { Берем 3 ДНК-пары с конца и транскрибируем в РНК для кодона }
    for i := CodonStart to SYNTHESIS_QUEUE_LENGTH do
    begin
      if State.Synthesis.CodonPosition < CODON_LENGTH then
      begin
        Inc(State.Synthesis.CodonPosition);
        { Транскрибируем ДНК>РНК при переходе в кодон }
        RNAPair := TranscribeToRNA(State.SynthesisQueue[i].PairType);
        State.Synthesis.CurrentCodon[State.Synthesis.CodonPosition] := RNAPair;
      end;
      
      { Очищаем использованную ДНК-пару }
      State.SynthesisQueue[i].PairType := bpNone;
    end;
  end;
end;

function GetNeededPartner(Nucleotide: TNucleotide): TNucleotide;
begin
  case Nucleotide of
    ntAdenine: GetNeededPartner := ntThymine;
    ntThymine: GetNeededPartner := ntAdenine;
    ntGuanine: GetNeededPartner := ntCytosine;
    ntCytosine: GetNeededPartner := ntGuanine;
    else GetNeededPartner := ntNone;
  end;
end;


procedure BasePairConsumer(PotokNo: Integer);
var
  CurrentPair: TBasePairRecord;
  TopNucleotide: TNucleotideRecord;
  DisplayX, PairIndex: Integer;
  LeftType, RightType: TNucleotide;
  LeftStr, RightStr: String;
  ProducerPotok: Integer;
begin
  { Проверяем активность и свободное место в буфере }
  if (not State.Potoks[PotokNo].IsActive) or (State.BufferSize <= 0) then
  begin
    { Деактивируем поток и сбрасываем импульсы }
    State.Potoks[PotokNo].IsActive := false;
    State.Impulses := 0;
    Exit;
  end;

  PairIndex := PotokNo - MAX_PRODUCERS;
  CurrentPair := State.BasePairs[PairIndex];

  { Определяем позицию для отображения }
  case PotokNo of
    5: DisplayX := 8+5;   { A-T }
    6: DisplayX := 23+5;  { T-A }
    7: DisplayX := 38+5;  { G-C }
    8: DisplayX := 53+5;  { C-G }
  end;

  { Показываем плашку "Активный" }
  GotoXY(DisplayX, 9);
  TextBackground(2);
  TextColor(15);
  Write(' Активный ');
  TextBackground(0);
  TextColor(7);
  
  { Если буфер не пуст, берем нуклеотид с вершины }
  if State.BufferSize > 0 then
  begin
    TopNucleotide := State.NucleotidesBuffer[State.BufferSize];
    RemoveFromBuffer(State.BufferSize); { Всегда убираем из буфера }
	
	{ Определяем оба нужных типа для этого потребителя }
	LeftType := TNucleotide(PotokNo - 5);        { Левый тип }
	RightType := GetNeededPartner(LeftType);     { Правый тип }
    
	
    { Пытаемся использовать нуклеотид для левой стороны }
    if (TopNucleotide.Nucleotide = LeftType) and 
       (CurrentPair.Nucleotide1.Nucleotide = ntNone) then
    begin
      State.BasePairs[PairIndex].Nucleotide1 := TopNucleotide;
      TopNucleotide.Used := True;
    end
    { Или пытаемся использовать для правой стороны }
    else if (TopNucleotide.Nucleotide = RightType) and 
            (CurrentPair.Nucleotide2.Nucleotide = ntNone) then
    begin
      State.BasePairs[PairIndex].Nucleotide2 := TopNucleotide;
      TopNucleotide.Used := True;
    end;
    
	{ Корректируем приоритет производителя }
    ProducerPotok := Integer(TopNucleotide.Nucleotide) + 1;
    
    if TopNucleotide.Used then
    begin
      { Инкремент приоритета, но не больше 100 }
      if State.Potoks[ProducerPotok].Priority < 100 then
        Inc(State.Potoks[ProducerPotok].Priority);
    end
    else
    begin
      { Декремент приоритета, но не меньше 1 }
      if State.Potoks[ProducerPotok].Priority > 1 then
        Dec(State.Potoks[ProducerPotok].Priority);
    end;
	
    { Если обе стороны заняты - создаем пару }
    if (State.BasePairs[PairIndex].Nucleotide1.Nucleotide <> ntNone) and
       (State.BasePairs[PairIndex].Nucleotide2.Nucleotide <> ntNone) then
    begin
      { Создаем пару в очередь синтеза }
      CreateBasePair(
        State.BasePairs[PairIndex].Nucleotide1,
        State.BasePairs[PairIndex].Nucleotide2
      );
      
      { Освобождаем пару }
      State.BasePairs[PairIndex].Nucleotide1.Nucleotide := ntNone;
      State.BasePairs[PairIndex].Nucleotide2.Nucleotide := ntNone;
    end;
  end;
  
  { Обновляем отображение пары }
  
  GotoXY(DisplayX, 8);
  
  { Левая сторона }
  if State.BasePairs[PairIndex].Nucleotide1.Nucleotide <> ntNone then
    LeftStr := State.BasePairs[PairIndex].Nucleotide1.TypeIDstr 
  else
    LeftStr := NucleotideToChar(TNucleotide(PotokNo-5)) + '___';
    
  { Правая сторона }  
  if State.BasePairs[PairIndex].Nucleotide2.Nucleotide <> ntNone then
    RightStr := State.BasePairs[PairIndex].Nucleotide2.TypeIDstr 
  else
    RightStr := NucleotideToChar(GetNeededPartner(TNucleotide(PotokNo-5))) + '___';
  
  Write(LeftStr, '-', RightStr);
  
  Delay(State.DelayTime);
  
  { Очищаем строку статусов }
  Window(6, 9, 76, 9);
  ClrScr;
  Window(1, 1, 80, 25);
end;

{ ВИЗУАЛИЗАЦИЯ }

procedure DrawBorder(X1, Y1, X2, Y2: Integer; Title: String);
var
  TitlePos: Integer;
begin
  Window(X1, Y1, X2, Y2);
  TextBackground(3);
  ClrScr;
  TitlePos := (X2 - X1 - Length(Title)) div 2 + 1;
  if TitlePos < 1 then TitlePos := 1;
  GotoXY(TitlePos, 1);
  TextColor(15);
  Write(Title);
  Window(X1 + 2, Y1 + 1, X2 - 2, Y2 - 1);
  TextBackground(0);
  ClrScr;
  Window(1, 1, 80, 25);
  TextColor(7);
end;

procedure DisplayBuffer;
var
  i: Integer;
begin
  GotoXY(8, 13);
  TextColor(7);
  Write('БУФЕР: ');
  
  for i := 1 to MAX_BUFFER_SIZE do
  begin
    if i <= State.BufferSize then
    begin
      TextColor(NucleotideToColor(State.NucleotidesBuffer[i].Nucleotide));
	  Write(State.NucleotidesBuffer[i].TypeIDstr, ' ');
    end
    else
    begin
      TextColor(8);
      Write('[  ] ');
    end;
  end; 
  { Процент заполненности }
  GotoXY(70, 13);
  TextColor(10);
  Write(GetBufferFillPercent:3, '%');
end;

procedure DisplaySynthesisStatus;
begin
  GotoXY(8, 16);
  TextColor(COLOR_STATUS);
  Write('СТАТУС: ');
  
  case State.Synthesis.Status of
    ssWaiting: 
      begin
        TextColor(COLOR_WAITING);
        Write('ОЖИДАНИЕ СТАРТ-КОДОНА');
      end;
    ssActive: 
      begin
        TextColor(COLOR_ACTIVE);
        Write('СИНТЕЗ АКТИВЕН       ');
      end;
    ssCompleted: 
      begin
        TextColor(COLOR_COMPLETED);
        Write('СИНТЕЗ ЗАВЕРШЕН      ');
      end;
  end;
end;

procedure DisplayCurrentCodon;
var
  i: Integer;
  CodonStr: String;
  Decoding: String;
  Color: Byte;
begin
  GotoXY(8, 17);
  TextColor(COLOR_STATUS);
  Write('ТЕКУЩИЙ КОДОН: ');
  
  { Отображаем текущий кодон }
  for i := 1 to CODON_LENGTH do
  begin
    if i <= State.Synthesis.CodonPosition then
    begin
      TextColor(11); { Голубой для заполненных позиций }
      Write(BasePairToStr(State.Synthesis.CurrentCodon[i]));
    end
    else
    begin
      TextColor(8); { Серый для пустых позиций }
      Write('---');
    end;
    
    if i < CODON_LENGTH then Write('-');
  end;
  
  { Расшифровка }
  if State.Synthesis.CodonPosition = CODON_LENGTH then
  begin
    CodonStr := GetCodonString(State.Synthesis.CurrentCodon);
    
    if CodonStr = 'AUG' then
    begin
      Decoding := 'СТАРТ (Мет)';
      Color := COLOR_ACTIVE;
    end
    else if (CodonStr = 'UAA') or (CodonStr = 'UAG') or (CodonStr = 'UGA') then
    begin
      Decoding := 'СТОП';
      Color := COLOR_COMPLETED;
    end
    else
    begin
      Decoding := GetAminoAcidName(CodonStr);
      Color := 14;
    end;
    
    GotoXY(45, 17);
    TextColor(Color);
    Write('[ ', CodonStr, ' -> ', Decoding, ' ]          ');
  end;
end;

procedure DisplayProteinChain;
var
  i: Integer;
  FirstLine: Boolean;
begin
  { Выводим количество аминокислот }
  GotoXY(40, 16);
  TextColor(COLOR_STATUS);
  Write('Аминокислот: ', State.Synthesis.ProteinLength);

  if State.Synthesis.ProteinLength = 0 then
  begin
    State.LastDisplayedAA := 0;
    State.CurrentDisplayLine := 18;
    State.CurrentDisplayPos := 8;
    Exit;
  end;

  { Если цепь короче чем было отображено - сбрасываем }
  if State.Synthesis.ProteinLength < State.LastDisplayedAA then
  begin
    State.LastDisplayedAA := 0;
    State.CurrentDisplayLine := 18;
    State.CurrentDisplayPos := 8;
  end;

  { Устанавливаем текущую позицию }
  GotoXY(State.CurrentDisplayPos, State.CurrentDisplayLine);

  { Проверяем первая ли это строка }
  FirstLine := (State.CurrentDisplayLine = 18) and (State.CurrentDisplayPos = 8);

  { Выводим "Белок: " только в начале первой строки }
  if FirstLine then
  begin
    TextColor(COLOR_STATUS);
    Write('Белок: ');
    State.CurrentDisplayPos := 15; { После "Белок: " }
    GotoXY(State.CurrentDisplayPos, State.CurrentDisplayLine);
  end;

  { Выводим только новые аминокислоты }
  for i := State.LastDisplayedAA + 1 to State.Synthesis.ProteinLength do
  begin
    { Добавляем тире между аминокислотами (кроме первой) }
    if (i > State.LastDisplayedAA + 1) or 
       (not FirstLine and (i = State.LastDisplayedAA + 1)) then
    begin
      TextColor(7);
      Write('-');
      Inc(State.CurrentDisplayPos);
    end;

    { Раскрашиваем аминокислоту }
    case State.Synthesis.ProteinChain[i] of
      'M': TextColor(10);
      'L', 'I', 'V': TextColor(11);
      'S', 'T': TextColor(14);
      'D', 'E': TextColor(13);
      'K', 'R': TextColor(12);
      'F', 'Y', 'W': TextColor(6);
      else TextColor(7);
    end;

    Write(State.Synthesis.ProteinChain[i]);
    Inc(State.CurrentDisplayPos);

    { Проверяем конец строки }
    if State.CurrentDisplayPos >= 73 then
    begin
      Inc(State.CurrentDisplayLine);
      if State.CurrentDisplayLine > 21 then
      begin
        { Очищаем и начинаем заново }
        Window(8, 18, 76, 21);
        ClrScr;
        Window(1, 1, 80, 25);
        State.CurrentDisplayLine := 18;
        State.CurrentDisplayPos := 8;
        GotoXY(8, 18);
        
        { Снова выводим "Белок: " }
        TextColor(COLOR_STATUS);
        Write('Белок: ');
        State.CurrentDisplayPos := 15;
        GotoXY(State.CurrentDisplayPos, State.CurrentDisplayLine);
      end
      else
      begin
        State.CurrentDisplayPos := 8;
        GotoXY(8, State.CurrentDisplayLine);
      end;
      FirstLine := false; 
    end;
  end;

  { Сохраняем последнюю отображенную позицию }
  State.LastDisplayedAA := State.Synthesis.ProteinLength;
end;


procedure DisplaySynthesisQueue;
var
  i: Integer;
  PairStr: String;
begin
  GotoXY(8, 14);
  TextColor(COLOR_STATUS);
  Write('ОЧЕРЕДЬ - НИТЬ ДНК: ');
  
  for i := 1 to SYNTHESIS_QUEUE_LENGTH do
  begin
    if State.SynthesisQueue[i].PairType <> bpNone then
    begin
      case State.SynthesisQueue[i].PairType of
        bpAT: PairStr := 'A-T';
        bpTA: PairStr := 'T-A';
        bpGC: PairStr := 'G-C';
        bpCG: PairStr := 'C-G';
        else PairStr := '---';
      end;
      
      case State.SynthesisQueue[i].PairType of
        bpAT, bpTA: TextColor(COLOR_ADENINE);
        bpGC, bpCG: TextColor(COLOR_GUANINE);
        else TextColor(7);
      end;
      Write(PairStr, ' ');
    end
    else
    begin
      TextColor(8);
      Write('--- ');
    end;
  end;
end;


procedure DisplayProducersPriority;
var
  i: Integer;
begin
  GotoXY(8, 15);
  TextColor(COLOR_STATUS);
  Write('Приоритет производителей: ');
  
  for i := 1 to MAX_PRODUCERS do
  begin
    TextColor(NucleotideToColor(TNucleotide(i-1)));
    Write(NucleotideToChar(TNucleotide(i-1)), ' - ');
    Write(State.Potoks[i].Priority:3, '% ');
  end;
end;


{ Обновленная статусная строка }
procedure DisplayControlInfo;
begin
  GotoXY(5, 24);
  TextColor(7);

  Write('Esc - выход | ');
  { Управление синтезом }
  Write('Ввод: ');
  case State.Synthesis.Status of
    ssWaiting: begin TextColor(14); Write('старт'); end;
    ssActive:  begin TextColor(12); Write('стоп'); end;
    ssCompleted: begin TextColor(8); Write('---'); end;
  end;
  
  TextColor(7);
  Write(' | ');
  
  { Управление потоками }
  Write('Пробел: ');
  if State.IsRunning then
  begin
    TextColor(12);
    Write('пауза');
  end
  else
  begin
    TextColor(10);
    Write('пуск');
  end;
  
  TextColor(7);
  Write(' | ');
  
  { Управление задержкой }
  Write('Стрелки /: задержка ', State.DelayTime, ' мс    ');

end;




{ УПРАВЛЕНИЕ ПОТОКАМИ }

function SelectNextPotok: Integer;
begin
  if State.BufferSize = 0 then           { БУФЕР ПУСТ }
    SelectNextPotok := Random(MAX_PRODUCERS) + 1     { Случайный 1-4 }
  else if State.BufferSize >= MAX_BUFFER_SIZE then  { БУФЕР ПОЛОН }
    SelectNextPotok := Random(MAX_CONSUMERS) + MAX_PRODUCERS + 1     { Случайный 5-8 }
  else
    SelectNextPotok := Random(State.PotokCount) + 1;  { Случайный 1-8 }
end;

{ ОБРАБОТЧИКИ ПРЕРЫВАНИЙ }

{$F+}
procedure TimerHandler; interrupt;
begin
  if not State.IsEscPressed then
  begin
    Dec(State.Impulses);
    
    if (State.Impulses <= 0) and State.IsRunning then
    begin
	  State.Potoks[State.CurrentPotok].IsActive :=False;
      State.CurrentPotok := SelectNextPotok;
      State.Impulses := 0 + Random(State.Potoks[State.CurrentPotok].Priority);
	  State.Potoks[State.CurrentPotok].IsActive :=True;
    end;
  end;
  
  asm
    PUSHF
    CALL OldTimeHandler
  end;
end;

{$F+}
procedure KeyHandler; interrupt;
var
  ScanCode: Byte;
begin
  ScanCode := Port[$60];
  
  case ScanCode of
    1:   State.IsEscPressed := True;                    { Esc - выход }
    28:  { Enter - управление синтезом }                { Enter }
         if State.Synthesis.Status = ssWaiting then
           State.Synthesis.Status := ssActive
         else if State.Synthesis.Status = ssActive then
           State.Synthesis.Status := ssCompleted;
    
    57:  { Пробел - пауза/возобновление потоков }       { Space }
         State.IsRunning := not State.IsRunning;  
    
    72:  { Стрелка вверх - увеличить задержку }         { Up }
         if State.DelayTime < 32767 then
           Inc(State.DelayTime);
    
    80:  { Стрелка вниз - уменьшить задержку }          { Down } 
	     if State.DelayTime > 0 then
           Dec(State.DelayTime);

  end;
  
  inline($9C);
  OldKeyHandler;
end;
{$F-}

{ ОСНОВНАЯ ПРОГРАММА }

procedure Initialize;
var
  i: Integer;
begin
  Randomize;
  
  { Инициализация состояния }
  State.CurrentPotok := 1;
  State.Impulses := 1;
  State.BufferSize := 0;
  State.IsEscPressed := False;
  State.IsRunning := True;  { Только этот флаг }
  
  { Инициализация синтеза }
  State.Synthesis.Status := ssWaiting;
  State.Synthesis.CodonPosition := 0;
  State.LastDisplayedAA := 0;
  State.CurrentDisplayLine := 18;
  State.CurrentDisplayPos := 8;
  
  { Инициализация потоков }
  State.PotokCount := MAX_PRODUCERS + MAX_CONSUMERS;

  for i := 1 to State.PotokCount do
	begin
	  State.Potoks[i].IsActive := False;
	  
	if i <= MAX_PRODUCERS then
		begin
			State.Potoks[i].PotokType := ptProducer;    { Потоки 1-4 }
			State.Potoks[i].Priority := PRODUCER_PRIORITY;
		end
	else
		begin
			State.Potoks[i].PotokType := ptConsumer;   { Потоки 5-8 }
			State.Potoks[i].Priority := CONSUMER_PRIORITY;
		end;
	end;
	
	 { Очищаем очередь синтеза }
	  for i := 1 to SYNTHESIS_QUEUE_LENGTH do
	  begin
		State.SynthesisQueue[i].PairType := bpNone;
		State.SynthesisQueue[i].Nucleotide1.Nucleotide := ntNone;
		State.SynthesisQueue[i].Nucleotide2.Nucleotide := ntNone;
	  end;
  
  { Инициализация счетчиков }
  for i := 0 to MAX_PRODUCERS-1 do
    State.ProducerCounters[TNucleotide(i)] := 0;
	
  for i := 1 to MAX_CONSUMERS do
	begin
	  State.BasePairs[i].Nucleotide1.Nucleotide := ntNone;
	  State.BasePairs[i].Nucleotide2.Nucleotide := ntNone;
	end;
  
  { Очистка экрана }
  ClrScr;
  
  { Рисуем интерфейс }
  DrawBorder(4, 2, 78, 5, 'ПРОИЗВОДИТЕЛИ НУКЛЕОТИДОВ');
  DrawBorder(4, 7, 78, 10, 'ПОТРЕБИТЕЛИ ПАР НУКЛЕОТИДОВ ');
  DrawBorder(4, 12, 78, 23, 'СИНТЕЗ БЕЛКА');
  
  { Информация }
  GotoXY(20, 24);
  Write('Esc - выход | Space - управление синтезом');
  
end;


procedure ProcessCompletedCodon;
var
  CodonStr: String;
  AminoAcid: Char;
begin
	if State.Synthesis.CodonPosition <> CODON_LENGTH then exit;
    CodonStr := GetCodonString(State.Synthesis.CurrentCodon);
    
    { Обработка старт-кодона - ТОЛЬКО в состоянии ожидания }
    if (CodonStr = 'AUG') and (State.Synthesis.Status = ssWaiting) then
    begin
      State.Synthesis.Status := ssActive;
      
      { Добавляем стартовую аминокислоту Methionine }
      if State.Synthesis.ProteinLength < MAX_PROTEIN_CHAIN_LENDTH then
      begin
        Inc(State.Synthesis.ProteinLength);
        State.Synthesis.ProteinChain[State.Synthesis.ProteinLength] := 'M';
      end;
    end

    { Обработка обычных кодонов - ТОЛЬКО в активном состоянии }
    else if State.Synthesis.Status = ssActive then
    begin
	  { Обработка стоп-кодонов }
	  if ((CodonStr = 'UAA') or (CodonStr = 'UAG') or (CodonStr = 'UGA'))  then  State.Synthesis.Status := ssCompleted;
      AminoAcid := TranslateCodonToAminoAcid(CodonStr);
      if State.Synthesis.ProteinLength < MAX_PROTEIN_CHAIN_LENDTH then
      begin
        Inc(State.Synthesis.ProteinLength);
        State.Synthesis.ProteinChain[State.Synthesis.ProteinLength] := AminoAcid;
      end;
    end;
	
	{ Сбрасываем кодон }
    State.Synthesis.CodonPosition := 0;

end;


begin
  { Обработка параметров командной строки }
  ValidateInputParams;
  { Инициализация }
  Initialize;
  
  { Установка обработчиков }
  GetIntVec($08, @OldTimeHandler);
  SetIntVec($08, Addr(TimerHandler));
  GetIntVec($09, @OldKeyHandler);
  SetIntVec($09, Addr(KeyHandler));
  
  { Главный цикл }
  while not State.IsEscPressed do
  begin
	case State.Potoks[State.CurrentPotok].PotokType of
		ptProducer: NucleotideProducer(State.CurrentPotok);
		ptConsumer: BasePairConsumer(State.CurrentPotok);
	end;
    DisplayBuffer;
    DisplaySynthesisStatus;
    DisplayCurrentCodon;
    DisplayProteinChain;
    DisplaySynthesisQueue;
	DisplayProducersPriority;
    ProcessCompletedCodon;
	DisplayControlInfo;
  end;
  
  { Восстановление обработчиков }
  SetIntVec($08, @OldTimeHandler);
  SetIntVec($09, @OldKeyHandler);
  
  { Завершение }
  NormVideo;
  ClrScr;
  Writeln('ДНК-симулятор завершен.');
  Writeln('Синтезировано аминокислот: ', State.Synthesis.ProteinLength);
end.