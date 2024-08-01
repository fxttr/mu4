-- Copyright (C) 2024 Florian Marrero Liestmann
-- SPDX-License-Identifier:  GPL-3.0-only

package Mu4.ELF is
    procedure Load
       (File_Address : in Memory.canonical_address; File_Size : in number;
        Task_Name    : in string; Error_Status : out error);

private
    ELF_Tag : constant string := "ELF";

    type identity_class is new byte;
    Protected_Mode : constant identity_class := 1;
    Long_Mode      : constant identity_class := 2;

    type identity_endianness is new byte;
    Little_Endian : constant identity_endianness := 1;
    Big_Endian    : constant identity_endianness := 2;

    type identity is limited record
        Magic_Byte  : number range 0 .. 2**08 - 1 := 0;
        Magic_Name  : string (1 .. 3)             := (others => NUL);
        Class       : identity_class              := identity_class'First;
        Endianness  : identity_endianness         := identity_endianness'First;
        Version     : number range 0 .. 2**08 - 1 := 0;
        ABI         : number range 0 .. 2**08 - 1 := 0;
        ABI_Version : number range 0 .. 2**08 - 1 := 0;
        Padding     : number range 0 .. 2**56 - 1 := 0;
    end record with
       Object_Size => (9 * 8) + 55 + 1;
    for identity use record
        Magic_Byte  at 0 range 0 .. 07;
        Magic_Name  at 1 range 0 .. 23;
        Class       at 4 range 0 .. 07;
        Endianness  at 5 range 0 .. 07;
        Version     at 6 range 0 .. 07;
        ABI         at 7 range 0 .. 07;
        ABI_Version at 8 range 0 .. 07;
        Padding     at 9 range 0 .. 55;
    end record;

    type header_file_type is new word;
    No_Object_File : constant header_file_type := 16#0000#;
    Relocatable_Object_File : constant header_file_type := 16#0002#;
    Executable_Object_File : constant header_file_type := 16#0002#;
    Dynamic_Object_File : constant header_file_type := 16#0003#;
    Core_Object_File : constant header_file_type := 16#0004#;
    OS_Specific_Object_File_Low : constant header_file_type := 16#FE00#;
    OS_Specific_Object_File_High : constant header_file_type := 16#FEFF#;
    Processor_Specific_Object_File_Low : constant header_file_type := 16#FF00#;
    Processor_Specific_Object_File_High : constant header_file_type :=
       16#FFFF#;

    type file_header is limited record
        File_Identity              : identity;
        File_Type                  : header_file_type := No_Object_File;
        Instruction_Set            : number range 0 .. 2**16 - 1 := 0;
        Version                    : number range 0 .. 2**32 - 1 := 0;
        Entry_Address              : address                     := 0;
        Program_Header_Offset      : address                     := 0;
        Section_Header_Offset      : address                     := 0;
        Flags                      : number range 0 .. 2**32 - 1 := 0;
        Header_Size                : number range 0 .. 2**16 - 1 := 0;
        Program_Header_Entry_Size  : number range 0 .. 2**16 - 1 := 0;
        Program_Header_Entry_Count : number range 0 .. 2**16 - 1 := 0;
        Section_Header_Entry_Size  : number range 0 .. 2**16 - 1 := 0;
        Section_Header_Entry_Count : number range 0 .. 2**16 - 1 := 0;
        Section_Header_Names_Index : number range 0 .. 2**16 - 1 := 0;
    end record with
       Object_Size => (62 * 8) + 15 + 1;
    for file_header use record
        File_Identity              at 00 range 0 .. 127;
        File_Type                  at 16 range 0 .. 015;
        Instruction_Set            at 18 range 0 .. 015;
        Version                    at 20 range 0 .. 031;
        Entry_Address              at 24 range 0 .. 063;
        Program_Header_Offset      at 32 range 0 .. 063;
        Section_Header_Offset      at 40 range 0 .. 063;
        Flags                      at 48 range 0 .. 031;
        Header_Size                at 52 range 0 .. 015;
        Program_Header_Entry_Size  at 54 range 0 .. 015;
        Program_Header_Entry_Count at 56 range 0 .. 015;
        Section_Header_Entry_Size  at 58 range 0 .. 015;
        Section_Header_Entry_Count at 60 range 0 .. 015;
        Section_Header_Names_Index at 62 range 0 .. 015;
    end record;

    type segment is new doubleword;
    Null_Segment                          : constant segment := 16#0000_0000#;
    Loadable_Segment                      : constant segment := 16#0000_0001#;
    Dynamic_Linking_Segment               : constant segment := 16#0000_0002#;
    Interpreter_Segment                   : constant segment := 16#0000_0003#;
    Auxiliary_Segment                     : constant segment := 16#0000_0004#;
    Reserved_Segment                      : constant segment := 16#0000_0005#;
    Program_Header_Table_Segment          : constant segment := 16#0000_0006#;
    Thread_Local_Storage_Template_Segment : constant segment := 16#0000_0007#;
    OS_Specific_Segment_Low               : constant segment := 16#6000_0000#;
    GNU_Exception_Information_Segment     : constant segment := 16#6474_E550#;
    GNU_Stack_Segment                     : constant segment := 16#6474_E551#;
    OS_Specific_Segment_High              : constant segment := 16#6FFF_FFFF#;
    Processor_Specific_Low                : constant segment := 16#7000_0000#;
    Processor_Specific_High               : constant segment := 16#7FFF_FFFF#;

    type segment_flag is new doubleword;
    No_Access_Segment                : constant segment_flag := 0;
    Executable_Segment               : constant segment_flag := 1;
    Writeable_Segment                : constant segment_flag := 2;
    Writeable_And_Executable_Segment : constant segment_flag := 3;
    Readable_Segment                 : constant segment_flag := 4;
    Readable_And_Executable_Segment  : constant segment_flag := 5;
    Readable_And_Writeable_Segment   : constant segment_flag := 6;
    Full_Access_Segment              : constant segment_flag := 7;
    Unspecified_Access_Segment       : constant segment_flag := 16#F000_0000#;

    type program_header_entry is limited record
        Segment_Type     : segment      := Null_Segment;
        Permission_Flag  : segment_flag := No_Access_Segment;
        File_Offset      : address      := 0;
        Virtual_Address  : address      := 0;
        Physical_Address : address      := 0;
        File_Size        : number       := 0;
        Memory_Size      : number       := 0;
        Alignment        : number       := 0;
    end record with
       Object_Size => (48 * 8) + 63 + 1;
    for program_header_entry use record
        Segment_Type     at 00 range 0 .. 31;
        Permission_Flag  at 04 range 0 .. 31;
        File_Offset      at 08 range 0 .. 63;
        Virtual_Address  at 16 range 0 .. 63;
        Physical_Address at 24 range 0 .. 63;
        File_Size        at 32 range 0 .. 63;
        Memory_Size      at 40 range 0 .. 63;
        Alignment        at 48 range 0 .. 63;
    end record;

    type section is new doubleword;
    Null_Section                        : constant section := 16#0000_0000#;
    Program_Data_Section                : constant section := 16#0000_0001#;
    Symbol_Table_Section                : constant section := 16#0000_0002#;
    String_Table_Section                : constant section := 16#0000_0003#;
    Relocation_Entries_Addend_Section   : constant section := 16#0000_0004#;
    Symbol_hash_table_Section           : constant section := 16#0000_0005#;
    Dynamic_linking_Section             : constant section := 16#0000_0006#;
    Notes_Section                       : constant section := 16#0000_0007#;
    Bss_Section                         : constant section := 16#0000_0008#;
    Relocation_Entries_Section          : constant section := 16#0000_0009#;
    Reserved_Section                    : constant section := 16#0000_000A#;
    Dynamic_Linker_Symbol_Table_Section : constant section := 16#0000_000B#;
    Constructor_Array_Section           : constant section := 16#0000_000E#;
    Destructor_Array_Section            : constant section := 16#0000_000F#;
    Preconstructor_Array_Section        : constant section := 16#0000_0010#;
    Group_Section                       : constant section := 16#0000_0011#;
    Indices_Section                     : constant section := 16#0000_0012#;
    Number_Of_Section_Types_Section     : constant section := 16#0000_0013#;
    OS_Specific_Section_Base            : constant section := 16#6000_0000#;

    type section_flag is new doubleword;
    Writeable_Section_Flag            : constant section_flag := 16#0000_0001#;
    Allocated_Section_Flag            : constant section_flag := 16#0000_0002#;
    Executable_Section_Flag           : constant section_flag := 16#0000_0004#;
    Mergeable_Section_Flag            : constant section_flag := 16#0000_0010#;
    Strings_Section_Flag              : constant section_flag := 16#0000_0020#;
    Extra_Information_Section_Flag    : constant section_flag := 16#0000_0040#;
    Strict_Order_Section_Flag         : constant section_flag := 16#0000_0080#;
    Specially_Handled_Section_Flag    : constant section_flag := 16#0000_0100#;
    Group_Member_Section_Flag         : constant section_flag := 16#0000_0200#;
    Thread_Local_Storage_Section_Flag : constant section_flag := 16#0000_0400#;
    OS_Specific_Section_Flag          : constant section_flag := 16#0FF0_0000#;
    Specially_Ordered_Section_Flag    : constant section_flag := 16#4000_0000#;
    Potentially_Excluded_Section_Flag : constant section_flag := 16#8000_0000#;
    Processor_Specific_Section_Flag   : constant section_flag := 16#F000_0000#;

    type section_header_entry is limited record
        Name_Index           : number range 0 .. 2**32 - 1 := 0;
        Section_Type         : section                     := section'First;
        Flags                : number                      := 0;
        Virtual_Address      : address                     := 0;
        File_Offset          : address                     := 0;
        File_Size            : number                      := 0;
        Linked_Section_Index : number range 0 .. 2**32 - 1 := 0;
        Extra_Information    : number range 0 .. 2**32 - 1 := 0;
        Alignment            : number                      := 0;
        Section_Entry_Size   : number                      := 0;
    end record with
       Object_Size => (56 * 8) + 63 + 1;
    for section_header_entry use record
        Name_Index           at 00 range 0 .. 31;
        Section_Type         at 04 range 0 .. 31;
        Flags                at 08 range 0 .. 63;
        Virtual_Address      at 16 range 0 .. 63;
        File_Offset          at 24 range 0 .. 63;
        File_Size            at 32 range 0 .. 63;
        Linked_Section_Index at 40 range 0 .. 31;
        Extra_Information    at 44 range 0 .. 31;
        Alignment            at 48 range 0 .. 63;
        Section_Entry_Size   at 56 range 0 .. 63;
    end record;

    function Valid_File_Header
       (Header : in file_header; File_Size : in number) return boolean;

    function Valid_Program_Header_Entry
       (Header       : in program_header_entry;
        File_Address : in Memory.canonical_address; File_Size : in number)
        return boolean with
       Pre =>
        address (File_Address) + address (File_Size) not in
           Memory.invalid_address'Range;

end Mu4.ELF;
